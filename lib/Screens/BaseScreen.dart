import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../Global.dart';
import 'Styles.dart';

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

  @override
  void initState() {
    super.initState();

    // cameraController = CameraController(
    //   widget.camera,
    //   ResolutionPreset.medium,
    // );
    // initializeControllerFuture = cameraController.initialize();
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
                              : Image.file(File(image!.path)),
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
      cameraController = await CameraController(
        widget.camera,
        ResolutionPreset.medium,
      );
      await (cameraController.initialize());

      image = await cameraController.takePicture();
      String question = questionController.text.toString().trim();

      image = await cameraController.takePicture();
      final imageBytes = await image!.readAsBytes();
      Content multiContent = Content.multi([TextPart(question), DataPart('image/jpeg', imageBytes)]);
      final geminiResponse = await chatSession
          .sendMessage(multiContent)
          .timeout(const Duration(seconds: 15));
      if (geminiResponse.text == null) {
        apiResponse = "No response from api";
      } else {
        apiResponse = geminiResponse.text!;
      }
      rebuildBase.value = !rebuildBase.value;
      cameraController.dispose();
    } catch (e) {
      cameraController.dispose();
      image = null;
      print("Error =========");
      print(e);
    }
  }
}
