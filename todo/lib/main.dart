import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/Models/item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var itens = new List<Item>();

  HomePage() {
    itens = [];

    // itens.add(new Item(title: "Tarefa 1"));
    // itens.add(new Item(title: "Tarefa 2"));
    // itens.add(new Item(title: "Tarefa 3", done: true));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var taskController = TextEditingController();

  void add() {
    if (taskController.text == "") return;

    setState(() {
      widget.itens.add(
        Item(
          title: taskController.text,
          done: false,
        ),
      );
      taskController.clear();

      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.itens.removeAt(index);

      save();
    });
  }

  Future load() async {
    var preferences = await SharedPreferences.getInstance();

    var data = preferences.getString("data");

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((e) => Item.fromJson(e)).toList();

      setState(() {
        widget.itens = result;
      });
    }
  }

  void save() async {
    var preferences = await SharedPreferences.getInstance();
    await preferences.setString('data', jsonEncode(widget.itens));
  }

  _HomePageState() {
    load();
  }

  @override
  Widget build(BuildContext context) {
    // O scaffold representa uma página
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: taskController,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: InputDecoration(
              labelText: "Nova Tarefa",
              labelStyle: TextStyle(
                color: Colors.white,
              )),
        ),
      ),
      // ListView.builder faz com que a listview tenha controle sobre a lista melhorando na perfermance
      body: ListView.builder(
        itemCount: widget.itens.length,
        itemBuilder: (BuildContext context, int index) {
          //Função que diz como será feita a rendenização do item na tela

          final item = widget.itens[index];

          return Dismissible(
            key: Key(item.title),
            background: Container(
              color: Colors.red.withOpacity(0.8),
            ),
            onDismissed: (direction) {
              remove(index);
            },
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                // setState notifica a tela de que ela precisa ser atualizada
                setState(() {
                  item.done = value;

                  save();
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
