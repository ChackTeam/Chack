class BookDataNormalizer {
  static String normalizeTitle(String title) {
    String normalized = title;

    // 괄호 제거
    normalized = normalized.replaceAll(RegExp(r'\([^)]*\)'), '');

    // ':' 또는 '=' 이전의 텍스트만 사용
    if (normalized.contains(':')) {
      normalized = normalized.split(':')[0];
    } else if (normalized.contains('=')) {
      normalized = normalized.split('=')[0];
    }

    // 연속된 공백 제거 및 앞뒤 공백 제거
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();

    return normalized;
  }

  static String normalizeAuthor(String author) {
    String normalized = author;

    // '지은이:', '저자:', '글쓴이:' 패턴 처리
    for (var prefix in ['지은이:', '저자:', '글쓴이:']) {
      if (normalized.contains(prefix)) {
        normalized = normalized.split(prefix)[1];
        break;
      }
    }

    // 괄호로 둘러싸인 '지은이', '저자', '글쓴이' 제거
    normalized = normalized.replaceAll(RegExp(r'\s*\([^)]*지은이[^)]*\)'), '')
                         .replaceAll(RegExp(r'\s*\([^)]*저자[^)]*\)'), '')
                         .replaceAll(RegExp(r'\s*\([^)]*글쓴이[^)]*\)'), '');

    // 연속된 공백 제거 및 앞뒤 공백 제거
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();

    return normalized;
  }

  static String normalizePublisher(String publisher) {
    String normalized = publisher;

    // '출판사:' 패턴 처리
    if (normalized.contains('출판사:')) {
      normalized = normalized.split('출판사:')[1];
    }

    // 괄호로 둘러싸인 '출판사', '출판' 제거
    normalized = normalized.replaceAll(RegExp(r'\s*\([^)]*출판사[^)]*\)'), '')
                         .replaceAll(RegExp(r'\s*\([^)]*출판[^)]*\)'), '');

    // 연속된 공백 제거 및 앞뒤 공백 제거
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();

    return normalized;
  }
}