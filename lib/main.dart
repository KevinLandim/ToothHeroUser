import 'dart:async';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pictureflutter/app/views/ratingpage.dart';
import 'app/views/maps.dart';
import 'firebase_options.dart';
import 'app/views/authpage.dart';
import 'package:permission_handler/permission_handler.dart';






Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras[0];
   await Firebase.initializeApp(
      options:DefaultFirebaseOptions.currentPlatform);



  runApp(
    MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.blue,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blue
      ),
        elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  backgroundColor:MaterialStateProperty.all<Color>(Colors.blue)
              )
        )),
      initialRoute:'/AuthPageRoute' ,
      routes: {
        '/AuthPageRoute':(context)=>AuthPage(camera:firstCamera)
      },
    ),
  );
}




