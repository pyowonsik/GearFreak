/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class GeneratePresignedUploadUrlRequestDto
    implements _i1.SerializableModel {
  GeneratePresignedUploadUrlRequestDto._({
    required this.fileName,
    required this.contentType,
    required this.fileSize,
    required this.bucketType,
    this.prefix,
  });

  factory GeneratePresignedUploadUrlRequestDto({
    required String fileName,
    required String contentType,
    required int fileSize,
    required String bucketType,
    String? prefix,
  }) = _GeneratePresignedUploadUrlRequestDtoImpl;

  factory GeneratePresignedUploadUrlRequestDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return GeneratePresignedUploadUrlRequestDto(
      fileName: jsonSerialization['fileName'] as String,
      contentType: jsonSerialization['contentType'] as String,
      fileSize: jsonSerialization['fileSize'] as int,
      bucketType: jsonSerialization['bucketType'] as String,
      prefix: jsonSerialization['prefix'] as String?,
    );
  }

  String fileName;

  String contentType;

  int fileSize;

  String bucketType;

  String? prefix;

  /// Returns a shallow copy of this [GeneratePresignedUploadUrlRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GeneratePresignedUploadUrlRequestDto copyWith({
    String? fileName,
    String? contentType,
    int? fileSize,
    String? bucketType,
    String? prefix,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'contentType': contentType,
      'fileSize': fileSize,
      'bucketType': bucketType,
      if (prefix != null) 'prefix': prefix,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GeneratePresignedUploadUrlRequestDtoImpl
    extends GeneratePresignedUploadUrlRequestDto {
  _GeneratePresignedUploadUrlRequestDtoImpl({
    required String fileName,
    required String contentType,
    required int fileSize,
    required String bucketType,
    String? prefix,
  }) : super._(
          fileName: fileName,
          contentType: contentType,
          fileSize: fileSize,
          bucketType: bucketType,
          prefix: prefix,
        );

  /// Returns a shallow copy of this [GeneratePresignedUploadUrlRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GeneratePresignedUploadUrlRequestDto copyWith({
    String? fileName,
    String? contentType,
    int? fileSize,
    String? bucketType,
    Object? prefix = _Undefined,
  }) {
    return GeneratePresignedUploadUrlRequestDto(
      fileName: fileName ?? this.fileName,
      contentType: contentType ?? this.contentType,
      fileSize: fileSize ?? this.fileSize,
      bucketType: bucketType ?? this.bucketType,
      prefix: prefix is String? ? prefix : this.prefix,
    );
  }
}
