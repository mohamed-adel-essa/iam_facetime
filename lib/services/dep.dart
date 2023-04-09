import 'package:face/db/db_services.dart';
import 'package:face/services/camera_services.dart';
import 'package:face/services/face_net_services.dart';
import 'package:face/services/ml_kit_services.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;
void setupDepInJ() {
  getIt.registerSingleton<DataBaseService>(DataBaseService(),
      signalsReady: false);

  getIt.registerSingletonAsync<FaceNetService>(() => FaceNetService.init(),
      signalsReady: false);
  getIt.registerSingleton<CameraService>(CameraService(), signalsReady: false);
  getIt.registerSingleton<MLKitService>(MLKitService(), signalsReady: false);
}
