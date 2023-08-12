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
}
