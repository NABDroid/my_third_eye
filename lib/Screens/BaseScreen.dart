import 'dart:io';

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
  //late Future<void> _initializeControllerFuture;
  XFile? image;
  late ChatSession chatSession;
  ValueNotifier<bool> rebuildBase = ValueNotifier<bool>(true);
  TextEditingController questionController = TextEditingController();
  String? apiResponse = "Take a image to process";
  int currentScreenId = 0;
  //late final firstCamera;
  late final cameras;

  List<Widget> screens = <Widget>[
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    print("key-------------------------------- $geminiKey");
    loadCameras();
    final model = GenerativeModel(
      // model: 'gemini-ultra',
      model: 'gemini-1.5-flash',
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
        body: ValueListenableBuilder<bool>(
          valueListenable: rebuildBase,
          builder: (context, value, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    (image == null) ? Container() : Image.file(File(image!.path)),

                    Text(apiResponse!, style: darkDetailsTextStyle,),
                    SizedBox(height: 20,),
                    TextField(
                      controller: questionController,
                      style: darkDetailsTextStyle,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        hintText: "Type something...",
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // SingleChildScrollView(
        //     child: ValueListenableBuilder<bool>(
        //   valueListenable: rebuildBase,
        //   builder: (context, value, child) {
        //     return screens[currentScreenId];
        //   },
        // )),

        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.camera_alt),
          onPressed: takeImage,
        ),
        // bottomNavigationBar: ValueListenableBuilder<bool>(
        //   valueListenable: rebuildBase,
        //   builder: (context, value, child) {
        //     return BottomNavigationBar(
        //       items: const [
        //         BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        //         BottomNavigationBarItem(
        //             icon: Icon(Icons.history), label: "History"),
        //         BottomNavigationBarItem(
        //             icon: Icon(Icons.settings), label: "Settings"),
        //       ],
        //       currentIndex: currentScreenId,
        //       onTap: bottomNavBarTap,
        //     );
        //   },
        // ),
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
  }

  Future<void> takeImage() async {
    try {

      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
      );

      // _initializeControllerFuture = cameraController.initialize();
      //await _initializeControllerFuture;
      cameraController.initialize();


      String question = questionController.text.toString().trim();

      image = await cameraController.takePicture();
      cameraController.dispose();
      final geminiResponse = await chatSession.sendMessage(
        Content.text(question),
      );
      if (geminiResponse.text == null) {
        apiResponse = "No response from api";
      } else {
        apiResponse = geminiResponse.text!;
      }
      rebuildBase.value = !rebuildBase.value;
    } catch (e) {
      print("Error =========");
      print(e);
    }
  }

  Future<void> onlyStringQues() async {
    String question = questionController.text.toString().trim();
    try {
      final geminiResponse = await chatSession.sendMessage(
        Content.text(question),
      );
      if (geminiResponse.text == null) {
        apiResponse = "No response from api";
      } else {
        apiResponse = geminiResponse.text!;
      }
      rebuildBase.value = !rebuildBase.value;
    } catch (e) {
    }
  }
}
