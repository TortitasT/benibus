import 'dart:convert';
import 'dart:io';

import 'package:benibus/resources.dart';
import 'package:benibus/stop.dart';
import 'package:benibus/stops.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StarredPage extends StatefulWidget {
  const StarredPage({super.key, required this.title});
  final String title;

  @override
  State<StarredPage> createState() => _StarredPageState();
}

Future<List<String>> getStarredStopsFromDisk() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getStringList('starred_stops') ?? [];
}

Future<bool> toggleStarredStopToDisk(String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> starredStops = prefs.getStringList('starred_stops') ?? [];

  bool isAlreadyStarred = starredStops.contains(id);

  !isAlreadyStarred ? starredStops.add(id) : starredStops.remove(id);
  prefs.setStringList('starred_stops', starredStops);

  return !isAlreadyStarred;
}

class _StarredPageState extends State<StarredPage> {
  bool loading = false;
  List<StopResource> stops = [];
  List<StopResource> items = [];

  void loadStops() async {
    setState(() {
      loading = true;
    });

    List<StopResource> stopsResources = (await getStops(stops)).where((stop) {
      return stop.starred;
    }).toList();

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
  Widget build(BuildContext buildContext) {
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
                  return items[index].buildStopTile(context, (state) {
                    setState(() {
                      stops[index].starred = state;
                    });

                    Future.delayed(const Duration(seconds: 1), () {
                      if (stops[index].starred) {
                        return;
                      }

                      setState(() {
                        items.removeAt(index);
                      });
                    });
                  }, loadStops);
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
