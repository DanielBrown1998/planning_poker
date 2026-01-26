// home_viewmodel.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:planning_poker/presentation/commands/home_commands.dart';
import 'package:planning_poker/presentation/state/home_state.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/entities.dart';
import '../../domain/usecases/usecases.dart';

/// ViewModel for the Home screen
class HomeViewModel extends ChangeNotifier {
  final CreateSessionUseCase _createSessionUseCase;
  final JoinSessionUseCase _joinSessionUseCase;
  final Uuid _uuid;

  HomeState _state = const HomeInitial();

  HomeViewModel({
    required CreateSessionUseCase createSessionUseCase,
    required JoinSessionUseCase joinSessionUseCase,
    Uuid? uuid,
  }) : _createSessionUseCase = createSessionUseCase,
       _joinSessionUseCase = joinSessionUseCase,
       _uuid = uuid ?? const Uuid();

  // Expõe o estado
  HomeState get state => _state;

  // Getters de conveniência para a UI
  bool get isLoading => _state is HomeLoading;
  bool get hasError => _state is HomeError;
  String? get error =>
      _state is HomeError ? (_state as HomeError).message : null;
  bool get hasSuccess => _state is HomeSuccess;

  /// Retorna a sessão ativa (se houver)
  Session? get session =>
      _state is HomeSuccess ? (_state as HomeSuccess).session : null;

  /// Retorna o jogador atual (se houver)
  Player? get currentPlayer =>
      _state is HomeSuccess ? (_state as HomeSuccess).player : null;

  void clearError() {
    if (_state is HomeError) {
      _emit(const HomeInitial());
    }
  }

  void _emit(HomeState state) {
    _state = state;
    notifyListeners();
  }

  /// Creates a new session
  Future<bool> createSession({
    required String sessionName,
    required String playerName,
  }) async {
    _emit(const HomeLoading());

    try {
      final player = Player(id: _uuid.v4(), name: playerName, isHost: true);
      final result = await CreateSessionCommand(
        useCase: _createSessionUseCase,
        sessionName: sessionName,
        host: player,
      ).execute();

      if (result != null) {
        _emit(HomeSuccess(session: result, player: player));
        return true;
      } else {
        _emit(const HomeError('Falha ao criar sessão'));
        return false;
      }
    } catch (e) {
      _emit(HomeError(e.toString()));
      return false;
    }
  }

  /// Joins an existing session
  Future<bool> joinSession({
    required String sessionKey,
    required String playerName,
  }) async {
    _emit(const HomeLoading());

    try {
      final player = Player(id: _uuid.v4(), name: playerName, isHost: false);

      final result = await JoinSessionCommand(
        useCase: _joinSessionUseCase,
        sessionKey: sessionKey,
        player: player,
      ).execute();

      if (result != null) {
        _emit(HomeSuccess(session: result, player: player));
        return true;
      } else {
        _emit(const HomeError('Falha ao entrar na sessão'));
        return false;
      }
    } catch (e) {
      _emit(HomeError(e.toString()));
      return false;
    }
  }

  void reset() {
    _emit(const HomeInitial());
  }
}
