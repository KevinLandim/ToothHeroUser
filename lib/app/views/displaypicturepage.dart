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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:pictureflutter/app/views/personaldata.dart';
import 'package:pictureflutter/app/views/takepicturepagekid.dart';
import 'package:pictureflutter/main.dart';




class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final CameraDescription camera;

  const DisplayPictureScreen({super.key, required this.imagePath,required this.camera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Display the Picture')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body:SingleChildScrollView(
            child:Column(
              children: [
                Container(
                    height:450,
                    padding: EdgeInsets.only(top:10),
                    alignment: Alignment.center,
                    child: Image.file(File(imagePath))),
                Text(
                    'Clique para repetir a foto',
                    style:TextStyle(
                        fontSize:20
                    )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder:(context)=>TakePictureScreenKid(
                                camera:camera ) )
                        );
                      }, child: Icon(Icons.camera_alt),
                    ),
                    FloatingActionButton(
                      onPressed: (){
                        /*Navigator.push(
                            context,
                            MaterialPageRoute(builder:(context)=>PersonalData(,

                            ) )
                        );*/
                      }, child: Icon(Icons.navigate_next),
                    )

                  ],
                )

              ],
            )
        )
    );
  }
}