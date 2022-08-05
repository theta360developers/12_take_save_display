import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:panorama/panorama.dart';

class PanoramaScreen extends StatefulWidget {
  File myFile;
  PanoramaScreen({Key? key, required this.myFile}) : super(key: key);

  @override
  State<PanoramaScreen> createState() => _PanoramaScreenState();
}

class _PanoramaScreenState extends State<PanoramaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Panorama(child: Image.file(widget.myFile)),
        ));
  }
}
