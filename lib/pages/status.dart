import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_name/services/socket.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<Socket>(context);

    return Scaffold(
      body: Center(
        child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
          children: [
						Text("ServerStatus: ${socketService.serverStatus} ")
					],
        ),
      ),
			floatingActionButton: FloatingActionButton(
				child: Icon(Icons.message ),
				onPressed: (){
					socketService.emit('emitir-mensaje', {
						'nombre':'Flutter',
						"mensaje":'Hola,desde flutter'
					});
				},
			),
    );
  }
}
