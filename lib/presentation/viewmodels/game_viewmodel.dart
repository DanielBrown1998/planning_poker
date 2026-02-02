import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:planning_poker/presentation/commands/game_commands.dart';

import '../../core/constants/poker_cards.dart';
import '../../domain/entities/entities.dart';
import '../../domain/usecases/usecases.dart';

/// ViewModel for the Game screen
class GameViewModel extends ChangeNotifier {
  final WatchSessionUseCase _watchSessionUseCase;
  final PlayCardUseCase _playCardUseCase;
  final RevealCardsUseCase _revealCardsUseCase;
  final ResetRoundUseCase _resetRoundUseCase;
  final LeaveSessionUseCase _leaveSessionUseCase;

  StreamSubscription<Session?>? _sessionSubscription;

  Session? _session;
  Player? _currentPlayer;
  String? _selectedCard;
  String? _error;

  GameViewModel({
    required WatchSessionUseCase watchSessionUseCase,
    required PlayCardUseCase playCardUseCase,
    required RevealCardsUseCase revealCardsUseCase,
    required ResetRoundUseCase resetRoundUseCase,
    required LeaveSessionUseCase leaveSessionUseCase,
  }) : _watchSessionUseCase = watchSessionUseCase,
       _playCardUseCase = playCardUseCase,
       _revealCardsUseCase = revealCardsUseCase,
       _resetRoundUseCase = resetRoundUseCase,
       _leaveSessionUseCase = leaveSessionUseCase;

  // Getters
  Session? get session => _session;
  Player? get currentPlayer => _currentPlayer;
  String? get selectedCard => _selectedCard;
  String? get error => _error;
  bool get hasError => _error != null;

  List<String> get availableCards => PokerCards.values;

  bool get isHost => _currentPlayer?.id == _session?.hostId;

  bool get isRevealed => _session?.state == GameState.revealed;

  bool get canReveal => _session?.canReveal ?? false;

  bool get allPlayersVoted => _session?.allPlayersVoted ?? false;

  String? get myPlayedCard {
    if (_currentPlayer == null || _session == null) return null;
    return _session!.playedCards[_currentPlayer!.id]?.cardValue;
  }

  List<Player> get players => _session?.players ?? [];

  Map<String, PlayedCard> get playedCards => _session?.playedCards ?? {};

  /// Stream of session updates
  Stream<Session?> get sessionStream =>
      _watchSessionUseCase.execute(_session?.id ?? '');

  /// Initializes the view model with session and player data
  void initialize(Session session, Player player) {
    debugPrint(
      '🚀 initialize chamado - session: ${session.id}, player: ${player.id}',
    );
    _session = session;
    _currentPlayer = player;
    _startWatchingSession();
    notifyListeners();
  }

  void _startWatchingSession() {
    debugPrint('👂 _startWatchingSession chamado - session: ${_session?.id}');
    if (_session == null) return;

    _sessionSubscription?.cancel();
    debugPrint('🔌 Iniciando listener do stream para session: ${_session!.id}');
    _sessionSubscription = _watchSessionUseCase
        .execute(_session!.id)
        .listen(
          (session) {
            debugPrint(
              '📡 Stream recebeu update - playedCards: ${session?.playedCards.keys.toList()}',
            );
            if (session == null) {
              // Session was deleted
              _session = null;
              _error = 'A sessão foi encerrada';
              notifyListeners();
              return;
            }
            _session = session;

            // Update selected card if it matches what was played
            final myCard = session.playedCards[_currentPlayer?.id];
            if (myCard != null) {
              _selectedCard = myCard.cardValue;
            }

            notifyListeners();
          },
          onError: (error) {
            debugPrint('❌ Stream ERROR: $error');
            _error = error.toString();
            notifyListeners();
          },
          onDone: () {
            debugPrint('🏁 Stream DONE/CLOSED');
          },
        );
  }

  /// Selects a card (but doesn't play it yet)
  void selectCard(String card) {
    debugPrint('🎴 selectCard chamado: $card');
    _selectedCard = card;
    notifyListeners();

    // Automatically play the card when selected
    playSelectedCard();
  }

  /// Plays the selected card
  Future<void> playSelectedCard() async {
    debugPrint(
      '🃏 playSelectedCard chamado - card: $_selectedCard, session: ${_session?.id}, player: ${_currentPlayer?.id}',
    );
    if (_selectedCard == null || _session == null || _currentPlayer == null) {
      debugPrint('❌ playSelectedCard retornou cedo - dados nulos');
      return;
    }

    final command = PlayCardCommand(
      useCase: _playCardUseCase,
      sessionId: _session!.id,
      playerId: _currentPlayer!.id,
      playerName: _currentPlayer!.name,
      cardValue: _selectedCard!,
    );

    await command.execute();
    debugPrint(
      '✅ playCard executado - hasError: ${command.hasError}, error: ${command.error}',
    );

    // O Command já gerencia loading/error internamente
    if (command.hasError) {
      _error = command.error;
    }
    notifyListeners();
  }

  /// Reveals all cards (host only)
  Future<void> revealCards() async {
    if (_session == null || !isHost) return;

    final command = RevealCardsCommand(
      useCase: _revealCardsUseCase,
      sessionId: _session!.id,
    );

    await command.execute();

    if (command.hasError) {
      _error = command.error;
    }
    notifyListeners();
  }

  /// Resets the round (host only)
  Future<void> resetRound() async {
    if (_session == null || !isHost) return;

    final command = ResetRoundCommand(
      useCase: _resetRoundUseCase,
      sessionId: _session!.id,
    );
    await command.execute();

    if (command.hasError) {
      _error = command.error;
    }
    notifyListeners();
  }

  /// Leaves the session
  Future<void> leaveSession() async {
    if (_session == null || _currentPlayer == null) return;

    final command = LeaveSessionCommand(
      useCase: _leaveSessionUseCase,
      sessionId: _session!.id,
      playerId: _currentPlayer!.id,
    );

    await command.execute();
    if (command.hasError) {
      _error = command.error;
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }
}
