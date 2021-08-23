import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    String secilenSehir;
    final myController = TextEditingController();

    void _showDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {

          return AlertDialog(
            title: new Text("HATA"),
            content: new Text("Geçersiz Bir Şehir Girdiniz"),
            actions: <Widget>[

              new FlatButton(
                child: new Text("KAPAT"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            fit: BoxFit.cover, image: AssetImage("assets/search.jpg")),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  controller: myController,
                  decoration: InputDecoration(
                      hintText: "Şehir Seçiniz",
                      border: OutlineInputBorder(borderSide: BorderSide.none)),
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              FlatButton(
                  onPressed: () async {
                    var response = await http.get(
                        "https://www.metaweather.com/api/location/search/?query=${myController.text}");
                    jsonDecode(response.body).isEmpty
                        ? _showDialog()
                        : Navigator.pop(context, myController.text);
                  },
                  child: Text("Sehri seç"))
            ],
          ),
        ),
      ),
    );
  }
}
