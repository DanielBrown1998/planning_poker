import 'dart:async';
import 'package:flutter/foundation.dart';

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
  bool _isLoading = false;
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
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  List<String> get availableCards => PokerCards.values;

  bool get isHost => _currentPlayer?.id == _session?.hostId;

  bool get isRevealed => _session?.state == SessionState.revealed;

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
    _session = session;
    _currentPlayer = player;
    _startWatchingSession();
    notifyListeners();
  }

  void _startWatchingSession() {
    if (_session == null) return;

    _sessionSubscription?.cancel();
    _sessionSubscription = _watchSessionUseCase
        .execute(_session!.id)
        .listen(
          (session) {
            if (session == null) {
              // Session was deleted
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
            _error = error.toString();
            notifyListeners();
          },
        );
  }

  /// Selects a card (but doesn't play it yet)
  void selectCard(String card) {
    _selectedCard = card;
    notifyListeners();

    // Automatically play the card when selected
    playSelectedCard();
  }

  /// Plays the selected card
  Future<void> playSelectedCard() async {
    if (_selectedCard == null || _session == null || _currentPlayer == null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    final result = await _playCardUseCase.execute(
      sessionId: _session!.id,
      playerId: _currentPlayer!.id,
      playerName: _currentPlayer!.name,
      cardValue: _selectedCard!,
    );

    result.when(
      success: (_) {
        _isLoading = false;
        notifyListeners();
      },
      failure: (message) {
        _error = message;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Reveals all cards (host only)
  Future<void> revealCards() async {
    if (_session == null || !isHost) return;

    _isLoading = true;
    notifyListeners();

    final result = await _revealCardsUseCase.execute(_session!.id);

    result.when(
      success: (_) {
        _isLoading = false;
        notifyListeners();
      },
      failure: (message) {
        _error = message;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Resets the round (host only)
  Future<void> resetRound() async {
    if (_session == null || !isHost) return;

    _isLoading = true;
    _selectedCard = null;
    notifyListeners();

    final result = await _resetRoundUseCase.execute(_session!.id);

    result.when(
      success: (_) {
        _isLoading = false;
        notifyListeners();
      },
      failure: (message) {
        _error = message;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Leaves the session
  Future<void> leaveSession() async {
    if (_session == null || _currentPlayer == null) return;

    _isLoading = true;
    notifyListeners();

    final result = await _leaveSessionUseCase.execute(
      sessionId: _session!.id,
      playerId: _currentPlayer!.id,
    );

    result.when(
      success: (_) {
        _sessionSubscription?.cancel();
        _session = null;
        _currentPlayer = null;
        _selectedCard = null;
        _isLoading = false;
        notifyListeners();
      },
      failure: (message) {
        _error = message;
        _isLoading = false;
        notifyListeners();
      },
    );
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
