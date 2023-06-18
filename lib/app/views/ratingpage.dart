
import 'package:ToothHero/app/views/thankspage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
//import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ToothHero/app/views/dentistlist.dart';
import 'package:ToothHero/app/views/personaldata.dart';

import 'authpage.dart';


class RatingPage extends StatefulWidget{
  final String idDocAtendimento;
  const RatingPage({super.key, required this.idDocAtendimento});

  @override
  State<StatefulWidget> createState() {

    return _RatingPageState();
  }

}

class _RatingPageState extends State<RatingPage>{
  double notaDentista = 0.0;
  String comentarioDentista='';
  double notaApp=0.0;
  String comentarioApp='';


  void _mostrarEntradaDeNotaDentista(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Nota pelo atendimento do profissional"),
          content: RatingBar.builder(
            initialRating: 3,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 35,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              print(rating);
              setState(() {notaDentista=rating;});
            },
          ),
          actions: <Widget>[

            TextButton(
              child: Text("Enviar",style:TextStyle(color: Colors.deepPurple)),
              onPressed: () {
                Navigator.of(context).pop();
                _mostrarEntradaDeTextoDentista(context);
              },
            ),
            TextButton(
              child: Text("Cancelar",style:TextStyle(color: Colors.deepPurple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
  void _mostrarEntradaDeTextoDentista(BuildContext context) {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Comente o que você achou do atendimento em geral"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Digite aqui",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Enviar",style:TextStyle(color: Colors.deepPurple),),
              onPressed: () {
                comentarioDentista=_controller.text.toString();
                print('Input: ${_controller.text}'); // Use the text input
                Navigator.of(context).pop();
                _mostrarEntradaDeNotaApp(context);
              },
            ),
            TextButton(
              child: Text("Cancelar",style:TextStyle(color: Colors.deepPurple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _mostrarEntradaDeNotaApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Nota para o Aplicativo"),
          content: RatingBar.builder(
            initialRating: 3,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 35,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              print(rating);
              setState(() {notaApp=rating;});
            },
          ),
          actions: <Widget>[

            TextButton(
              child: Text("Enviar",style:TextStyle(color: Colors.deepPurple)),
              onPressed: () {
                Navigator.of(context).pop();
                _mostrarEntradaDeTextoApp(context);
              },
            ),
            TextButton(
              child: Text("Cancelar",style:TextStyle(color: Colors.deepPurple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
  void _mostrarEntradaDeTextoApp(BuildContext context) {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Comente o que você achou do aplicativo"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Digite aqui",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Enviar",style:TextStyle(color: Colors.deepPurple)),
              onPressed: () {
                comentarioApp=_controller.text.toString();
                print('Input: ${_controller.text}'); // Use the text input
                Navigator.of(context).pop();
                print('notaDentista:$notaDentista. comentarioDentista:$comentarioDentista,'
                    'notaApp:$notaApp,comentarioApp:$comentarioApp');
                enviarAvaliacoes();
                Navigator.push(context,MaterialPageRoute(builder: (context)=>ThanksPage()));
              },
            ),
            TextButton(
              child: Text("Cancelar",style:TextStyle(color: Colors.deepPurple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
    enviarAvaliacoes() async{
     /* try {
        var datahora = DateTime.now().toString();
        await FirebaseFirestore.instance.collection('avaliacoes').add({
          'atendimentoId': widget.idDocAtendimento,
          'nota': notaDentista,
          'comentario': comentarioDentista,
          'dataHora': datahora,
          'nomeSocorrista': PersonalData.nomeSocorrista,
          'dentistaId':DentisList.profissionalId,
          'socorristaId': AuthPage.idAnonimo,
        });

      }catch(e){print('Erro ao enviar avaliações');}*/
      FirebaseFunctions functions =FirebaseFunctions.instanceFor(region:"southamerica-east1");
      HttpsCallable callable =functions.httpsCallable('enviarAvaliacoes');
      var datahora = DateTime.now().toString();
      final response=await callable.call(<String,dynamic>{
        'atendimentoId': widget.idDocAtendimento,
        'nota': notaDentista,
        'comentario': comentarioDentista,
        'dataHora': datahora,
        'nomeSocorrista': PersonalData.nomeSocorrista,
        'dentistaId':DentisList.profissionalId,
        'socorristaId': AuthPage.idAnonimo,

      });
      if(response.data['status']=='success'){
        print('Documento atualizado com sucesso');
      }else {
        print('Erro ao cancelar');
      }

    }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
            stream:FirebaseFirestore.instance.collection('atendimentos').doc(widget.idDocAtendimento).snapshots(),
            builder:(BuildContext context,AsyncSnapshot<DocumentSnapshot>snapshot){
            if(snapshot.hasError){return Text("Ocorreu algum erro ao receber o pedido de avaliação");}
            if (snapshot.hasData && snapshot.data != null) {
            Map<String,dynamic>data =snapshot.data!.data() as Map<String,dynamic>;
            if(data.containsKey('status') && data['status']=='finalizado'){
            return Scaffold(
            body:Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("São 4 perguntas rápidas para avaliar os nossos serviços!",
                  style: TextStyle(color: Colors.deepPurple,fontSize:18),
                  textAlign: TextAlign.center,),
                ElevatedButton(
                onPressed: (){ _mostrarEntradaDeNotaDentista(context);},
                child:Text("Iniciar avaliação!"),
                  style: ElevatedButton.styleFrom(backgroundColor:Colors.deepPurple),
                ),
              ],
            )
            ));

            }else{return Center(child: Text('Aguarde o dentista finalizar o atendimento',textAlign: TextAlign.center,
              style: TextStyle(color: Colors.deepPurple,fontSize:18),));}}else{return Center(child: Text('Aguarde o dentista finalizar o atendimento'));}
          })
    );

  }
}