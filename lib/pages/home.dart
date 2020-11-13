import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_name/models/band.dart';
import 'package:band_name/services/socket.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: '1', name: 'Soda Stereo', votes: 4),
    // Band(id: '2', name: 'Queen', votes: 3),
    // Band(id: '3', name: 'Rolling Stones', votes: 2),
    // Band(id: '4', name: 'Megadeth', votes: 4),
  ];

  @override
  void initState() {
    // no necesitamos volver a re-dibujar nada si cambia el provider
    final socketService = Provider.of<Socket>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<Socket>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<Socket>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nombre de Bandas",
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.Online
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : Icon(Icons.offline_bolt, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
					if(bands.isNotEmpty)_showGraph(),
					Expanded(
					  child: ListView.builder(
					  	itemCount: bands.length,
					  	itemBuilder: (context, i) => _bandTile(bands[i]),
					  ),
					),
				],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<Socket>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketService.emit('delete-band', {"id": band.id}),
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        alignment: Alignment.centerLeft,
        color: Colors.red,
        child: Text(
          "Eliminar Banda",
          style: TextStyle(color: Colors.white),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      // Para Android
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Nueva Banda:"),
          content: TextField(
            controller: textController,
          ),
          actions: <Widget>[
            MaterialButton(
              child: Text("Agregar"),
              elevation: 5,
              textColor: Colors.blue,
              onPressed: () => addBandToList(textController.text),
            )
          ],
        ),
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text("Nueva banda: \n"),
        content: CupertinoTextField(
          controller: textController,
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Agregar"),
            onPressed: () => addBandToList(textController.text),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      // this.bands.add(new Band(id: DateTime.now().toString() , name: name, votes: 0));
      // setState(() {});
      final socketService = Provider.of<Socket>(context, listen: false);
      socketService.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

	// Mostrar Gráfica 
	Widget _showGraph(){

		Map<String, double> dataMap = new Map();
		bands.forEach( (band) => dataMap[ band.name ] = band.votes.toDouble() );

		return Container( 
			width: double.infinity,
			height: 200,
			child: PieChart(
				dataMap: dataMap,
				chartValuesOptions: ChartValuesOptions(
					showChartValueBackground: false,
					showChartValues: true,
					showChartValuesInPercentage: true,
					showChartValuesOutside: false,
				),
			),
		);
	}


}
