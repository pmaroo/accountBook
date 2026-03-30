import 'app_persisted_state.dart';

abstract class AppStorageBase {
  Future<AppPersistedState?> load();

  Future<void> save(AppPersistedState state);

  Future<void> clear();
}
