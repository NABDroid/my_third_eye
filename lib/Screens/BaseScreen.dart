import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../Global.dart';
import 'Styles.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


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
  // image related
  late CameraController cameraController;
  late Future<void> initializeControllerFuture;
  XFile? image;

  // chat related
  late ChatSession chatSession;
  ValueNotifier<bool> rebuildBase = ValueNotifier<bool>(true);
  TextEditingController questionController = TextEditingController();
  String? apiResponse = "Take a image to process";
  String? command = "";


  // Speak related
  late FlutterTts flutterTts;

  // Speech recognition related
  late stt.SpeechToText speech;
  bool isListening = false;


  @override
  void initState() {
    super.initState();

    cameraController = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    initializeControllerFuture = cameraController.initialize();
    final model = GenerativeModel(
      // model: 'gemini-ultra',
      model: 'gemini-1.5-flash',
      apiKey: geminiKey,
    );
    chatSession = model.startChat();
    initTts();
    initSpeech();
  }


  dynamic initTts() {
    flutterTts = FlutterTts();}

  void initSpeech() async {
    speech = stt.SpeechToText();
    bool available = await speech.initialize();
    if (available) {
      print("initSpeech true");
      startListening();
    } else {
      // Handle the error here
    }
  }

  void startListening() {
    speech.listen(
      onResult: (result) {
        command = result.recognizedWords;
        rebuildBase.value = !rebuildBase.value;
        if (result.recognizedWords.toLowerCase().contains("Hello")) {
          takeImage();
        }
      },
    );
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
            return Padding(
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
                              : SizedBox(height: 300,child: Image.file(File(image!.path))),
                          Text(
                            apiResponse!,
                            style: darkDetailsTextStyle,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text((command == null)?" ":command!),

                ],
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
    super.dispose();
  }

  Future<void> takeImage() async {
    try {
      // cameraController = CameraController(
      //   widget.camera,
      //   ResolutionPreset.medium,
      // );
      // await (cameraController.initialize());

      image = await cameraController.takePicture();
      // String question = questionController.text.toString().trim();
      image = await cameraController.takePicture();
      final imageBytes = await image!.readAsBytes();
      Content multiContent = Content.multi([TextPart("What's there?"), DataPart('image/jpeg', imageBytes)]);
      final geminiResponse = await chatSession
          .sendMessage(multiContent)
          .timeout(const Duration(seconds: 15));
      if (geminiResponse.text == null) {
        apiResponse = "No response from api";
      } else {
        apiResponse = geminiResponse.text!;
        await flutterTts.speak(apiResponse!);
      }
      rebuildBase.value = !rebuildBase.value;
      // cameraController.dispose();
    } catch (e) {
      // cameraController.dispose();
      image = null;

    }
  }
}
