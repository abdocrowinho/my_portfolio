// Decodes the common success and data wrapper returned by portfolio Edge Functions.
class ApiResponseDto<T> {
  const ApiResponseDto({required this.success, this.data, this.message});

  factory ApiResponseDto.fromJson(Map<String, dynamic> json) => ApiResponseDto(
    success: json['success'] as bool? ?? false,
    data: json['data'] as T?,
    message: json['message'] as String? ?? json['error'] as String?,
  );

  final bool success;
  final T? data;
  final String? message;
}
