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

import 'maps.dart';



class DentisList extends StatefulWidget{

  final String documentId;
  final String telefone;

  const DentisList({super.key, required this.documentId, required this.telefone});

  @override
  State<DentisList> createState() => _DentisListState();
}

class _DentisListState extends State<DentisList> {
  Future<void> updateStatus(String documentId) async {
    try {
      CollectionReference emergenciasCollection =
      FirebaseFirestore.instance.collection('emergencias');

      await emergenciasCollection.doc(documentId).update({
        'status': 'fechada',
      });

      print('Documento atualizado.');
    } catch (e) {
      print('Erro ao atualizar status do documento:$e');
    }
  }
  Future<void>updateStatusCancel(String documentId) async{
    try {
      CollectionReference emergenciasCollection =
          FirebaseFirestore.instance.collection('emergencias');
          await emergenciasCollection.doc(documentId).update({'status':'cancelada'});
    }catch(e){
      print('Erro ao atualizar status do documento:$e');

    }
  }
  Future<void>SendCallNotification(String emergenciaId, String profissionalId) async{
    try {

      CollectionReference callCollection= FirebaseFirestore.instance.collection('ligação');

      DocumentReference DocRef= await callCollection.add({
        "emergenciaId": emergenciaId,
        'profissionalId':profissionalId,
        'telefoneSocorrista':widget.telefone
      });
    }catch(e){
      print('Erro ao atualizar status do documento:$e');

    }
  }






  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:()async{
        await ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content:Text("Você não pode retroceder,apenas cancelar!"))
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Dentistas disponíveis')),
        body: Center(
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
                                trailing:ElevatedButton(
                                  child:Text("Escolher"),
                                  //icon: Icon(Icons.phone),
                                  onPressed:(){
                                    updateStatus(widget.documentId);
                                    SendCallNotification(data['emergenciaId'],data['profissionalId']);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Você aceitou este dentista. \n'
                                            'Ele te ligará em breve'),
                                      ),
                                    );
                                    Navigator.push(context,MaterialPageRoute(builder: (context)=>MapPage()));
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

            ),


        floatingActionButton: Container(
          margin: EdgeInsets.only(left:30),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: ElevatedButton(
              onPressed: (){
                Navigator.of(context).popAndPushNamed('/AuthPageRoute');
                updateStatusCancel(widget.documentId);
              },
              child: Text("Cancelar"),
            ),
          ),
        ),


      ),
    );
  }
}