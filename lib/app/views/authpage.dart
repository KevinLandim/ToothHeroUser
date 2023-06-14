
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:ToothHero/app/views/takepicturepagekid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;


class AuthPage extends StatefulWidget {
  const AuthPage({super.key,required this.camera});
  final CameraDescription camera;

  @override
  _AuthPageState createState() => _AuthPageState(camera);

}

class _AuthPageState  extends State<AuthPage>{
  _AuthPageState(CameraDescription camera);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  checkInternet() async {
    try {
      final response = await http.get(Uri.parse('https://github.com/KevinLandim/ToothHeroUser'));
      if (response.statusCode == 200) {
        // Estou conectado à internet.
        print('Conectado à internet');
      } else {
        // A conexão com o servidor foi estabelecida, mas ocorreu um erro ao acessar a internet.
        print('Erro ao acessar a internet');
      }
    } catch (e) {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sem conexão!")));
    // Não consegui estabelecer uma conexão com o servidor.
    print('Não conectado à internet');
    }
  }
  @override
  void initState(){
    super.initState();
    checkInternet();

  }



  _signInAnonymously() async {
    setState(() {
      _isLoading = true; // Iniciar carregamento.Faz o build renderizar novamente a tela pois um houve altereção no estado da pagina
    });
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      print("User signed in: ${userCredential.user}");

    } catch (e) {
      print("Error signing in: $e");
    }finally{
      if(mounted){ // se o usuário ainda estiver na AuthPage então pare o carregamento
        setState(() {
          _isLoading=false; //para o carregamento
        });
      }
    }

  }

  requestStoragePermission() async{ //Pedir para o usuário permitir o uso da memoria
    //ph é a biblioteca de gerenciar permissões
    var status=await ph.Permission.storage.status;
    if(status.isDenied){
      await ph.Permission.storage.request();
    }
  }

  requestLocationPermission()async{
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

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
      while(_permissionGranted != PermissionStatus.granted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(content: Text("Você precisa permitir o uso a localização!"))
        );
         _permissionGranted= await location.requestPermission();

      }
    }
  }
  requestCameraPermission()async{
    ph.PermissionStatus status= await ph.Permission.camera.status;
    while(!status.isGranted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Você precisa permitir o uso da câmera"))
      );
      status= await ph.Permission.camera.request();
    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
          child: _isLoading
              ? CircularProgressIndicator() // Mostre a barra de carregamento se _isLoading for true
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Olá,bem vindo ao tooth-hero"),
                  Text("Sobre a empresa...."),
                  ElevatedButton(
                    onPressed:()async{
                       await requestCameraPermission();
                       await requestStoragePermission();
                       await requestLocationPermission();
                        _signInAnonymously();
                      Navigator.push(
                          context as BuildContext,
                          MaterialPageRoute(builder:(context)=>
                              TakePictureScreenKid(camera:widget.camera)
                          //FirstPage(camera: widget.camera)
                          )
                      );


                    },
                    child:Text("Clique aqui para solicitar o socorro!"),
                  ),

                ],

          )

      ),
    );
  }
}