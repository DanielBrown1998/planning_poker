import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../data/datasources/firebase_session_datasource.dart';
import '../../data/repositories/firebase_session_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/usecases/usecases.dart';
import '../../presentation/viewmodels/viewmodels.dart';

/// Dependency injection configuration
class DependencyInjection {
  static List<SingleChildWidget> getProviders() {
    // Data sources
    final firebaseDataSource = FirebaseSessionDataSource();

    // Repositories
    final SessionRepository sessionRepository = FirebaseSessionRepository(
      dataSource: firebaseDataSource,
    );

    // Use cases
    final createSessionUseCase = CreateSessionUseCase(sessionRepository);
    final joinSessionUseCase = JoinSessionUseCase(sessionRepository);
    final playCardUseCase = PlayCardUseCase(sessionRepository);
    final revealCardsUseCase = RevealCardsUseCase(sessionRepository);
    final resetRoundUseCase = ResetRoundUseCase(sessionRepository);
    final watchSessionUseCase = WatchSessionUseCase(sessionRepository);
    final leaveSessionUseCase = LeaveSessionUseCase(sessionRepository);

    return [
      // ViewModels
      ChangeNotifierProvider<HomeViewModel>(
        create: (_) => HomeViewModel(
          createSessionUseCase: createSessionUseCase,
          joinSessionUseCase: joinSessionUseCase,
        ),
      ),
      ChangeNotifierProvider<GameViewModel>(
        create: (_) => GameViewModel(
          watchSessionUseCase: watchSessionUseCase,
          playCardUseCase: playCardUseCase,
          revealCardsUseCase: revealCardsUseCase,
          resetRoundUseCase: resetRoundUseCase,
          leaveSessionUseCase: leaveSessionUseCase,
        ),
      ),
    ];
  }
}
