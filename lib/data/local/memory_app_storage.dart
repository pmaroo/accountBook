import 'app_persisted_state.dart';
import 'app_storage_base.dart';

class MemoryAppStorage implements AppStorageBase {
  AppPersistedState? _state;

  @override
  Future<void> clear() async {
    _state = null;
  }

  @override
  Future<AppPersistedState?> load() async {
    return _state;
  }

  @override
  Future<void> save(AppPersistedState state) async {
    _state = state;
  }
}
