import 'package:outfitter/services/navigation_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  // locator.registerSingleton<FirebaseAuthService>(FirebaseAuthService());
  // locator.registerFactory<LoginService>(() => LoginService());
}
