import 'package:benibus/starred.dart';
import 'package:benibus/stop.dart';
import 'package:flutter/material.dart';

class StopResource {
  final String id;
  final String name;
  List<String> lines;
  bool starred;

  StopResource(this.id, this.name, this.lines, [this.starred = false]);

  ListTile buildStopTile(BuildContext context, Function starredCallback,
      Function returnToPageCallback) {
    return ListTile(
      title: Text('$id - $name'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StopPage(
                    title: name,
                    id: id,
                    starred: starred,
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
