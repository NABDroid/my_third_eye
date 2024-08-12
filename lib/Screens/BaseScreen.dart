import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:keep_screen_on/keep_screen_on.dart';
import '../Global.dart';
import 'Styles.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';



class BaseScreen extends StatefulWidget {
  const BaseScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  late CameraController cameraController;
  late Future<void> initializeControllerFuture;
  XFile? image;
  late ChatSession chatSession;
  ValueNotifier<bool> rebuildBase = ValueNotifier<bool>(true);
  TextEditingController questionController = TextEditingController();
  String apiResponse = "Take a image to process";
  String? command = "";
  late FlutterTts flutterTts;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    cameraController = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    initializeControllerFuture = cameraController.initialize();
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: geminiKey,
    );
    chatSession = model.startChat();
    flutterTts = FlutterTts();
    initProcess();

  }


  Future<void> initProcess() async {
    await takeImage();
    initializeControllerFuture.then((_) {
      _timer = Timer.periodic(const Duration(seconds: 20), (Timer t) async {
        await takeImage();
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Center(
            child: Text(
              "Third Eye",
              style: appBarTextStyle,
            ),
          ),
        ),
        body: ValueListenableBuilder<bool>(
          valueListenable: rebuildBase,
          builder: (context, value, child) {
            return Card(
              color: Colors.black,
              surfaceTintColor: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            (image == null)
                                ? Container()
                                : SizedBox(
                                    height: 300,
                                    child: Image.file(File(image!.path))),
                            Text(
                              apiResponse!,
                              style: liteDetailsTextStyle,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: takeImage,
          child: const Icon(Icons.camera_alt),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    image = null;
    _timer?.cancel();
    KeepScreenOn.turnOff();
    super.dispose();
  }

  Future<void> takeImage() async {
    try {
      image = await cameraController.takePicture();
      final imageBytes = await image!.readAsBytes();
      Content multiContent = Content.multi(
          [TextPart("What's there?"), DataPart('image/jpeg', imageBytes)]);
      final geminiResponse = await chatSession
          .sendMessage(multiContent)
          .timeout(const Duration(seconds: 15));
      if (geminiResponse.text == null) {
        apiResponse = "No response from gemini, check your internet connection";
      } else {
        apiResponse = geminiResponse.text!;
        apiResponse = apiResponse.replaceAll("The image shows", "I'm seeing");
      }
      rebuildBase.value = !rebuildBase.value;
      await flutterTts.speak(apiResponse!);
    } catch (e) {
      print("=========================================================");
      print(e.toString());
      image = null;
    }
  }
}
