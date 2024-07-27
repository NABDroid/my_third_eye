import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'Screens/BaseScreen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameraLists = await availableCameras();
  final firstCamera = cameraLists.first;
  runApp(AppRoot(camera: firstCamera,));
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key, required this.camera});
  final CameraDescription camera;



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BaseScreen(camera: camera,),
    );
  }
}