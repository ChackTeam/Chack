import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/icons.dart';
import '../../constants/colors.dart';
import '../../components/custom_alert_banner.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ProfileSettingsScreenState createState() => ProfileSettingsScreenState();
}

class ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  DateTime? _selectedBirthDate;
  String? _profileImageUrl;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _profileImageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // _loadUserData 메서드 수정
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _nicknameController.text = data['nickname'] ?? '';
            _selectedBirthDate = data['birthDate'] != null
                ? DateTime.parse(data['birthDate'])
                : null;
            // photoURL 필드가 없을 수 있으므로 null 처리
            _profileImageUrl = data['photoURL'];
          });
        }
      }
    } catch (e) {
      // print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // _updateProfileImage 메서드 수정
  Future<void> _updateProfileImage() async {
    if (_profileImageFile == null) return;
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final storageRef =
            _storage.ref().child('profile_images/${user.uid}.jpg');
        final uploadTask = await storageRef.putFile(_profileImageFile!);
        final imageUrl = await uploadTask.ref.getDownloadURL();

        // 기존 문서에 photoURL 필드만 추가/업데이트
        await _firestore.collection('users').doc(user.uid).update({
          'photoURL': imageUrl,
        });

        setState(() => _profileImageUrl = imageUrl);
        if (mounted) {
          CustomAlertBanner.show(
            context,
            message: '프로필 이미지가 업데이트되었습니다.',
            iconColor: AppColors.pointColor,
          );
        }
      }
    } catch (e) {
      // print('Error uploading profile image: $e');
      if (mounted) {
        CustomAlertBanner.show(
          context,
          message: '이미지 업로드 중 오류가 발생했습니다.',
          iconColor: AppColors.errorColor,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'nickname': _nicknameController.text,
          'birthDate': _selectedBirthDate?.toIso8601String(),
        });
        CustomAlertBanner.show(
          context,
          message: '프로필 정보가 업데이트되었습니다.',
          iconColor: AppColors.pointColor,
        );

        Navigator.pop(context);
      }
    } catch (e) {
      // print('Error updating user data: $e');
      CustomAlertBanner.show(
        context,
        message: '프로필 정보 업데이트 중 오류가 발생했습니다.',
        iconColor: AppColors.errorColor,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() => _profileImageFile = File(pickedFile.path));
      await _updateProfileImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '프로필 설정',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: _pickProfileImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.pointColor.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: _profileImageFile != null ||
                                  _profileImageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: _profileImageFile != null
                                      ? Image.file(
                                          _profileImageFile!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          _profileImageUrl!,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Padding(
                                              padding: const EdgeInsets.all(30),
                                              child: SvgPicture.asset(
                                                AppIcons.profileIcon,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                  AppColors.pointColor,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(30),
                                  child: SvgPicture.asset(
                                    AppIcons.profileIcon,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.pointColor,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.pointColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  '닉네임',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    hintText: '닉네임을 입력해주세요',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '생년월일',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedBirthDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.pointColor,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      setState(() => _selectedBirthDate = pickedDate);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedBirthDate != null
                              ? '${_selectedBirthDate!.year}년 ${_selectedBirthDate!.month}월 ${_selectedBirthDate!.day}일'
                              : '생년월일을 선택해주세요',
                          style: TextStyle(
                            color: _selectedBirthDate != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateUserData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isLoading ? '저장 중...' : '저장하기',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
