

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart';

/*
class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}
class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433);
  bool _isMapReady = false;  // nova variável para verificar se o mapa está pronto

  void _onMapCreated(GoogleMapController controller){
    mapController = controller;
    setState(() {
      _isMapReady = true;  // defina _isMapReady como true quando o mapa estiver pronto
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_isMapReady) {  // apenas descarte o controlador se o mapa estiver pronto
      mapController?.dispose();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('google ma')),
      body: GoogleMap(
          initialCameraPosition: CameraPosition(target: _center, zoom: 11.0),
          onMapCreated: _onMapCreated
      ),
    );
  }
}

*/
class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
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
  }

  void updatePinOnMap() {
    setState(() {
      var pinPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      _markers.add(Marker(markerId: MarkerId('<marker_id>'), position: pinPosition));
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(zoom: 14, target: pinPosition)));
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top:80,left: 20,right: 20,bottom:20),
        child: Column(
          children: [
            Text("Sua localização:"),
            Container(

              height: 300,
              child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: LatLng(0, 0), zoom: 1),
                  onMapCreated: _onMapCreated,
                  markers: _markers,
              ),
            ),
            Text('Toque no botão abaixo para enviar sua localização atual,e prosseguir com o atendimento'),
            ElevatedButton(
                onPressed: null,
                child: Text(
                    "Enviar localização e confirmar",
                        style:TextStyle(color:Colors.white)
                ))
          ],
        ),
      ),
    );
  }
}

