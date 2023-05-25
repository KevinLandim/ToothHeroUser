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


class DadosPessoais extends StatelessWidget {
  final String imagePath;
  const DadosPessoais({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    CollectionReference firestore = FirebaseFirestore.instance.collection('emergencias');
    TextEditingController nomeController = TextEditingController();
    TextEditingController telefoneController = TextEditingController();

    Future<void> addEmergencia(String nome, String telefone,
        String fullPath) async {
      try {
        DocumentReference documentRef = await firestore.add({
          'nome': nome,
          'telefone': telefone,
          'datahora': DateTime.now().toString(),
          'status': 'aberta',
          'fotos': fullPath,
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


    Future<void> addImagem(String path) async {
      final storage = FirebaseStorage.instance;
      File file = File(path);
      try {
        String nome = 'img-${DateTime.now().toString()}.jpg';
        await storage.ref('emergencias') //ref é a pasta
            .child(nome) //child é o nome da foto
            .putFile(file);

        await addEmergencia(
            nomeController.text, telefoneController.text, "emergencias/$nome");
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
              Container(
                  height: 300,
                  child: Image.file(File(imagePath))),
              ElevatedButton(
                onPressed: () {
                  addImagem(imagePath);
                },
                child: Text("Solicitar emergência!"),
              ),

            ],
          ),
        ),
      ),

    );
  }
}
