// Registers the portfolio feature dependencies in one explicit location.
import 'package:abdelrhman_protfolio/features/portfolio/data/datasources/portfolio_remote_data_source.dart';
import 'package:abdelrhman_protfolio/features/portfolio/data/datasources/portfolio_remote_data_source_impl.dart';
import 'package:abdelrhman_protfolio/features/portfolio/data/datasources/portfolio_storage_data_source.dart';
import 'package:abdelrhman_protfolio/features/portfolio/data/datasources/supabase_portfolio_storage_data_source.dart';
import 'package:abdelrhman_protfolio/features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/usecases/create_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/usecases/delete_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/usecases/get_project_by_id.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/usecases/get_projects.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/usecases/update_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/state/portfolio_view_model.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

final serviceLocator = GetIt.instance;

void configureDependencies() {
  serviceLocator
    ..registerLazySingleton (
      () => Dio(
        BaseOptions(
          baseUrl: 'https://pwnqxzvtoyjnuyjiucuo.supabase.co/functions/v1/',
          headers: const {'Content-Type': 'application/json'},
        ),
      )..interceptors.add(
          LogInterceptor(
            requestBody: true,
            responseBody: true,
            error: true,
            logPrint: (message) => print(message),
          ),
        ),
    )
    ..registerLazySingleton<PortfolioRemoteDataSource>(
      () => PortfolioRemoteDataSourceImpl(serviceLocator()),
    )
    ..registerLazySingleton<PortfolioStorageDataSource>(
      SupabasePortfolioStorageDataSource.new,
    )
    ..registerLazySingleton<PortfolioRepository>(
      () => PortfolioRepositoryImpl(serviceLocator(), serviceLocator()),
    )
    ..registerLazySingleton(() => GetProjects(serviceLocator()))
    ..registerLazySingleton(() => GetProjectById(serviceLocator()))
    ..registerLazySingleton(() => CreateProject(serviceLocator()))
    ..registerLazySingleton(() => UpdateProject(serviceLocator()))
    ..registerLazySingleton(() => DeleteProject(serviceLocator()))
    ..registerFactory(
      () => PortfolioViewModel(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      ),
    );
}
