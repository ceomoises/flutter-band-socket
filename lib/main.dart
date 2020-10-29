import 'package:band_name/services/socket.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_name/pages/home.dart';
import 'package:band_name/pages/status.dart';
import 'package:provider/single_child_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => Socket())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        initialRoute: 'home',
        routes: {
          'home': (_) => HomePage(),
          'status': (_) => StatusPage(),
        },
      ),
    );
  }
}
