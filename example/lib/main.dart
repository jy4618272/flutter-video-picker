import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_picker/video_picker.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<File> _videoFile;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Video Picker Demo'),
        ),
        body: new Center(
            child: new FutureBuilder<File>(
                future: _videoFile,
                builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.error == null) {
                    print(snapshot.data);
                    //return new Image.file(snapshot.data);
                    return new Container();
                  } else if (snapshot.error != null) {
                    return const Text('error picking video.');
                  } else {
                    return const Text('You have not yet picked a video.');
                  }
                })),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            setState(() {
              _videoFile = VideoPicker.pickVideo();
            });
          },
          tooltip: 'Pick Image',
          child: new Icon(Icons.add_a_photo),
        ),
      )
    );
  }
}
