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
import 'firebase_options.dart';



Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`

  WidgetsFlutterBinding.ensureInitialized();


  final cameras = await availableCameras();


  final firstCamera = cameras.first;
   await Firebase.initializeApp(
        //name:'toothhero-4102d',
      options:DefaultFirebaseOptions.currentPlatform);

  runApp(
    MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.blue,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blue
      ),
        elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  backgroundColor:MaterialStateProperty.all<Color>(Colors.blue)

              )
        )),
      home:FirstPage(
          camera:firstCamera),
    ),
  );
}

class FirstPage extends StatelessWidget {
   const FirstPage({
     super.key,
     required this.camera,
   });

  final CameraDescription camera;



  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(
          title:Text('Home Page Socorrista')),
          body:Center(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Card(
                color: Colors.white,
              shape:RoundedRectangleBorder(
              borderRadius:BorderRadius.circular(15.0),
              side: BorderSide(color:Colors.black,width:2),
            ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Text(
                        'Clique no botão abaixo \n para fotografar a boca da criança!',
                        style:TextStyle(
                            fontSize: 24,
                            color:Colors.blue

                        ),
                        textAlign:TextAlign.center,


                      ),
                      FloatingActionButton(
                        onPressed: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder:(context)=>TakePictureScreen(
                                  camera: camera) )
                          );
                        }, child: Icon(Icons.camera_alt),
                      )

                    ],
                  ),
                ),
              ),


              ],
            )
          )


    );
  }



}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;



  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();
            try {
              final savedImage = await ImageGallerySaver.saveFile(image.path);
            } catch(e){
              print("Ocorreu um erro ao salvar imagem: ${e}");
            }

            
            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                  camera: widget.camera,

                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
   final CameraDescription camera;

  const DisplayPictureScreen({super.key, required this.imagePath,required this.camera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body:SingleChildScrollView(
          child:Column(
            children: [
              Container(
                height:500,
                  padding: EdgeInsets.only(top:10),
                  alignment: Alignment.center,
                  child: Image.file(File(imagePath))),
              Text(
                  'Clique para repetir a foto',
                  style:TextStyle(
                      fontSize:20
                  )
              ),
              Row(
                children: [
                  FloatingActionButton(
                    onPressed: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder:(context)=>TakePictureScreen(
                              camera:camera ) )
                      );
                    }, child: Icon(Icons.camera_alt),
                  ),
                  FloatingActionButton(
                    onPressed: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder:(context)=>DadosPessoais(imagePath: imagePath,
                            
                          ) )
                      );
                    }, child: Icon(Icons.navigate_next),
                  )

                ],
              )

            ],
          )
      )
    );
  }
}

class DadosPessoais extends StatelessWidget{

  final String imagePath;
  
  const DadosPessoais({super.key, required this.imagePath});






  @override
  Widget build(BuildContext context) {
    CollectionReference firestore = FirebaseFirestore.instance.collection('emergencias');
    TextEditingController nomeController =TextEditingController();
    TextEditingController telefoneController =TextEditingController();



    Future<void> addEmergencia(String nome, String telefone, String fullPath) async {
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
          SnackBar(content: Text('Gravando dados no Firestore... Document ID: $documentId')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DentisList(documentId: documentId)),
        );
      } catch (e) {
        print('Error adding emergencia: $e');
      }
    }


    Future<void> addImagem(String path) async{
      final storage = FirebaseStorage.instance;
      File file =File(path);
      try{
       String nome = 'img-${DateTime.now().toString()}.jpg';



        await storage.ref('emergencias')//ref é a pasta
            .child(nome)//child é o nome da foto
            .putFile(file);

        //String fullPath=storage.ref().fullPath.toString();
         await addEmergencia(nomeController.text, telefoneController.text,"emergencias/$nome");

      } on FirebaseException catch(e){
        throw Exception('Erro no upload:${e.code}');
      }

    }




    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top:60.0),
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
                onPressed: (){
                  addImagem(imagePath);
                  },
                child: Text("Solicitar emergência!"),
            ),

          ],
        ),
      ),

    );
  }


}

class DentisList extends StatefulWidget{

  final String documentId;

  const DentisList({super.key, required this.documentId});

  @override
  State<DentisList> createState() => _DentisListState();
}

class _DentisListState extends State<DentisList> {
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

              // Verifique se há dados antes de acessar 'docs'
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    return Container(
                      decoration: BoxDecoration(
                        border:Border.all(
                            color:Colors.blue,
                            width:2
                        ),
                      ),
                      child: ListTile(
                        subtitle: Text("data que o dentista aceitou ${data['datahora'] ?? 'Data/Hora não disponível'}"),
                        title: Text("Nome do dentista: ${data['nomeDentista'] ?? 'Nome não disponível'}"
                            "\nId do dentista: ${data['profissionalId']}"),
                        trailing:IconButton(
                          icon: Icon(Icons.ad_units),
                          onPressed:(){




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

