import  'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:ToothHero/app/views/takepicturepagedoc.dart';





class TakePictureScreenKid extends StatefulWidget {
  const TakePictureScreenKid({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenKidState createState() => TakePictureScreenKidState();
}

class TakePictureScreenKidState extends State<TakePictureScreenKid> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String? imagePath;
  List<String>  listOfImages=[];



  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  TakePhoto() async {
    if(imagePath!=null){//verifica se a foto já foi tirada,para não tirar foto sem preview
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content:Text("Para nova foto,clique em repetir foto!"))
      );
    }else {
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
            listOfImages!.add(image.path); //adiciona a foto tirada a lista
          });
        } catch (e) {
          print("Ocorreu um erro ao salvar imagem: ${e}");
        }
        if (!mounted) return;
      } catch (e) {
        print(e);
      }
    }
  }
  TextButton CreateButtons(String name, VoidCallback function,IconData icon){
    return TextButton(
        onPressed: function,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name,style:TextStyle(color:Colors.deepPurple)),
            Icon(icon,color:Colors.deepPurple),
          ],

        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        await ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content:Text("Você não pode voltar, apenas cancelar!")));
        return false;
      },
      child: Scaffold(

        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // se o future estiver completo, mostre preview
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding:EdgeInsets.all(10),
                      child: Text('Fotografe a boca/região acidentada da criança:',
                          textAlign: TextAlign.center, style:TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:25,
                          color: Colors.deepPurple
                      )
                      ),
                    ),

                    Container(
                        height: 300.0,
                        width: 200.0,
                        child: imagePath!= null
                        ?Image.file(File(imagePath!))
                        :CameraPreview(_controller)),
                    CreateButtons("Tirar foto",TakePhoto, Icons.camera_alt),//botão 1
                    CreateButtons("Repetir foto", () {
                      if(imagePath!=null){//O botão de repetir foto não faz nada se a tela estiver exibindo o preview
                      setState(() {
                        listOfImages.removeLast();
                      });}//botão 2
                      setState(() {
                        imagePath=null; //Botão de repetir foto, torna o imagePath nulo
                      });
                    }, Icons.refresh),
                    CreateButtons("Avançar", () {
                      if(imagePath!=null){
                      Navigator.push(
                        context as BuildContext,
                        MaterialPageRoute(builder:(context)=>TakePictureScreenDoc(camera:widget.camera,listOfImages:listOfImages)));
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
        floatingActionButton: Container(
          margin: EdgeInsets.only(left:30),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: ElevatedButton(
              onPressed: (){
                Navigator.of(context).popAndPushNamed('/AuthPageRoute');
                },
              style: ElevatedButton.styleFrom(backgroundColor:Colors.deepPurple),
              child: Text("Cancelar",style:TextStyle(color:Colors.white)),
            ),
          ),
        ),

      ),
    );
  }
}