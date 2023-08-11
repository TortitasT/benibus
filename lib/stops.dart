import 'dart:convert';

import 'package:benibus/stop.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StopResource {
  final String id;
  final String name;

  StopResource(this.id, this.name);
}

class StopsPage extends StatefulWidget {
  const StopsPage({super.key, required this.title});
  final String title;

  @override
  State<StopsPage> createState() => _StopsPageState();
}

class _StopsPageState extends State<StopsPage> {
  bool loading = true;
  List<StopResource> stops = [];
  List<StopResource> items = [];

  void loadStops() async {
    final responseItems = jsonDecode((await http.get(Uri.parse(
            'https://apisvt.avanzagrupo.com/lineas/getParadas?empresa=5&N=1')))
        .body);

    List<StopResource> stopsResources = responseItems['data']['paradas']
        .map<StopResource>((e) => StopResource(e['cod'], e['ds']))
        .toList();

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
                  return ListTile(
                    title: Text(items[index].name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StopPage(
                                title: items[index].name, id: items[index].id)),
                      );
                    },
                  );
                },
              ),
            ),
          ]),
      ]),
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
