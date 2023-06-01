import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:firebase_storage/firebase_storage.dart' ;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pictureflutter/app/views/personaldata.dart';
import 'package:pictureflutter/app/views/takepicturepagedoc.dart';
import 'package:pictureflutter/main.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'displaypicturepage.dart';




class TakePictureScreenBoth extends StatefulWidget {
  const TakePictureScreenBoth({
    super.key,
    required this.camera,
    required this.listOfImages
  });

  final CameraDescription camera;
  final List listOfImages;

  @override
  TakePictureScreenBothState createState() => TakePictureScreenBothState();
}

class TakePictureScreenBothState extends State<TakePictureScreenBoth> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String? imagePath;



  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }
  TakePhoto() async {
    // Tira a foto em um bloco try/catch. Se algo der errado,o erro é pego.
    try {
      // Certifique que a câmera foi inicializada.
      await _initializeControllerFuture;
      //  tentativa de tirar a foto e pegar o arquivo 'image' onde ele foi salvo
      final image = await _controller.takePicture();
      try {
        final savedImage = await ImageGallerySaver.saveFile(image.path);
        setState(() {
          imagePath = image.path; // Atualiza o ImagePath com nova imagem

        });
        setState(() {
          widget.listOfImages.add(image.path);
        });
      } catch(e){
        print("Ocorreu um erro ao salvar imagem: ${e}");
      }
      if (!mounted) return;
    } catch (e) {
      print(e);
    }
  }
  TextButton CreateButtons(String name, VoidCallback function,IconData icon){
    return TextButton(
        onPressed: function,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name),
            Icon(icon),
          ],

        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Foto do responsável com a criança:'),
                  Container(
                      height: 300.0,
                      child: imagePath!= null
                          ?Image.file(File(imagePath!))
                          :CameraPreview(_controller)),
                  CreateButtons("Tirar foto",TakePhoto, Icons.camera_alt),//botão 1
                  CreateButtons("Repetir foto", () {                      //botão 2
                    setState(() {
                      imagePath=null; //Botão de repetir foto, torna o imagePath nulo
                    });
                  }, Icons.refresh),
                  CreateButtons("Avançar", () {
                    if(imagePath!=null){
                      Navigator.push(
                          context as BuildContext,
                          MaterialPageRoute(builder:(context)=>PersonalData(listOfImages:widget.listOfImages)));
                    }else{ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:Text("Tire a foto antes de prosseguir")
                        )
                    );}
                  }, Icons.double_arrow_sharp) //botão 3

                ],
              ),

            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),

    );
  }
}