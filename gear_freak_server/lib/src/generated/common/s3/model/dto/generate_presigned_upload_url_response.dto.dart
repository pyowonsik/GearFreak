/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class GeneratePresignedUploadUrlResponseDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  GeneratePresignedUploadUrlResponseDto._({
    required this.presignedUrl,
    required this.fileKey,
    required this.expiresIn,
  });

  factory GeneratePresignedUploadUrlResponseDto({
    required String presignedUrl,
    required String fileKey,
    required int expiresIn,
  }) = _GeneratePresignedUploadUrlResponseDtoImpl;

  factory GeneratePresignedUploadUrlResponseDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return GeneratePresignedUploadUrlResponseDto(
      presignedUrl: jsonSerialization['presignedUrl'] as String,
      fileKey: jsonSerialization['fileKey'] as String,
      expiresIn: jsonSerialization['expiresIn'] as int,
    );
  }

  String presignedUrl;

  String fileKey;

  int expiresIn;

  /// Returns a shallow copy of this [GeneratePresignedUploadUrlResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GeneratePresignedUploadUrlResponseDto copyWith({
    String? presignedUrl,
    String? fileKey,
    int? expiresIn,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'presignedUrl': presignedUrl,
      'fileKey': fileKey,
      'expiresIn': expiresIn,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'presignedUrl': presignedUrl,
      'fileKey': fileKey,
      'expiresIn': expiresIn,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _GeneratePresignedUploadUrlResponseDtoImpl
    extends GeneratePresignedUploadUrlResponseDto {
  _GeneratePresignedUploadUrlResponseDtoImpl({
    required String presignedUrl,
    required String fileKey,
    required int expiresIn,
  }) : super._(
          presignedUrl: presignedUrl,
          fileKey: fileKey,
          expiresIn: expiresIn,
        );

  /// Returns a shallow copy of this [GeneratePresignedUploadUrlResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GeneratePresignedUploadUrlResponseDto copyWith({
    String? presignedUrl,
    String? fileKey,
    int? expiresIn,
  }) {
    return GeneratePresignedUploadUrlResponseDto(
      presignedUrl: presignedUrl ?? this.presignedUrl,
      fileKey: fileKey ?? this.fileKey,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }
}
