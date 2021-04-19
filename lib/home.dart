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
    await Tflite.loadModel(
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
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => null,
          ),
          backwardsCompatibility: true,
          title: Center(
            child: Text('Disease Detection'),
          ),
        ),
        body: Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(50),
              child: Container(
                width: _width,
                child: Text(
                  'Disease Detection Application',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                  child: _loading
                      ? Container(
                          width: _width,
                          height: _height / 4,
                          child: Column(
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                    text: 'Please provide an Image',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                    ),
                                    children: [
                                      TextSpan(text: '\n To proceed further')
                                    ]),
                              ),
                            ],
                          ))
                      : Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 250,
                                child: Image.file(_image),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              _output != null
                                  ? Text(
                                      'This plant is ${_output[0]['label']}',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    )
                                  : Container(
                                      height: 50,
                                      child: Text(
                                        'Select Image',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 20),
                                      ),
                                    ),
                            ],
                          ),
                        )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.center,
                width: _width,
                child: SizedBox(
                  width: _width - 270,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: getImage,
                        child: Text(
                          'Choose from Gallery',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: getCameraImage,
                        child: Text(
                          'Click from Camera',
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        )));
  }
}
