import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../Global.dart';
import 'Styles.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: geminiKey,
  );

  // static List<Widget> _widgetOptions = <Widget>[
  //   HomeScreen(),
  //   SearchScreen(),
  //   ProfileScreen(),
  // ];


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: themeColor,
          title: Text(
            "Chokh",
            style: appBarTextStyle,
          ),
        ),
        body: SingleChildScrollView(
            child: Container(
          color: Colors.amberAccent[100],
        )),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: "History"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }
}
