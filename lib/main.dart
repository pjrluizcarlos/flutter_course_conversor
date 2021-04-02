import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

const request = "https://api.hgbrasil.com/finance?format=json-cors&key=0af274f9";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        hintStyle: TextStyle(color: Colors.amber),
      )
    ),
  ));
}

Future<Map> getData() {
  return http
      .get(Uri.parse(request))
      .then((response) => json.decode(response.body));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _resetFields() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      return _resetFields();
    }

    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      return _resetFields();
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      return _resetFields();
    }

    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$", textAlign: TextAlign.center),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text("Erro ao carregar dados :(",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),
                      buildTextField("Reais", "R\$", realController, _realChanged), Divider(),
                      buildTextField("Dólares", "US\$", dolarController, _dolarChanged), Divider(),
                      buildTextField("Euros", "€", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

TextField buildTextField(String label, String prefix, TextEditingController controller, Function onChanged) {
  return TextField(
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        prefixText: "$prefix "
    ),
    style: TextStyle(color: Colors.amber),
    controller: controller,
    onChanged: onChanged,
  );
}
