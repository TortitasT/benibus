import 'package:benibus/starred.dart';
import 'package:benibus/stop.dart';
import 'package:flutter/material.dart';

class StopResource {
  final String id;
  final String name;
  bool starred;

  StopResource(this.id, this.name, [this.starred = false]);

  ListTile buildStopTile(BuildContext context, Function starredCallback) {
    return ListTile(
      title: Text(name),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StopPage(title: name, id: id)),
        );
      },
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
