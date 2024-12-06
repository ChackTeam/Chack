import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:chack_project/services/location_service.dart';
import 'package:chack_project/services/recommended_books_service.dart';

class LibraryInfoWidget extends StatefulWidget {
  final String isbn;
  final RecommendedBooksService recommendedBooksService;

  const LibraryInfoWidget({
    super.key,
    required this.isbn,
    required this.recommendedBooksService,
  });

  @override
  State<LibraryInfoWidget> createState() => _LibraryInfoWidgetState();
}

class _LibraryInfoWidgetState extends State<LibraryInfoWidget> {
  final LocationService _locationService = LocationService();  // 싱글톤 인스턴스 사용
  Map<String, dynamic>? _libraryInfo;
  String? _errorMessage;
  bool _isLoading = true;
  StreamSubscription<Position>? _locationSubscription;
  Position? _lastPosition;

  @override
  void initState() {
    super.initState();
    _setupLocationSubscription();
  }

  Future<void> _setupLocationSubscription() async {
    try {
      // 초기 위치 정보 가져오기
      _lastPosition = await _locationService.getCurrentLocation();
      if (_lastPosition != null) {
        await _fetchLibraryInfo(_lastPosition!);
      }

      // 위치 변경 구독
      _locationSubscription = _locationService.positionStream.listen((position) {
        // 위치가 유의미하게 변경되었을 때만 업데이트
        if (_shouldUpdateLocation(position)) {
          _lastPosition = position;
          _fetchLibraryInfo(position);
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = '위치 정보를 불러올 수 없습니다';
        _isLoading = false;
      });
    }
  }

  bool _shouldUpdateLocation(Position newPosition) {
    if (_lastPosition == null) return true;

    final distance = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );
    
    return distance > 100; // 100m 이상 이동했을 때만 업데이트
  }

  Future<void> _fetchLibraryInfo(Position position) async {
    try {
      final libraryInfo = await widget.recommendedBooksService.fetchLibrary(
        widget.isbn,
        position,
      );

      if (mounted) {
        setState(() {
          _libraryInfo = libraryInfo;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '도서관 정보를 불러오는데 실패했습니다';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Text(
          _errorMessage!,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontFamily: 'SUITE',
          ),
          textAlign: TextAlign.right,
        ),
      );
    }

    if (_libraryInfo == null || _libraryInfo!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(right: 16),
        child: Text(
          '주변 도서관 정보가 없습니다',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontFamily: 'SUITE',
          ),
          textAlign: TextAlign.right,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _libraryInfo!['name'] ?? '도서관 정보 없음',
            style: const TextStyle(
              fontFamily: "SUITE",
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,  // Row를 콘텐츠 크기에 맞게 설정
            children: [
              Text(
                '${((_libraryInfo!['distance'] as num).toDouble() / 1000).toStringAsFixed(1)}km',
                style: TextStyle(
                  fontFamily: "SUITE",
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),  // 거리와 대출가능 여부 사이 간격
              Text(
                (_libraryInfo?['loanAvailable'] == 'Y') ? '대출 가능' : '대출 불가',
                style: TextStyle(
                  fontFamily: "SUITE",
                  fontSize: 12,
                  color: (_libraryInfo?['loanAvailable'] == 'Y') 
                    ? Colors.green 
                    : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}