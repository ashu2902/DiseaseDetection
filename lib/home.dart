import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _loading = true;
  File _image;
  List _output;
  final picker = ImagePicker();

  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  //init ml model finction
  loadModel() async {
    String res = await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  //image prediction

  Future imagePrediction(File image) async {
    var output = await Tflite.runModelOnImage(
        path: _image.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );
    setState(() {
      _output = output;
      _loading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Pick image from gallery
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;
    setState(() {
      _image = File(pickedFile.path);
    });

    imagePrediction(_image);
  }

  // Pick image from camera
  Future getCameraImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile == null) return null;
    setState(() {
      _image = File(pickedFile.path);
    });

    imagePrediction(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Disease Detection')),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _image == null
                      ? Container(
                          child: Text('no image selected'),
                          color: Colors.blue,
                          height: 180,
                          width: 250,
                        )
                      : Container(
                          child: Image.file(_image),
                          color: Colors.blue,
                          height: 200,
                          width: 350,
                        )),
              Container(
                child: Text(
                  "name",
                  textAlign: TextAlign.center,
                ),
                color: Colors.red,
                height: 50,
                width: MediaQuery.of(context).size.width,
              ),
              ElevatedButton(
                onPressed: getImage,
                child: Text('Choose from Gallery'),
              ),
              ElevatedButton(
                onPressed: getCameraImage,
                child: Text('Click from Camera'),
              )
            ],
          ),
        ));
  }
}
