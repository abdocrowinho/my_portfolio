// Converts portfolio intents into render-ready state through the domain use case.
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/entities/portfolio_project_draft.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/usecases/create_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/usecases/delete_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/usecases/get_project_by_id.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/usecases/get_projects.dart';
import 'package:abdelrhman_protfolio/features/portfolio/domain/usecases/update_project.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/state/portfolio_intent.dart';
import 'package:abdelrhman_protfolio/features/portfolio/presentation/state/portfolio_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';

class PortfolioViewModel extends Cubit<PortfolioState> {
  PortfolioViewModel(
    this._getProjects,
    this._getProjectById,
    this._createProject,
    this._updateProject,
    this._deleteProject,
  ) : super(const PortfolioInitial());

  final GetProjects _getProjects;
  final GetProjectById _getProjectById;
  final CreateProject _createProject;
  final UpdateProject _updateProject;
  final DeleteProject _deleteProject;

  Future<void> handle(PortfolioIntent intent) async {
    if (intent is LoadProjects) await _loadProjects();
  }

  Future<void> _loadProjects() async {
    emit(const PortfolioLoading());
    try {
      final projects = await _getProjects();
      emit(
        projects.isEmpty ? const PortfolioEmpty() : PortfolioLoaded(projects),
      );
    } catch (_) {
      emit(const PortfolioError('Unable to load projects right now.'));
    }
  }

  Future<PortfolioProject?> getProjectById(String id) =>
      _runProjectOperation(() => _getProjectById(id));

  Future<PortfolioProject?> createProject(PortfolioProjectDraft draft) =>
      _runProjectOperation(() => _createProject(draft));

  Future<PortfolioProject?> updateProject(
    PortfolioProject project,
    PortfolioProjectDraft draft, {
    required List<String> retainedImageUrls,
    required bool retainVideo,
  }) => _runProjectOperation(
    () => _updateProject(
      project,
      draft,
      retainedImageUrls: retainedImageUrls,
      retainVideo: retainVideo,
    ),
  );

  Future<bool> deleteProject(PortfolioProject project) async {
    try {
      await _deleteProject(project);
      await _loadProjects();
      return true;
    } catch (_) {
      emit(const PortfolioError('Unable to delete this project right now.'));
      return false;
    }
  }

  Future<PortfolioProject?> _runProjectOperation(
    Future<PortfolioProject> Function() operation,
  ) async {
    try {
      final project = await operation();
      await _loadProjects();
      return project;
    } catch (error, stackTrace) {
      log('Portfolio save failed before the Edge Function completed.', error: error, stackTrace: stackTrace);
      emit(PortfolioError('Unable to save project: $error'));
      return null;
    }
  }
}
