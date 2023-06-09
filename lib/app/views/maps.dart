

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';

import 'package:pictureflutter/app/views/dentistlist.dart';
import 'package:pictureflutter/app/views/ratingpage.dart';



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
  bool _isMapReady = false;  // new variable to check if the map is ready
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
      _timer = Timer(Duration(seconds:20), () {
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
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(zoom: 12, target: socorristaPinMap)));
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _isMapReady = true;  // set _isMapReady to true when map is ready

    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_isMapReady) {  // only dispose the controller if map is ready
      mapController.dispose();
    }
    //_timer?.cancel();
  }
  void reOpenEmergenceAgain(){
    CollectionReference firestore = FirebaseFirestore.instance.collection('emergencias');
    firestore.doc(widget.idDocEmergencia).update({'status':'aberta'});

    Navigator.push(context,MaterialPageRoute(builder: (context)=>
        DentisList(idDocEmergencia: widget.idDocEmergencia,
            latSocorrista: widget.latSocorrista,
            longSocorrista: widget.longSocorrista)));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top:80,left: 20,right: 20,bottom:20),
        child: SingleChildScrollView(
            child:Column(
              children: [
                Text("Atendimento em andamento"),
                Text("Mapa com a localização sua e do dentista"),
                Container(
                  height: 300,
                  child: GoogleMap(
                      initialCameraPosition: CameraPosition(target: LatLng(0, 0), zoom: 1),
                      onMapCreated: _onMapCreated,
                      markers: _markers,
                  ),
                ),
                Text('Para abrir o Maps e visualizar a rota'
                    ' até a localização do dentista, clique no Pino vermelho,e depois no Icone do maps'),
                Text("Se o dentista não te ligar em até um minuto por favor, clique no botão abaixo"),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: (){
                         if(!_isTimeOver){
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Por favor aguarde!')));
                         }else{reOpenEmergenceAgain();}

                        },
                        child: Text(
                            "Buscar outro profissional",
                                style:TextStyle(color:Colors.white)
                        )),

                    //o Botão de avaliação
                  ],

                ),
                TextButton(
                    onPressed:(){if(_isTimeOver)Navigator.push(context,MaterialPageRoute(builder: (context)=>RatingPage(idDocAtendimento:widget.idDocAtendimento)));},
                    child:Text("Avaliar atendimento"))
              ],
            ),

        ),
      ),
    );
  }


}

