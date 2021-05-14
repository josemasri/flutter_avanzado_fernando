import 'dart:io';

import 'package:band_names/services/band.dart';
import 'package:band_names/services/socket.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:band_names/models/band.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    final bandService = Provider.of<BandService>(context);
    var bands = bandService.bands;

    socketService.socket
        .on('bands-updated', (data) => bandService.bands = data);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
              icon: Icon(
                Icons.circle,
                color: socketService.serverStatus == ServerStatus.Online
                    ? Colors.green
                    : socketService.serverStatus == ServerStatus.Offline
                        ? Colors.red
                        : Colors.yellow,
              ),
              onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _showChart(bands),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (_, i) => _bandTile(bands[i], bands, socketService),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewBand(context, bands, socketService),
        child: Icon(Icons.add),
        elevation: 1,
      ),
    );
  }

  Widget _bandTile(Band band, List<Band> bands, SocketService socketService) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () => _addVote(band.id, socketService),
      ),
      onDismissed: (_) => _removeBand(band.id, bands, socketService),
      background: Container(
        padding: EdgeInsets.only(left: 10),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete Band',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  _addNewBand(
      BuildContext context, List<Band> bands, SocketService socketService) {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('New Band name:'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                child: Text("Add"),
                onPressed: () => _addBandToList(
                    textController.text, context, bands, socketService),
                elevation: 5,
                textColor: Colors.blue,
              )
            ],
          );
        },
      );
    }
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text("New band Name:"),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: [
              CupertinoDialogAction(
                child: Text('Add'),
                isDefaultAction: true,
                onPressed: () => _addBandToList(
                    textController.text, context, bands, socketService),
              ),
              CupertinoDialogAction(
                child: Text('Cancel'),
                isDestructiveAction: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  _addBandToList(
    String name,
    BuildContext context,
    List<Band> bands,
    SocketService socketService,
  ) {
    print(name);
    if (name.length > 1) {
      socketService.socket.emit('add-band', {'name': name});
    }
    Navigator.of(context).pop();
  }

  _addVote(String id, SocketService socketService) {
    socketService.socket.emit('vote', {'id': id});
  }

  _removeBand(String id, List<Band> bands, SocketService socketService) {
    socketService.socket.emit('remove-band', {id});
  }

  Widget _showChart(List<Band> bands) {
    Map<String, double> dataMap = {};

    bands.forEach((band) {
      dataMap[band.name] = band.votes.toDouble();
    });

    return Container(
      height: 200,
      child: PieChart(dataMap: dataMap),
    );
  }
}
