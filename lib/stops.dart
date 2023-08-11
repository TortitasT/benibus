import 'dart:convert';

import 'package:benibus/resources.dart';
import 'package:benibus/starred.dart';
import 'package:benibus/stop.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StopsPage extends StatefulWidget {
  const StopsPage({super.key, required this.title});
  final String title;

  @override
  State<StopsPage> createState() => _StopsPageState();
}

Future<List<StopResource>> getStops(List<StopResource> currentStops) async {
  List<String> starredStops = await getStarredStopsFromDisk();

  // Load if not loaded
  List<StopResource> stopResources = currentStops.isNotEmpty
      ? currentStops
      : jsonDecode((await http.get(Uri.parse(
                  'https://apisvt.avanzagrupo.com/lineas/getParadas?empresa=5&N=1')))
              .body)['data']['paradas']
          .map<StopResource>((e) => StopResource(e['cod'], e['ds']))
          .toList();

  // Set starred
  List<StopResource> stopsResources = stopResources.map((stop) {
    if (starredStops.contains(stop.id)) {
      stop.starred = true;
    } else {
      stop.starred = false;
    }
    return stop;
  }).toList();

  return stopsResources;
}

class _StopsPageState extends State<StopsPage> {
  bool loading = false;
  List<StopResource> stops = [];
  List<StopResource> items = [];

  void loadStops() async {
    setState(() {
      loading = true;
    });

    final stopsResources = await getStops(stops);

    setState(() {
      loading = false;

      stops.clear();
      stops.addAll(stopsResources);

      items.clear();
      items.addAll(stopsResources);
    });
  }

  void filterStopsByQuery(query) {
    setState(() {
      items = stops
          .where(
              (stop) => stop.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadStops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const StarredPage(title: 'Mis paradas')),
              ).then((value) {
                loadStops();
              });
            },
            icon: const Icon(Icons.star),
          ),
        ],
      ),
      body: Stack(children: [
        if (loading) const Center(child: CircularProgressIndicator()),
        if (!loading)
          Column(children: [
            Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Buscar por nombre de parada',
                  ),
                  onChanged: (value) {
                    filterStopsByQuery(value);
                  },
                )),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return items[index].buildStopTile(context, (state) {
                    setState(() {
                      stops[index].starred = state;
                    });
                  });
                },
              ),
            ),
          ]),
      ]),
    );
  }
}
