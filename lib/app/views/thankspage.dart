import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'authpage.dart';

class ThanksPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async {return false;},
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height:300,
                child: Image.asset("assets/imagens/ic_dente_corte.png")),
            Center(
              child: Card(
                elevation: 10, // Ajusta a elevação do cartão
                child: Container(
                  padding: EdgeInsets.all(20), // Ajusta o preenchimento do cartão
                  child: Text(
                    "Obrigado por escolher a ToohHero!",textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20, // Ajusta o tamanho da fonte
                        fontWeight: FontWeight.bold // Ajusta a espessura da fonte
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:50),
              child: ElevatedButton(onPressed:(){SystemNavigator.pop();} ,
                  child:Text("Fechar aplicativo"),
                  style: ElevatedButton.styleFrom(backgroundColor:Colors.deepPurple),
              ),
            )
          ],

        ),
      ),
    );
  }


}