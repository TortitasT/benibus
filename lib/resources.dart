import 'package:benibus/pages/starred.dart';
import 'package:benibus/pages/stop.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class StopResource {
  final String id;
  final String name;
  List<String> lines;
  LatLng latLng;
  bool starred;

  StopResource(this.id, this.name, this.lines, this.latLng,
      [this.starred = false]);

  ListTile buildStopTile(BuildContext context, Function starredCallback,
      Function returnToPageCallback) {
    return ListTile(
      title: Text('$id - $name'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StopPage(
                    stop: this,
                  )),
        ).then((value) => returnToPageCallback());
      },
      subtitle: Text(lines.join(', ')),
      trailing: IconButton(
        onPressed: () async {
          bool state = await toggleStarredStopToDisk(id);
          starredCallback(state);
        },
        icon: Icon(starred ? Icons.star : Icons.star_border),
      ),
    );
  }

  static StopResource fromJson(json) {
    String id = json['cod'];
    String name = json['ds'];

    List<String> lines = json['lines'] is List
        ? json['lines'].map<String>((json) => json.toString()).toList()
        : [json['lines']];

    String lat = json['coordinates'][0];
    String lon = json['coordinates'][1];
    LatLng latLng = LatLng(double.parse(lat), double.parse(lon));

    return StopResource(id, name, lines, latLng);
  }

  toJson() {
    return {
      'cod': id,
      'ds': name,
      'lines': lines,
      'coordinates': [latLng.latitude, latLng.longitude],
    };
  }
}

class TraficResource {
  final String code;
  final String description;
  final String lasting;

  TraficResource(this.code, this.description, this.lasting);

  ListTile buildStopTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.directions_bus),
      title: Text(code),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description),
        ],
      ),
      trailing: Text(lasting, style: const TextStyle(fontSize: 20)),
    );
  }
}
