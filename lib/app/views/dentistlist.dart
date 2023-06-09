import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'maps.dart';
import 'dart:math';



class DentisList extends StatefulWidget{

  final String idDocEmergencia;
  final double latSocorrista;
  final double longSocorrista;
  static String profissionalId='';


  const DentisList({super.key, required this.idDocEmergencia,required this.latSocorrista,required this.longSocorrista});

  @override
  State<DentisList> createState() => _DentisListState();
}

class _DentisListState extends State<DentisList> {



  Future<void> emergenciaFechadaUpdate(String documentId) async {//executada quando o socorrista escolhe o dentista
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
  Future<void>emergenciaCanceladaUpdate(String documentId) async{
    try {
      CollectionReference emergenciasCollection =
          FirebaseFirestore.instance.collection('emergencias');
          await emergenciasCollection.doc(documentId).update({'status':'cancelada'});
    }catch(e){
      print('Erro ao atualizar status do documento:$e');

    }
  }
  Future<void>SendCallNotification (String idDocAtendimento) async{
    try {
      CollectionReference atendimentosCollection = FirebaseFirestore.instance.collection('atendimentos');
      atendimentosCollection.doc(idDocAtendimento).update({'status':'em andamento'});


    }catch(e){
      print('Erro ao atualizar status do documento:$e');

    }

  }
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Raio da Terra em quilômetros
    var lat1Rad = _degreesToRadians(lat1);
    var lat2Rad = _degreesToRadians(lat2);
    var deltaLat = _degreesToRadians(lat2 - lat1);
    var deltaLon = _degreesToRadians(lon2 - lon1);

    var a = sin(deltaLat/2) * sin(deltaLat/2) +
        cos(lat1Rad) * cos(lat2Rad) *
            sin(deltaLon/2) * sin(deltaLon/2);

    var c = 2 * atan2(sqrt(a), sqrt(1-a));
    var distance = R * c;

    return distance; // retorna a distância em quilômetros
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:()async{
        await ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content:Text("Você não pode retroceder,apenas cancelar!"))
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Dentistas disponíveis')),
        body: Center(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('atendimentos')//stream é a fonte contínua de dados
                        .where('status', isEqualTo: "Aceito")
                        .where('emergenciaId', isEqualTo: "${widget.idDocEmergencia}")
                       // .where('nome', isEqualTo: 'x')
                        .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {//sempre que um valor novo é emitido pelo stream,o builder atualiza
                      if (snapshot.hasError) {
                        return const Text('Algo deu errado');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(
                          strokeWidth: 2.0,
                        );
                      }
                      // Verifica se há dados antes de acessar 'docs'
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        return ListView(
                          //map é um método que executa uma determinada função para cada elemento da lista
                          //no caso, uma lista de snapshots, que são  documentos recuperados do firestore
                          children: snapshot.data!.docs.map((DocumentSnapshot document) {
                            Map <String, dynamic> data = document.data() as Map<String, dynamic>;


                            double distanceInKm = calculateDistance(
                                double.parse(data['latitude']),
                                double.parse(data['longitude']),
                                widget.latSocorrista,
                                widget.longSocorrista,
                            );


                            if (distanceInKm.round() <20) {
                              return Container(
                                decoration: BoxDecoration(
                                  border:Border.all(
                                      color:Colors.blue,
                                      width:2
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Text("Dentista: ${data['nome'] ?? 'Nome não disponível'}"),
                                      subtitle: Text("Horário  ${data['datahora'] ?? 'Data/Hora não disponível'}"),),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        TextButton(onPressed:null,child:Text('${distanceInKm.round()}Km')),
                                        ElevatedButton(
                                          child:const Text("Escolher"),
                                          //icon: Icon(Icons.phone),
                                          onPressed:(){
                                            emergenciaFechadaUpdate(widget.idDocEmergencia);
                                            SendCallNotification(document.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Você aceitou este dentista. \n'
                                                    'Ele te ligará em breve'),
                                              ),
                                            );
                                            Navigator.push(context,MaterialPageRoute(builder: (context)=>
                                                MapPage(idDocEmergencia:widget.idDocEmergencia,
                                                    idDocAtendimento:document.id,
                                                    latSocorrista:widget.latSocorrista,
                                                    longSocorrista:widget.longSocorrista,
                                                    latDentista:double.parse(data['latitude']),
                                                    longDentista:double.parse(data['longitude'])
                                                      )));
                                            setState(() {DentisList.profissionalId=data['profissionalId'];});
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );}else{return const Visibility(visible:false,child: CircularProgressIndicator()); }
                          }).toList(),
                        );
                      } else {
                        print('AAAAAAAAAAAAAAAAAA${widget.idDocEmergencia}');
                        return Container(
                          margin: const EdgeInsets.only(top:30.0),
                          child: const Column(

                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                strokeWidth: 2.0,
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                  'Aguardando dentistas aceitarem '
                              )
                            ],
                          ),
                        );

                      }
                    },
                  ),

            ),


        floatingActionButton: Container(
          margin: const EdgeInsets.only(left:30),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: ElevatedButton(
              onPressed: (){
                Navigator.of(context).popAndPushNamed('/AuthPageRoute');
                emergenciaCanceladaUpdate(widget.idDocEmergencia);

              },
              child: const Text("Cancelar"),
            ),
          ),
        ),


      ),
    );
  }
}