import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:firebase_storage/firebase_storage.dart' ;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../main.dart';
import 'dentistlist.dart';


class PersonalData extends StatefulWidget {
  final List listOfImages;
  const PersonalData({super.key, required this.listOfImages});

  @override
  State<StatefulWidget> createState() =>_PersonalDataState();

}

class _PersonalDataState extends State<PersonalData>{
  double uploadProgress = 0.0;
  bool  visibility=false;

  @override
  Widget build(BuildContext context) {
    CollectionReference firestore = FirebaseFirestore.instance.collection('emergencias');
    TextEditingController nomeController = TextEditingController();
    TextEditingController telefoneController = TextEditingController();

    Future<void> addEmergencia(String nome, String telefone,
        String imageKidPath,String imageDocPath,String imageBothPath) async {
      try {
        DocumentReference documentRef = await firestore.add({
          'nome': nome,
          'telefone': telefone,
          'datahora': DateTime.now().toString(),
          'status': 'aberta',
          'fotoCrianca': imageKidPath,
          'fotoDoc':imageDocPath,
          'fotoAmbos':imageBothPath
        });

        String documentId = documentRef.id;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Emergência aberta!')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DentisList(documentId: documentId)),
        );
      } catch (e) {
        print('Error adding emergencia: $e');
      }
    }


    Future<void> addImagem(List listOfImages) async {
      final storage = FirebaseStorage.instance;

      try {
        List<String> imagePaths = [];
        for (int i = 0; i < listOfImages.length; i++) {
          File file = File(listOfImages[i]);

          String imageName = 'img-${DateTime.now().toString()}-$i.jpg';

          UploadTask uploadTask= storage.ref('emergencias') // ref é a pasta
              .child(imageName) // child é o nome da foto
              .putFile(file);

          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot){
            setState(() {
              uploadProgress = snapshot.bytesTransferred.toDouble() / snapshot.totalBytes.toDouble();
            });

          });


          await uploadTask;
          imagePaths.add('emergencias/$imageName');
        }

        await addEmergencia(
            nomeController.text, telefoneController.text,imagePaths[0],imagePaths[1],imagePaths[2]);
      } on FirebaseException catch (e) {
        throw Exception('Erro no upload:${e.code}');
      }
    }

    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 60.0),
        child:SingleChildScrollView(

          child: Column(
                children: [
                  Text("Documentos a enviar:"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                    widget.listOfImages.map((imagem) => Container(
                        margin: EdgeInsets.only(right: 5,bottom: 5,top:5),
                        width: 100,
                        child: Image.file(File(imagem)))).toList()
                    ,
                  ),
                  TextField(
                    controller: nomeController,
                    decoration: InputDecoration(
                        labelText: 'Nome do responsável',
                        border: OutlineInputBorder()
                    ),

                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    controller: telefoneController,
                    decoration: InputDecoration(
                        labelText: 'Telefone',
                        border: OutlineInputBorder()
                    ),

                  ),
            if(visibility) // Só irá aparecer a barra de progresso das imagens quando o botão for clicado
            Stack(
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                  child: LinearProgressIndicator(
                    value: uploadProgress,
                  ),
                ),
                // Posiciona o texto no centro do LinearProgressIndicator.
                Center(
                  child: Text(
                    'Enviando imagens ...',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

                  ElevatedButton(
                    onPressed: () {
                      addImagem(widget.listOfImages);
                      setState(() {
                        visibility=true;
                      });
                    },
                    child: Text("Solicitar emergência!"),
                  ),
                ],
              ),

        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(left:30),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: ElevatedButton(
            onPressed: (){
              Navigator.of(context).popAndPushNamed('/AuthPageRoute');
            },
            child: Text("Cancelar"),
          ),
        ),
      ),

    );
  }



}
