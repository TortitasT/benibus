import 'dart:convert';
import 'package:benibus/starred.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class StopPage extends StatefulWidget {
  const StopPage(
      {Key? key, required this.title, required this.id, required this.starred})
      : super(key: key);

  final String title;
  final String id;
  final bool starred;

  @override
  State<StopPage> createState() => _StopPageState();
}

class _StopPageState extends State<StopPage> {
  bool loading = true;
  bool starred = false;
  List<dynamic> items = [];

  void loadStop() async {
    final responseItems = jsonDecode(((await http.get(Uri.parse(
            'https://apisvt.avanzagrupo.com/lineas/getTraficosParada?empresa=5&parada=${widget.id}')))
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

    starred = widget.starred;
    loadStop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(starred ? Icons.star : Icons.star_border),
            onPressed: () async {
              bool state = await toggleStarredStopToDisk(widget.id);
              setState(() {
                starred = state;
              });
            },
          ),
        ],
      ),
      body: Stack(children: [
        if (loading) const Center(child: CircularProgressIndicator()),
        if (!loading)
          if (items.isEmpty)
            const Center(
                child: Text('No he encontrado horarios para esta parada 😢'))
          else
            ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
                );
              },
            ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          loadStop();
        },
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
