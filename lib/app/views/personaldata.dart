import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:firebase_storage/firebase_storage.dart' ;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'dentistlist.dart';

class PersonalData extends StatefulWidget {
  final List listOfImages;
  const PersonalData({super.key,required this.listOfImages});
  @override
  State<StatefulWidget> createState() =>_PersonalDataState();
}

class _PersonalDataState extends State<PersonalData>{

  double uploadProgress = 0.0;
  bool  visibility=false;

  getCoordinates(String coordinates) async{ //Esta função verifica se a localização foi permitita e se está ativa,e envia coordenadas
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    //verifica se a localização do dispositivo está ativada
    //se estiver,retorna 'true',se não,'false'
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();//pede ao usuário para ativar com pop-up
      if (!_serviceEnabled) {//se o usuário recusar o pedido, o programa só retorna nada para sair do if
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text("Você precisa ativar a localização!"))
        );
        _serviceEnabled = await location.requestService();

      }
    }
    _permissionGranted = await location.hasPermission();//verifica se a permissão de localização está habilitada
    if (_permissionGranted == PermissionStatus.denied) {//manda um pop-pup para ativar se não estiver
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(content: Text("Você precisa permitir o uso a localização!"))
        );
        await location.requestPermission();

      }
    }

    _locationData = await location.getLocation();
    if(coordinates=='latitude'){return _locationData.latitude; }
    if(coordinates=='longitude'){return _locationData.longitude;}
    print("Longitude:${_locationData.longitude.toString()}e  latitude:${_locationData.latitude.toString()}");
  }

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
          'fotoAmbos':imageBothPath,
          'latitude': await getCoordinates('latitude'),
          'longitude': await  getCoordinates('longitude')
        });

        String documentId = documentRef.id;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Emergência aberta!')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DentisList(documentId: documentId,telefone:telefone,nomeSocorrista:nome)),
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
                      FocusScope.of(context).unfocus();//Tira o foco do widget que tem foco(no caso, fecha o teclado)
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
