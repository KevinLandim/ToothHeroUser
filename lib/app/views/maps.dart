

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';

import 'package:ToothHero/app/views/dentistlist.dart';
import 'package:ToothHero/app/views/ratingpage.dart';



class MapPage extends StatefulWidget {
  final String idDocEmergencia;
  final double latSocorrista;
  final double longSocorrista;
  final String idDocAtendimento;
  final double latDentista;
  final double longDentista;
  MapPage({required this.idDocEmergencia,required this.idDocAtendimento, required this.latSocorrista,
    required this.longSocorrista, required this.latDentista, required this.longDentista});
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Timer? _timer;
  bool _isTimeOver = false;


  late GoogleMapController mapController;
  late LocationData currentLocation;
  late Location location;
  bool _isMapReady = false;  // nova variável para checar se o mapa está pronto
  Set<Marker> _markers = Set<Marker>();

  @override
  void initState() {
    super.initState();
    location = new Location();
    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      updatePinOnMap();
    });
    location.enableBackgroundMode(enable: true);

    void _startTimer() {
      _isTimeOver = false;
      _timer = Timer(Duration(seconds:10), () {
        setState(() {
          _isTimeOver = true;
        });
      });
    }
    _startTimer();

  }

  void updatePinOnMap() {
    setState(() {
      var dentistPinPosition=LatLng(widget.latDentista, widget.longDentista);
      var socorristaPinMap = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      _markers.add(Marker(markerId: MarkerId('userMarkerId'), position: socorristaPinMap));
      _markers.add(Marker(markerId: MarkerId('dentistMarkerId'),position: dentistPinPosition));
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(zoom: 10, target: socorristaPinMap)));
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _isMapReady = true;

    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_isMapReady) {
      mapController.dispose();
    }
    //_timer?.cancel();
  }

  void reOpenEmergenceAgain() async{
    HttpsCallable callable=FirebaseFunctions.instance.httpsCallable('reOpenEmergenceAgain');
    final response = await callable.call(<String,dynamic>{'documentId':widget.idDocEmergencia});
    if(response.data['status']=='success'){
      print('emergencia aberta novamente');
    }else{print('Algo errado');}

    Navigator.push(context,MaterialPageRoute(builder: (context)=>
        DentisList(idDocEmergencia: widget.idDocEmergencia,
            latSocorrista: widget.latSocorrista,
            longSocorrista: widget.longSocorrista)));
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        return false;},
      child: Scaffold(
        body: Container(
          margin: EdgeInsets.only(top:60,left: 20,right: 20,bottom:20),
          child: SingleChildScrollView(
              child:Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom:20),
                    child: Text("Atendimento em andamento",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.black),),
                  ),
                  Container(
                    height: 300,
                    child: GoogleMap(
                        initialCameraPosition: CameraPosition(target: LatLng(0, 0), zoom: 1),
                        onMapCreated: _onMapCreated,
                        markers: _markers,
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[
                          Text('Para abrir o Maps e visualizar a rota até a localização do dentista, clique no Pino vermelho,e depois no Icone do maps',
                              style:TextStyle(color: Colors.black,fontSize: 16)),

                        ],
                      ),
                    ),

                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Text("Se o dentista não te ligar em até 1  minuto,por favor, clique no botão abaixo",
                              style:TextStyle(color: Colors.black,fontWeight:FontWeight.bold,fontSize: 16)),
                        ],
                      ),
                    ),

                  ),
                  Column(
                    children: [
                      ElevatedButton(
                          onPressed: (){
                           if(!_isTimeOver){
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Por favor aguarde!')));
                           }else{reOpenEmergenceAgain();}

                          },
                          style: ElevatedButton.styleFrom(backgroundColor:Colors.red),
                          child: Text(
                              "Buscar outro profissional",
                                  style:TextStyle(color:Colors.white)
                          ),),
                      TextButton(
                          onPressed:(){if(_isTimeOver)Navigator.push(context,MaterialPageRoute(builder: (context)=>RatingPage(idDocAtendimento:widget.idDocAtendimento)));},
                          child:Text("Avaliar atendimento",style:TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor:Colors.deepPurple))

                      //o Botão de avaliação
                    ],


                  ),

                ],
              ),

          ),
        ),
      ),
    );
  }


}

