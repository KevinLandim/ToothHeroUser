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



class DentisList extends StatefulWidget{

  final String documentId;

  const DentisList({super.key, required this.documentId});

  @override
  State<DentisList> createState() => _DentisListState();
}

class _DentisListState extends State<DentisList> {
  Future<void> updateStatus(String documentId) async {
    try {
      CollectionReference emergenciasCollection =
      FirebaseFirestore.instance.collection('emergencias');

      await emergenciasCollection.doc(documentId).update({
        'status': 'aceita',
      });

      print('Document status updated successfully.');
    } catch (e) {
      print('Error updating document status: $e');
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dentistas disponíveis')),
      body: Center(
          child: Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('atendimentos')
                  .where('status', isEqualTo: "Aceito")
                  .where('emergenciaId',isEqualTo:widget.documentId)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Algo deu errado');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    strokeWidth: 2.0,
                  );
                }

                // Verifica se há dados antes de acessar 'docs'
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  return ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map <String, dynamic> data = document.data() as Map<String, dynamic>;

                      return Container(
                        decoration: BoxDecoration(
                          border:Border.all(
                              color:Colors.blue,
                              width:2
                          ),
                        ),
                        child: ListTile(
                          subtitle: Text("Data que o dentista aceitou ${data['datahora'] ?? 'Data/Hora não disponível'}"),
                          title: Text("Nome do dentista: ${data['nome'] ?? 'Nome não disponível'}"),
                          trailing:IconButton(
                            icon: Icon(Icons.phone),
                            onPressed:(){
                              updateStatus(widget.documentId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Você aceitou este dentista. \n'
                                      'Ele te ligará em breve'),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                } else {
                  return Container(
                    margin: EdgeInsets.only(top:30.0),
                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 2.0,
                        ),
                        SizedBox(height: 16.0),
                        Text(
                            'Aguardando dentistas aceitarem'
                        )

                      ],
                    ),
                  );

                }
              },
            ),
          )
      ),


    );
  }
}