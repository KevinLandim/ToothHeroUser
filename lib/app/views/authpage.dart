import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';

import 'package:flutter/material.dart';

import 'package:pictureflutter/app/views/firstpage.dart';
import 'package:pictureflutter/app/views/takepicturepagekid.dart';
import '../../main.dart';

import 'package:firebase_auth/firebase_auth.dart';



class AuthPage extends StatefulWidget {
  const AuthPage({super.key,required this.camera});
  final CameraDescription camera;

  @override
  _AuthPageState createState() => _AuthPageState(camera);

}

class _AuthPageState  extends State<AuthPage>{
  _AuthPageState(CameraDescription camera);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  _signInAnonymously() async {
    setState(() {
      _isLoading = true; // Iniciar carregamento.Faz o build renderizar novamente a tela pois um houve altereção no estado da pagina
    });
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      print("User signed in: ${userCredential.user}");

    } catch (e) {
      print("Error signing in: $e");
    }finally{
      if(mounted){ // se o usuário ainda estiver na AuthPage então pare o carregamento
        setState(() {
          _isLoading=false; //para o carregamento
        });
      }
    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
          child: _isLoading
              ? CircularProgressIndicator() // Mostre a barra de carregamento se _isLoading for true
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Olá,bem vindo ao tooth-hero"),
                  Text("Sobre a empresa...."),
                  ElevatedButton(
                    onPressed:(){
                      _signInAnonymously();
                      Navigator.push(
                          context as BuildContext,
                          MaterialPageRoute(builder:(context)=>
                              TakePictureScreenKid(camera:widget.camera)
                          //FirstPage(camera: widget.camera)

                          )
                      );
                    },
                    child:Text("Clique aqui para solicitar o socorro!"),
                  ),

                ],

          )

      ),
    );
  }
}