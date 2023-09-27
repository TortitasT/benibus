import 'dart:convert';
import 'dart:io';

import 'package:benibus/geolocator.dart';
import 'package:benibus/pages/map.dart';
import 'package:benibus/pages/starred.dart';
import 'package:benibus/resources.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StopsPage extends StatefulWidget {
  const StopsPage({super.key, required this.title});
  final String title;

  @override
  State<StopsPage> createState() => _StopsPageState();
}

Future<String> getStopsHttp() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.remove('stops_cache');

  var cache = prefs.getString('stops_cache');
  if (cache != null) {
    return cache;
  }

  var response = (await http.get(Uri.parse(
      'https://apisvt.avanzagrupo.com/lineas/getParadas?empresa=5&N=1')));

  prefs.setString('stops_cache', response.body);
  return response.body;
}

Future<List<StopResource>> getStops(List<StopResource> currentStops) async {
  List<String> starredStops = await getStarredStopsFromDisk();

  List<StopResource> stopResources = currentStops.isNotEmpty
      ? currentStops
      : jsonDecode(await getStopsHttp())['data']['paradas']
          .map<StopResource>(StopResource.fromJson)
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

  // Order by closest
  try {
    LatLng currentLocation = await getCurrentLatLng();
    stopsResources.sort((a, b) {
      double distanceA =
          const Distance().as(LengthUnit.Meter, currentLocation, a.latLng);
      double distanceB =
          const Distance().as(LengthUnit.Meter, currentLocation, b.latLng);
      return distanceA.compareTo(distanceB);
    });
  } catch (_) {}

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
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapPage(title: 'Mapa')),
              ).then((value) {
                loadStops();
              });
            },
            icon: const Icon(Icons.map),
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
                  }, loadStops);
                },
              ),
            ),
          ]),
      ]),
    );
  }
}
