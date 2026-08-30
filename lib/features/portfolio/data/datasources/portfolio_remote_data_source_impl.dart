// Calls public Edge Functions through Dio and maps their wrapped responses to data DTOs.
import 'package:abdelrhman_protfolio/features/portfolio/data/datasources/portfolio_remote_data_source.dart';
import 'package:abdelrhman_protfolio/features/portfolio/data/models/api_response_dto.dart';
import 'package:abdelrhman_protfolio/features/portfolio/data/models/portfolio_project_dto.dart';
import 'package:dio/dio.dart';

class PortfolioRemoteDataSourceImpl implements PortfolioRemoteDataSource {
  PortfolioRemoteDataSourceImpl(this._client);

  final Dio _client;

  @override
  Future<List<PortfolioProjectDto>> getProjects() async {
    final data = _unwrap(await _client.get<dynamic>('get_projects'));
    if (data is! List) {
      throw const FormatException('Projects response is invalid.');
    }
    return data
        .map((item) => PortfolioProjectDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PortfolioProjectDto> getProjectById(String id) async =>
      _projectFromResponse(
        await _client.get<dynamic>('get_project_by_id', queryParameters: {'id': id}),
      );

  @override
  Future<PortfolioProjectDto> createProject(Map<String, dynamic> payload) async =>
      _projectFromResponse(await _client.post<dynamic>('create_project', data: payload));

  @override
  Future<PortfolioProjectDto> updateProject(Map<String, dynamic> payload) async =>
      _projectFromResponse(await _client.post<dynamic>('update_project', data: payload));

  @override
  Future<void> deleteProject(String id) async {
    _unwrap(await _client.post<dynamic>('delete_project', data: {'id': id}));
  }

  PortfolioProjectDto _projectFromResponse(Response<dynamic> response) {
    final data = _unwrap(response);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Project response is invalid.');
    }
    return PortfolioProjectDto.fromJson(data);
  }

  Object? _unwrap(Response<dynamic> response) {
    final json = response.data as Map<String, dynamic>;
    final result = ApiResponseDto<Object?>.fromJson(json);
    if (!result.success) {
      throw Exception(result.message ?? 'The server rejected the request.');
    }
    return result.data;
  }
}
