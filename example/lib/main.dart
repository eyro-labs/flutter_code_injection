import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_code_injection/flutter_code_injection.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterCodeInjectionException error;
  bool checking = false;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    setState(() {
      error = null;
      checking = true;
    });

    try {
      await Future.delayed(Duration(seconds: 2));
      final list = await flutterCodeInjection.whiteListLibraries;
      // simulate unlisted library error by removing 3 last white listed libraries
      list.removeLast();
      list.removeLast();
      list.removeLast();

      await flutterCodeInjection.checkWhiteListLibraries(list);
    } on FlutterCodeInjectionException catch (e) {
      error = e;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    int index = 1;

    final tileHeader = ListTile(
      title: Text('Check for code injection'),
      subtitle: error == null
          ? checking
              ? Text('Checking...')
              : null
          : Text('Found ${error.unListedLibraries.length} unlisted libraries'),
      trailing: RaisedButton.icon(
        onPressed: checking ? null : initPlatformState,
        icon: Icon(Icons.extension),
        label: Text('Check'),
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
      ),
    );

    final divider = Divider(height: 0, color: Colors.blueGrey);

    Widget loading = SizedBox.shrink();
    if (checking) {
      loading = LinearProgressIndicator();
    }

    List<Widget> unListedLibraries = [];
    if (error != null && error.unListedLibraries != null) {
      unListedLibraries = ListTile.divideTiles(
        context: context,
        tiles: error.unListedLibraries.map(
          (e) {
            final sequence = index;
            index++;
            return ListTile(
              title: Text('Library - $sequence'),
              subtitle: Text(e),
            );
          },
        ),
      ).toList();
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Code Injection'),
        ),
        body: ListView(
            children: [
          tileHeader,
          divider,
        ]
              ..add(loading)
              ..addAll(unListedLibraries)),
      ),
    );
  }
}
