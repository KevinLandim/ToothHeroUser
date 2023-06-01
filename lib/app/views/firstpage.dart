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
import 'package:pictureflutter/app/views/takepicturepagekid.dart';
import 'package:pictureflutter/main.dart';
//import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'app/views/authpage.dart';



class FirstPage extends StatelessWidget {
  const FirstPage({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;



  @override
  Widget build(BuildContext context){

    return Scaffold(
        appBar: AppBar(
            title:Text('Home Page Socorrista')),
        body:Center(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  color: Colors.white,
                  shape:RoundedRectangleBorder(
                    borderRadius:BorderRadius.circular(15.0),
                    side: BorderSide(color:Colors.black,width:2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Text(
                          'Clique no botão abaixo \n para fotografar a boca da criança!',
                          style:TextStyle(
                              fontSize: 24,
                              color:Colors.blue

                          ),
                          textAlign:TextAlign.center,


                        ),
                        FloatingActionButton(
                          onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder:(context)=>TakePictureScreenKid(
                                    camera: camera) )
                            );
                          }, child: Icon(Icons.camera_alt),
                        )

                      ],
                    ),
                  ),
                ),


              ],
            )
        )


    );
  }



}