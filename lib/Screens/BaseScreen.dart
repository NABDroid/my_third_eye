import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:my_third_eye/Screens/HistoryScreen.dart';
import 'package:my_third_eye/Screens/SettingsScreen.dart';
import '../Global.dart';
import 'HomeScreen.dart';
import 'Styles.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  late CameraController cameraController;
  late Future<void> _initializeControllerFuture;
  XFile? image;
  late final ChatSession chatSession;
  ValueNotifier<bool> rebuildBase = ValueNotifier<bool>(true);

  String? apiResponse = "No data";
  int currentScreenId = 0;

  List<Widget> screens = <Widget>[
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    print(geminiKey);
    loadCameras();
    final model = GenerativeModel(
      model: 'gemini-ultra',
      apiKey: geminiKey,
    );
    chatSession = model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: themeColor,
          title: Text(
            "ThirdEye",
            style: appBarTextStyle,
          ),
        ),
        body: SingleChildScrollView(
            child: ValueListenableBuilder<bool>(
          valueListenable: rebuildBase,
          builder: (context, value, child) {
            return screens[currentScreenId];
          },
        )),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.camera_alt),
          onPressed: takeImage,
        ),
        bottomNavigationBar: ValueListenableBuilder<bool>(
          valueListenable: rebuildBase,
          builder: (context, value, child) {
            return BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.history), label: "History"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: "Settings"),
              ],
              currentIndex: currentScreenId,
              onTap: bottomNavBarTap,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    image = null;
    super.dispose();
  }

  void bottomNavBarTap(int index) {
    currentScreenId = index;
    rebuildBase.value = !rebuildBase.value;
  }

  loadCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = cameraController.initialize();
  }

  Future<void> takeImage() async {
    try {
      print("========================== Taking image ==========================");

      await _initializeControllerFuture;
      image = await cameraController.takePicture();
      final geminiResponse = await chatSession.sendMessage(
        Content.text("hey, gemini"),
      );
      if (geminiResponse.text == null) {
        apiResponse = "No response from api";
      } else {
        apiResponse = geminiResponse.text!;
      }
      print("================ geminiResponse.text");
      print(geminiResponse.text);
      // setState(() {});
    } catch (e) {
      print("Error =========");
      print(e);
    }
  }
}
