/// 상품 등록 상태
sealed class CreateProductState {
  final List<String> uploadedFileKeys;

  const CreateProductState({required this.uploadedFileKeys});
}

/// 초기 상태
class CreateProductInitial extends CreateProductState {
  const CreateProductInitial() : super(uploadedFileKeys: const []);
}

/// 업로드 중 상태
class CreateProductUploading extends CreateProductState {
  final String currentFileName;

  const CreateProductUploading({
    required super.uploadedFileKeys,
    required this.currentFileName,
  });
}

/// 업로드 성공 상태
class CreateProductUploadSuccess extends CreateProductState {
  const CreateProductUploadSuccess({required super.uploadedFileKeys});
}

/// 업로드 실패 상태
class CreateProductUploadError extends CreateProductState {
  final String error;

  const CreateProductUploadError({
    required super.uploadedFileKeys,
    required this.error,
  });
}


