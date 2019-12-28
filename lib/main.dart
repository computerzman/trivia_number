import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'injection_container.dart' as di;
 
void main() async {
  // add the following line, and it should be the first line in main method
  WidgetsFlutterBinding.ensureInitialized(); /* To Fix the Error: Flutter: Unhandled Exception: ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized https://stackoverflow.com/questions/57689492/flutter-unhandled-exception-servicesbinding-defaultbinarymessenger-was-accesse */
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Trivia',
      home: NumberTriviaPage(),
      theme: ThemeData(
          primaryColor: Colors.green.shade800,
          accentColor: Colors.green.shade600
          ),
    );
  }
}
