import 'dart:convert';
import 'dart:typed_data';

enum ThumbnailType{
  musicIcon,
  videoIcon,
}
extension ParseCToString on ThumbnailType{
  String value() {
    return toString().split('.').last;
  }
}

class ThumbnailDto {

  String? imagePath;
  Uint8List? imageData;
  ThumbnailType? thumbnailType;
  ThumbnailDto({
    this.imagePath,
    this.imageData, 
    this.thumbnailType
  });

  //used by send to bluetooth, not to store it in preferences
  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    if (imageData != null) data["image"] = base64Encode(imageData!);
    if (thumbnailType != null) data["thumbnailType"] = thumbnailType.toString();
    return data;
  }

  //used by send to bluetooth, not to store it in preferences
  factory ThumbnailDto.fromJson(Map<String, dynamic> json) {
    ThumbnailDto thumbnailDto = ThumbnailDto();
    if (json["image"] != null) thumbnailDto.imageData = base64Decode(json["image"]!);
    if (json["thumbnailType"] != null) thumbnailDto.thumbnailType = ThumbnailType.values.firstWhere((e) => e.toString() == json["thumbnailType"]);
    return thumbnailDto;
  }
}