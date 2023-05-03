class OcrSelection {
  int? startBlock;
  int? startLine;
  int? startElement;

  int? endBlock;
  int? endLine;
  int? endElement;
}
class OcrSelectionProperty extends OcrSelection{
  String? property;
}