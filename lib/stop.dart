import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class StopPage extends StatefulWidget {
  const StopPage({Key? key, required this.title, required this.id})
      : super(key: key);

  final String title;
  final String id;

  @override
  State<StopPage> createState() => _StopPageState();
}

class _StopPageState extends State<StopPage> {
  bool loading = true;
  List<dynamic> items = [];

  void loadStop() async {
    final responseItems = jsonDecode(((await http.get(Uri.parse(
            'https://apisvt.avanzagrupo.com/lineas/getTraficosParada?empresa=5&parada=' +
                widget.id)))
        .body));

    setState(() {
      loading = false;

      items.clear();
      items.addAll(responseItems['data']['traficos']
          .map((e) => e['coLinea'] + ' - ' + e['quedan']));
    });
  }

  @override
  void initState() {
    super.initState();
    loadStop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              onPressed: () {
                loadStop();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Stack(children: [
          if (loading) const Center(child: CircularProgressIndicator()),
          if (!loading)
            ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
                );
              },
            ),
        ]));
  }
}
