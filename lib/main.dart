import 'dart:io';

import 'package:benibus/stop.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeniBus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'BeniBus :)'),
    );
  }
}

class StopResource {
  final String id;
  final String name;

  StopResource(this.id, this.name);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<StopResource> items = [];

  // void loadItems() async {
  //   final responseItems = jsonDecode((await http.get(Uri.parse(
  //           'https://apisvt.avanzagrupo.com/lineas/getLineas?empresa=5&N=1')))
  //       .body);
  //
  //   setState(() {
  //     items.clear();
  //     items.addAll(responseItems['data'].map((e) => e['name'] as String));
  //   });
  // }

  void loadStops() async {
    final responseItems = jsonDecode((await http
            .get(Uri.parse('https://apisvt.avanzagrupo.com/lineas/getParadas')))
        .body);

    List<StopResource> stopsResources = responseItems['data']['paradas']
        .map<StopResource>((e) => StopResource(e['cod'], e['ds']))
        .toList();

    setState(() {
      items.clear();
      items.addAll(stopsResources);
    });
  }

  // void searchStops() async {
  //   final query = 'Calle';
  //
  //   final responseItems = jsonDecode((await http.get(Uri.parse(
  //           'https://apisvt.avanzagrupo.com/lineas/getTraficosParada?empresa=5&find=' +
  //               query)))
  //       .body);

  // data.parada.cod & data.parada.ds

  // setState(() {
  //   items.clear();
  //   items.addAll(responseItems['data'].map((e) => e['name'] as String));
  // });
  // }

  @override
  void initState() {
    super.initState();
    loadStops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: items.length,
        prototypeItem: const ListTile(
          title: Text("Prototype Item"),
        ),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index].name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StopPage(title: items[index].name, id: items[index].id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          loadStops();
        },
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
