// components/custom_search_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chack_project/constants/icons.dart';
import 'package:chack_project/constants/colors.dart';

class CustomSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLogoTap;
  final VoidCallback? onProfileTap;
  final String? searchText; // 검색어를 표시하기 위해 추가
  final bool showBackButton; // 뒤로가기 버튼 표시 여부
  final VoidCallback? onBackTap; // 뒤로가기 버튼 클릭 핸들러

  const CustomSearchBar({
    super.key,
    this.onTap,
    this.onLogoTap,
    this.onProfileTap,
    this.searchText,
    this.showBackButton = false,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      padding: const EdgeInsets.only(left: 10, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 로고 또는 뒤로가기 버튼
          if (showBackButton)
            GestureDetector(
              onTap: onBackTap ?? () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 24,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: onLogoTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SvgPicture.asset(
                  AppIcons.chackIcon,
                  width: 24,
                ),
              ),
            ),

          const SizedBox(width: 5),

          // 검색창
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: ShapeDecoration(
                  color: Colors.black.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      searchText ?? '읽고 싶은 책을 알려주세요',
                      style: TextStyle(
                        color: searchText != null
                            ? Colors.black.withOpacity(0.8)
                            : Colors.black.withOpacity(0.4),
                        fontSize: 16,
                        fontFamily: 'SUITE',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 프로필 아이콘
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final photoURL = userData?['photoURL'] as String?;

              return GestureDetector(
                onTap: onProfileTap,
                child: Hero(
                  tag: 'profile_icon_tag',
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.pointColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: photoURL != null
                        ? Padding(
                            padding: const EdgeInsets.all(0.5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                photoURL,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                cacheWidth: null,
                                headers: const {
                                  'Cache-Control': 'no-cache',
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: SvgPicture.asset(
                                      AppIcons.profileIcon,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.pointColor,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(10),
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
              );
            },
          ),
        ],
      ),
    );
  }
}
