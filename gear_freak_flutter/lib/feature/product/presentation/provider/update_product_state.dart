import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 상품 수정 상태
sealed class UpdateProductState {
  /// UpdateProductState 생성자
  const UpdateProductState();
}

/// 초기 상태
class UpdateProductInitial extends UpdateProductState {
  /// UpdateProductInitial 생성자
  const UpdateProductInitial();
}

/// 상품 데이터 로딩 중 상태
class UpdateProductLoading extends UpdateProductState {
  /// UpdateProductLoading 생성자
  const UpdateProductLoading();
}

/// 상품 데이터 로딩 성공 상태
class UpdateProductLoaded extends UpdateProductState {
  /// UpdateProductLoaded 생성자
  ///
  /// [product]는 로딩된 상품 데이터입니다.
  /// [uploadedFileKeys]는 새로 업로드된 파일 키 목록입니다.
  const UpdateProductLoaded({
    required this.product,
    this.uploadedFileKeys = const [],
  });

  /// 로딩된 상품 데이터
  final pod.Product product;

  /// 새로 업로드된 파일 키 목록 (temp 경로)
  final List<String> uploadedFileKeys;
}

/// 이미지 업로드 중 상태
class UpdateProductUploading extends UpdateProductLoaded {
  /// UpdateProductUploading 생성자
  ///
  /// [product]는 로딩된 상품 데이터입니다.
  /// [uploadedFileKeys]는 업로드된 파일 키 목록입니다.
  /// [currentFileName]는 현재 업로드 중인 파일 이름입니다.
  const UpdateProductUploading({
    required super.product,
    required super.uploadedFileKeys,
    required this.currentFileName,
  });

  /// 현재 업로드 중인 파일 이름
  final String currentFileName;
}

/// 이미지 업로드 성공 상태
class UpdateProductUploadSuccess extends UpdateProductLoaded {
  /// UpdateProductUploadSuccess 생성자
  ///
  /// [product]는 로딩된 상품 데이터입니다.
  /// [uploadedFileKeys]는 업로드된 파일 키 목록입니다.
  const UpdateProductUploadSuccess({
    required super.product,
    required super.uploadedFileKeys,
  });
}

/// 이미지 업로드 실패 상태
class UpdateProductUploadError extends UpdateProductLoaded {
  /// UpdateProductUploadError 생성자
  ///
  /// [product]는 로딩된 상품 데이터입니다.
  /// [uploadedFileKeys]는 업로드된 파일 키 목록입니다.
  /// [error]는 업로드 실패 메시지입니다.
  const UpdateProductUploadError({
    required super.product,
    required super.uploadedFileKeys,
    required this.error,
  });

  /// 업로드 실패 메시지
  final String error;
}

/// 상품 데이터 로딩 실패 상태
class UpdateProductLoadError extends UpdateProductState {
  /// UpdateProductLoadError 생성자
  ///
  /// [error]는 로딩 실패 메시지입니다.
  const UpdateProductLoadError({required this.error});

  /// 로딩 실패 메시지
  final String error;
}

/// 상품 수정 중 상태
class UpdateProductUpdating extends UpdateProductLoaded {
  /// UpdateProductUpdating 생성자
  ///
  /// [product]는 로딩된 상품 데이터입니다.
  /// [uploadedFileKeys]는 업로드된 파일 키 목록입니다.
  const UpdateProductUpdating({
    required super.product,
    required super.uploadedFileKeys,
  });
}

/// 상품 수정 성공 상태
class UpdateProductUpdated extends UpdateProductLoaded {
  /// UpdateProductUpdated 생성자
  ///
  /// [product]는 수정된 상품 데이터입니다.
  /// [uploadedFileKeys]는 업로드된 파일 키 목록입니다.
  const UpdateProductUpdated({
    required super.product,
    required super.uploadedFileKeys,
  });
}

/// 상품 수정 실패 상태
class UpdateProductUpdateError extends UpdateProductLoaded {
  /// UpdateProductUpdateError 생성자
  ///
  /// [product]는 로딩된 상품 데이터입니다.
  /// [uploadedFileKeys]는 업로드된 파일 키 목록입니다.
  /// [error]는 수정 실패 메시지입니다.
  const UpdateProductUpdateError({
    required super.product,
    required super.uploadedFileKeys,
    required this.error,
  });

  /// 수정 실패 메시지
  final String error;
}
