import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ocr_selection_page.dart';

class OcrCameraPage extends StatefulWidget {
  const OcrCameraPage({
    Key? key,
    required this.properties,
    this.singleMode = false,
    this.title = "Scan text",
    this.titleCameraButton = "Scan",
    this.titleSelectText = "Select text",
  }) : super(key: key);

  final bool singleMode;
  final String title;
  final String titleSelectText;
  final String titleCameraButton;
  final List<String> properties;

  @override
  State<OcrCameraPage> createState() => _OcrCameraPageState();
}

class _OcrCameraPageState extends State<OcrCameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _init = false;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    // To display the current output from the Camera,
    // create a CameraController.
    // Obtain a list of the available cameras on the device.
  }

  _checkPermissions() async {
    if (await Permission.camera.request().isGranted) {
      setState(() {
        _permissionGranted = true;
      });
      _initCameraController();
    }
  }

  _initCameraController() async {
    final cameras = await availableCameras();

    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      cameras.first,
      // Define the resolution to use.
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    setState(() {
      _init = true;
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: !_permissionGranted
          ? Container(
              child: Text(
                "Permission not granted, please go to settings and change it",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            )
          : !_init
              ? Container()
              : FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // If the Future is complete, display the preview.
                      return Stack(children: [
                        CameraPreview(_controller),
                        Column(
                          children: [
                            Expanded(
                                child: Container(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                    shape: BeveledRectangleBorder(
                                        borderRadius: BorderRadius.zero),
                                  ),
                                  onPressed: () async {
                                    // Take the Picture in a try / catch block. If anything goes wrong,
                                    // catch the error.
                                    try {
                                      // Ensure that the camera is initialized.
                                      await _initializeControllerFuture;

                                      // Attempt to take a picture and get the file `image`
                                      // where it was saved.
                                      final image =
                                          await _controller.takePicture();

                                      if (!mounted) return;

                                      // Navigator.of(context).pop();
                                      // If the picture was taken, display it on a new screen.
                                      Map<String, String>? res =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OcrSelectionPage(
                                            // Pass the automatically generated path to
                                            // the DisplayPictureScreen widget.
                                            properties: widget.properties,
                                            title: widget.titleSelectText,
                                            imagePath: image.path,
                                            singleMode: widget.singleMode,
                                          ),
                                        ),
                                      );
                                      Navigator.of(context).pop(res);
                                    } catch (e) {
                                      // If an error occurs, log the error to the console.
                                      print(e);
                                    }
                                  },
                                  child: Text(widget.titleCameraButton),
                                ),
                              ),
                            ))
                          ],
                        )
                      ]);
                    } else {
                      // Otherwise, display a loading indicator.
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
      // floatingActionButton: FloatingActionButton(
      //   // Provide an onPressed callback.
      //   onPressed: () async {
      //     // Take the Picture in a try / catch block. If anything goes wrong,
      //     // catch the error.
      //     try {
      //       // Ensure that the camera is initialized.
      //       await _initializeControllerFuture;
      //
      //       // Attempt to take a picture and get the file `image`
      //       // where it was saved.
      //       final image = await _controller.takePicture();
      //
      //       if (!mounted) return;
      //
      //       // Navigator.of(context).pop();
      //       // If the picture was taken, display it on a new screen.
      //       Map<String, String>? res = await Navigator.of(context).push(
      //         MaterialPageRoute(
      //           builder: (context) => OcrSelectionPage(
      //             // Pass the automatically generated path to
      //             // the DisplayPictureScreen widget.
      //             properties: widget.properties,
      //             imagePath: image.path,
      //             singleMode: widget.singleMode,
      //           ),
      //         ),
      //       );
      //       Navigator.of(context).pop(res);
      //     } catch (e) {
      //       // If an error occurs, log the error to the console.
      //       print(e);
      //     }
      //   },
      //   child: const Icon(Icons.camera_alt),
      // ),
    );
  }
}
