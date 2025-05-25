import 'package:benibus/geolocator.dart';
import 'package:benibus/pages/stop.dart';
import 'package:benibus/pages/stops.dart';
import 'package:benibus/resources.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  MapPage({Key? key, required this.title, this.stop}) : super(key: key);

  final String title;
  final StopResource? stop;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool loading = false;
  LatLng latLng = const LatLng(0, 0);
  List<StopResource> stops = [];

  @override
  void initState() {
    super.initState();

    loadInitialLatLong();
  }

  Future<void> loadStops() async {
    List<StopResource> newStops = await getStops([]);

    setState(() {
      stops = newStops;
    });
  }

  List<Marker> getStopMarkers() {
    return stops
        .map((stop) => Marker(
              width: 45.0,
              height: 45.0,
              point: stop.latLng,
              rotate: true,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.location_on,
                  color: stop.starred ? Colors.orange : Colors.green,
                  size: 45,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StopPage(
                              stop: stop,
                            )),
                  ).then((value) => loadStops());
                },
              ),
            ))
        .toList();
  }

  Future<void> centerToCurrentLocation() async {
    bool lastLoading = loading;

    setState(() {
      loading = true;
    });

    try {
      LatLng newLatLng = await getCurrentLatLng();

      setState(() {
        latLng = newLatLng;
      });
    } catch (_) {}

    setState(() {
      loading = lastLoading;
    });
  }

  void loadInitialLatLong() async {
    setState(() {
      loading = true;
    });

    if (widget.stop == null) {
      await centerToCurrentLocation();
    } else {
      setState(() {
        latLng = widget.stop!.latLng;
      });
    }

    await loadStops();

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(children: [
          if (loading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (!loading)
            FlutterMap(
              options: MapOptions(
                initialCenter: latLng,
                initialZoom: 18.0,
                maxZoom: 18.0,
                minZoom: 1.0,
              ),
              children: [
                MobileLayerTransformer(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(
                        onPressed: () {
                          centerToCurrentLocation();
                        },
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                  ),
                ),
                MobileLayerTransformer(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: () {
                          launchUrl(
                              Uri.parse('https://openstreetmap.org/copyright'));
                        },
                        child: const Text('OpenStreetMap contributors'),
                      ),
                    ),
                  ),
                ),
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'eu.tortitas.benibus',
                  maxNativeZoom: 18,
                  minNativeZoom: 1,
                ),
                CurrentLocationLayer(),
                MarkerLayer(
                  markers: getStopMarkers(),
                )
              ],
            )
        ]));
  }
}
