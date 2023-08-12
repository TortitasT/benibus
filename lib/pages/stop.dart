import 'dart:convert';
import 'package:benibus/geolocator.dart';
import 'package:benibus/pages/map.dart';
import 'package:benibus/pages/starred.dart';
import 'package:benibus/resources.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class StopPage extends StatefulWidget {
  const StopPage({Key? key, required this.stop}) : super(key: key);

  final StopResource stop;

  @override
  State<StopPage> createState() => _StopPageState();
}

class _StopPageState extends State<StopPage> {
  bool loading = true;
  bool starred = false;
  List<dynamic> items = [];

  void loadStop() async {
    final responseItems = jsonDecode(((await http.get(Uri.parse(
            'https://apisvt.avanzagrupo.com/lineas/getTraficosParada?empresa=5&parada=${widget.stop.id}')))
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

    starred = widget.stop.starred;
    loadStop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stop.name),
        actions: [
          IconButton(
            icon: Icon(starred ? Icons.star : Icons.star_border),
            onPressed: () async {
              bool state = await toggleStarredStopToDisk(widget.stop.id);
              setState(() {
                starred = state;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapPage(
                    title: 'Map',
                    stop: widget.stop,
                  ),
                ),
              );
            },
          )
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
