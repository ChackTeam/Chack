import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firebase 에러 메시지를 한글로 변환
  String _getKoreanErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-credential':
      case 'invalid-verification-code':
      case 'invalid-verification-id':
        return '인증 정보가 올바르지 않습니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'user-not-found':
      case 'wrong-password':
        return '아이디/패스워드가 틀렸습니다.'; // 이메일 또는 비밀번호 오류일 경우
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'operation-not-allowed':
        return '해당 인증 방식이 비활성화되어 있습니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
      case 'too-many-requests':
        return '너무 많은 요청이 있었습니다. 잠시 후 다시 시도해주세요.';
      case 'credential-already-in-use':
        return '이미 다른 계정에서 사용 중인 인증 정보입니다.';
      default:
        return '로그인 중 오류가 발생했습니다. 다시 시도해주세요.';
    }
  }

  // 현재 유저 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 이메일 회원가입
  Future<void> signUpWithEmail({
    required String nickname,
    required String email,
    required String password,
    required String birthDate,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = credential.user!.uid;

      await credential.user?.updateDisplayName(nickname);

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'nickname': nickname,
        'email': email,
        'birthDate': birthDate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await credential.user?.sendEmailVerification();

      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code}');
      throw _getKoreanErrorMessage(e.code);
    } catch (e) {
      print('Sign Up Error: $e');
      throw '회원가입 중 오류가 발생했습니다.';
    }
  }

  // 이메일 로그인
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!credential.user!.emailVerified) {
        await _auth.signOut();
        throw '이메일 인증이 필요합니다. 메일함을 확인해주세요.';
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      // 로그인 시 이메일 또는 비밀번호 오류는 특정 메시지로 출력
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw '아이디/패스워드가 틀렸습니다.';
      }
      print('Firebase Auth Error: ${e.code}');
      throw _getKoreanErrorMessage(e.code);
    } catch (e) {
      print('Sign In Error: $e');
      throw '로그인 중 오류가 발생했습니다.';
    }
  }

  // 인증 메일 재발송
  Future<void> resendVerificationEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.sendEmailVerification();
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      print('Resend Verification Error: ${e.code}');
      throw _getKoreanErrorMessage(e.code);
    } catch (e) {
      print('Resend Verification Error: $e');
      throw '인증 메일 발송에 실패했습니다.';
    }
  }

  // 이메일 인증 상태 확인
  Future<bool> isEmailVerified(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final isVerified = credential.user?.emailVerified ?? false;
      if (!isVerified) {
        await _auth.signOut();
      }
      return isVerified;
    } catch (e) {
      print('Verification Check Error: $e');
      return false;
    }
  }

  // 구글 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists || !userDoc.data()!.containsKey('birthDate')) {
          return userCredential;
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Google Sign-In Error: ${e.code}');
      throw _getKoreanErrorMessage(e.code);
    } catch (e) {
      print('Google Sign-In Error: $e');
      throw '구글 로그인 중 오류가 발생했습니다.';
    }
  }

  // 현재 유저 가져오기
  User? getCurrentUser() => _auth.currentUser;

  // 로그아웃
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Sign Out Error: $e');
      throw '로그아웃에 실패했습니다.';
    }
  }
}
