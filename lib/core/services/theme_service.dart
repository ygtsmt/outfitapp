import "package:injectable/injectable.dart";
import "package:ginly/app/bloc/app_bloc.dart";
import "package:ginly/core/data_sources/local_data_source/secure_data_storage.dart";
import "package:ginly/core/injection/injection.dart";

@injectable
class ThemeService {
  Future<void> setSavedThemeMode() async {
    final savedThemeMode = await getIt<SecureDataStorage>().getThemeMode();
    getIt<AppBloc>().add(SetThemeEvent(savedThemeMode));
  }
}
