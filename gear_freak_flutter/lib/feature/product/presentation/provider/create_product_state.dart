/// 상품 등록 상태
sealed class CreateProductState {
  /// CreateProductState 생성자
  ///
  /// [uploadedFileKeys]는 업로드된 파일 키 목록입니다.
  const CreateProductState({required this.uploadedFileKeys});

  /// 업로드된 파일 키 목록
  final List<String> uploadedFileKeys;
}

/// 초기 상태
class CreateProductInitial extends CreateProductState {
  /// CreateProductInitial 생성자
  ///
  /// [uploadedFileKeys]는 업로드된 파일 키 목록입니다.
  const CreateProductInitial() : super(uploadedFileKeys: const []);
}

/// 업로드 중 상태
class CreateProductUploading extends CreateProductState {
  /// CreateProductUploading 생성자
  ///
  /// [uploadedFileKeys]는 업로드된 파일 키 목록입니다.
  /// [currentFileName]는 현재 업로드된 파일 이름입니다.
  const CreateProductUploading({
    required super.uploadedFileKeys,
    required this.currentFileName,
  });

  /// 현재 업로드된 파일 이름
  final String currentFileName;
}

/// 업로드 성공 상태
class CreateProductUploadSuccess extends CreateProductState {
  /// CreateProductUploadSuccess 생성자
  ///
  /// [uploadedFileKeys]는 업로드된 파일 키 목록입니다.
  const CreateProductUploadSuccess({required super.uploadedFileKeys});
}

/// 업로드 실패 상태
class CreateProductUploadError extends CreateProductState {
  /// CreateProductUploadError 생성자
  ///
  /// [uploadedFileKeys]는 업로드된 파일 키 목록입니다.
  /// [error]는 업로드 실패 메시지입니다.
  const CreateProductUploadError({
    required super.uploadedFileKeys,
    required this.error,
  });

  /// 업로드 실패 메시지
  final String error;
}

/// 상품 생성 중 상태
class CreateProductCreating extends CreateProductState {
  /// CreateProductCreating 생성자
  ///
  /// [uploadedFileKeys]는 업로드된 파일 키 목록입니다.
  const CreateProductCreating({required super.uploadedFileKeys});
}

/// 상품 생성 성공 상태
class CreateProductCreated extends CreateProductState {
  /// CreateProductCreated 생성자
  ///
  /// [uploadedFileKeys]는 업로드된 파일 키 목록입니다.
  const CreateProductCreated({required super.uploadedFileKeys});
}

/// 상품 생성 실패 상태
class CreateProductCreateError extends CreateProductState {
  /// CreateProductCreateError 생성자
  ///
  /// [uploadedFileKeys]는 업로드된 파일 키 목록입니다.
  /// [error]는 생성 실패 메시지입니다.
  const CreateProductCreateError({
    required super.uploadedFileKeys,
    required this.error,
  });

  /// 생성 실패 메시지
  final String error;
}
