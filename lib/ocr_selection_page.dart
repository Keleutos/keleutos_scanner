import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'models/selection.dart';

class OcrSelectionPage extends StatefulWidget {
  const OcrSelectionPage(
      {Key? key,
      required String this.imagePath,
      required this.properties,
      required this.title,
      this.singleMode = false})
      : super(key: key);
  final bool singleMode;
  final String imagePath;
  final String title;
  final List<String> properties;

  @override
  State<OcrSelectionPage> createState() => _OcrSelectionPageState();
}

class _OcrSelectionPageState extends State<OcrSelectionPage> {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  OcrSelection _selection = OcrSelection();
  List<OcrSelectionProperty> _propSelection = List.empty(growable: true);
  RecognizedText? _recognizedText;

  _selectProperty() async {
    String? prop;
    if (widget.singleMode) {
      prop = "default";
    } else {
      String? prop = await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              ...widget.properties.map((e) => ListTile(
                    leading: _getResult()[e] != ""
                        ? const Icon(Icons.check)
                        : const Icon(Icons.add),
                    title: Text(e),
                    onTap: () => Navigator.of(context).pop(e),
                  ))
            ],
          );
        },
      );
    }
    if (prop != null) {
      setState(() {
        _propSelection = _propSelection
            .where((element) => element.property != prop)
            .toList();
      });
      var ocr = OcrSelectionProperty()
        ..property = prop
        ..startBlock = _selection.startBlock
        ..startLine = _selection.startLine
        ..startElement = _selection.startElement
        ..endBlock = _selection.endBlock
        ..endLine = _selection.endLine
        ..endElement = _selection.endElement;
      setState(() {
        _propSelection.add(ocr);
      });
      if (widget.singleMode) {
        print(_getResult());
        Navigator.of(context).pop(_getResult());
      }
    }
    _clearSelection();
  }

  Map<String, String> _getResult() {
    Map<String, String> result = Map();
    if (!widget.singleMode) {
      for (var prop in widget.properties) {
        if (_propSelection.map((e) => e.property).contains(prop)) {
          var selection =
              _propSelection.where((element) => element.property == prop).first;
          var text = "";
          _recognizedText!.blocks.asMap().entries.forEach((block) {
            block.value.lines.asMap().entries.forEach((line) {
              line.value.elements.asMap().entries.forEach((element) {
                if (_isInSelection(
                    selection, block.key, line.key, element.key)) {
                  text = "${text} ${element.value.text}";
                }
              });
            });
          });

          result[prop] = text;
        } else {
          result[prop] = "";
        }
      }
    } else {
      var selection = _propSelection
          .where((element) => element.property == "default")
          .first;
      var text = "";
      _recognizedText!.blocks.asMap().entries.forEach((block) {
        block.value.lines.asMap().entries.forEach((line) {
          line.value.elements.asMap().entries.forEach((element) {
            if (_isInSelection(selection, block.key, line.key, element.key)) {
              text = "${text} ${element.value.text}";
            }
          });
        });
      });
      result["default"] = text;
    }
    return result;
  }

  _clearAll() {
    setState(() {
      _propSelection.clear();
    });
    _clearSelection();
  }

  _onSelection(int block, int line, int element) {
    setState(() {
      if (_selection.startBlock == null) {
        _selection.startBlock = block;
        _selection.startLine = line;
        _selection.startElement = element;
      } else {
        _selection.endBlock = block;
        _selection.endLine = line;
        _selection.endElement = element;
      }
    });
    if (_selection.endBlock != null) {
      _selectProperty();
    }
  }

  _clearSelection() {
    setState(() {
      _selection = OcrSelection();
    });
  }

  bool _isInSelection(
      OcrSelection selection, int block, int line, int element) {
    if (selection.endBlock == null) {
      return selection.startBlock == block &&
          selection.startLine == line &&
          selection.startElement == element;
    } else {
      if (selection.startBlock! <= block && block <= selection.endBlock!) {
        if (selection.startBlock! < block && block < selection.endBlock!) {
          return true;
        }
        if (selection.startLine! <= line && line <= selection.endLine!) {
          if (selection.startLine! < line && line < selection.endLine!) {
            return true;
          }
          if (selection.startElement! <= element &&
              element <= selection.endElement!) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool _isSelected(int block, int line, int element) {
    return _isInSelection(_selection, block, line, element);
  }

  bool _isPropSelected(int block, int line, int element) {
    var result = false;
    for (var selection in _propSelection) {
      if (_isInSelection(selection, block, line, element)) {
        result = true;
      }
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _recognizeText();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _textRecognizer.close();
    super.dispose();
  }

  _recognizeText() async {
    final inputImage = InputImage.fromFilePath(widget.imagePath);
    var recognizedText = await _textRecognizer.processImage(inputImage);
    setState(() {
      _recognizedText = recognizedText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.

          // Navigator.of(context).pop();
          // If the picture was taken, display it on a new screen.
          Navigator.of(context).pop(_getResult());
        },
        child: const Icon(Icons.check),
      ),
      body: _recognizedText != null
          ? ListView(children: [
              ..._recognizedText!.blocks.asMap().entries.map((block) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ...block.value.lines.asMap().entries.map((line) =>
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Wrap(
                              children: [
                                ...line.value.elements
                                    .asMap()
                                    .entries
                                    .map((e) => GestureDetector(
                                          onTap: () => _onSelection(
                                              block.key, line.key, e.key),
                                          child: Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 4,
                                                      color: _isSelected(
                                                              block.key,
                                                              line.key,
                                                              e.key)
                                                          ?
                                                          Theme.of(context).colorScheme.secondary
                                                          : _isPropSelected(
                                                                  block.key,
                                                                  line.key,
                                                                  e.key)
                                                              ?
                                                      Theme.of(context).colorScheme.primary
                                                              : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black38)),
                                              margin: EdgeInsets.all(4),
                                              child: Text(
                                                "${e.value.text}",
                                                style: TextStyle(fontSize: 20),
                                              )),
                                        ))
                              ],
                            ),
                          ))
                    ],
                  ),
                );
              }),
            ])
          : Container(),
    );
  }
}
