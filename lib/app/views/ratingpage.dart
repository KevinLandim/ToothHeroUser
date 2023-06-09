

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pictureflutter/app/views/dentistlist.dart';
import 'package:pictureflutter/app/views/personaldata.dart';


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
              child: Text("Enviar"),
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Handle rating submission
                _mostrarEntradaDeTextoDentista(context);
              },
            ),
            TextButton(
              child: Text("Cancel"),
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
              child: Text("Enviar"),
              onPressed: () {
                comentarioDentista=_controller.text.toString();
                print('Input: ${_controller.text}'); // Use the text input
                Navigator.of(context).pop();
                _mostrarEntradaDeNotaApp(context);
              },
            ),
            TextButton(
              child: Text("Cancel"),
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
              child: Text("Enviar"),
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Handle rating submission
                _mostrarEntradaDeTextoApp(context);
              },
            ),
            TextButton(
              child: Text("Cancel"),
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
              child: Text("Enviar"),
              onPressed: () {
                comentarioApp=_controller.text.toString();
                print('Input: ${_controller.text}'); // Use the text input
                Navigator.of(context).pop();
                print('notaDentista:$notaDentista. comentarioDentista:$comentarioDentista,notaApp:$notaApp,comentarioApp:$comentarioApp');
                enviarAvaliacoes();
              },
            ),
            TextButton(
              child: Text("Cancel"),
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

      try {
        var datahora = DateTime.now().toString();
        await FirebaseFirestore.instance.collection('avaliacoes').add({
          'atendimentoId': widget.idDocAtendimento,
          'nota': notaDentista,
          'comentario': comentarioDentista,
          'datahora': datahora,
          'nomesocorrista': PersonalData.nomeSocorrista,
          'profissionalId':DentisList.profissionalId
        });
      }catch(e){print('Erro ao enviar avaliações');}
    }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(/*widget.idDocAtendimento*/
            stream:FirebaseFirestore.instance.collection('atendimentos').doc('x').snapshots(),
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
                Text("Clique no botão abaixo para avaliar os nossos serviços"),
                ElevatedButton(
                onPressed: (){ _mostrarEntradaDeNotaDentista(context);},
                child:Text("Avaliar!")
                ),
              ],
            )
            ));

            }else{return Center(child: Text('Aguarde o dentista finalizar o atendimento'));}}else{return Center(child: Text('Aguarde o dentista finalizar o atendimento'));}
          })
    );

  }
}