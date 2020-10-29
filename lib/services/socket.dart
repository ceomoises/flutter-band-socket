

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
	Online,
	Offline,
	Connecting
}

// Que es un Mixin ??
// Si no queremos usar Provider, podemos remover el ChangeNotifier y en vez de 
// notifyListeners podemos crear nuestros Streams builder 
class Socket with ChangeNotifier{
	ServerStatus _serverStatus = ServerStatus.Connecting;
	IO.Socket _socket;

	ServerStatus get serverStatus => this._serverStatus;
	IO.Socket get socket => this._socket;

	Function get emit => this._socket.emit;  

	Socket(){
		this._initConfig();
	}

	void _initConfig(){
		// Dart client
		this._socket = IO.io('http://localhost:3000/',{
			'transports': ['websocket'],
			'autoConnect':true, 
		});

		this._socket.on('connect', (_) {
			//print('connect');
			this._serverStatus = ServerStatus.Online;
			notifyListeners();
		});

		this._socket.on('disconnect', (_){
			//print("disconnect");
			this._serverStatus = ServerStatus.Offline;
			notifyListeners();
		});

		// socket.on('nuevo-mensaje', ( payload ){
		// 	print("nuevo mensaje: ");
		// 	print(payload.containsKey("nombre") ? payload["nombre"]: "no hay");
		// });

	}
}