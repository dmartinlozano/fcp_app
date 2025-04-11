class DeviceInfoDto{
  int? numBuilder;
  String? iosDeviceName;
  bool isPaused = false;
  bool isLoked = false;
  double volume = 0.0;

  DeviceInfoDto({
    required this.numBuilder,
    required this.isPaused,
    required this.isLoked,
    required this.volume,
    this.iosDeviceName
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['numBuilder'] = numBuilder;
    data['isPaused'] = isPaused;
    data['isLoked'] = isLoked;
    data['volume'] = volume;
    if (iosDeviceName != null) data['iosDeviceName'] = iosDeviceName;
    return data;
  }

  factory DeviceInfoDto.fromJson(Map<String, dynamic> json) {
    DeviceInfoDto deviceInfoDto = DeviceInfoDto(
      numBuilder: json['numBuilder'],
      isPaused: json['isPaused'],
      isLoked: json['isLoked'],
      volume: json['volume']
    );
    if (json['iosDeviceName'] != null) deviceInfoDto.iosDeviceName = json['iosDeviceName'];
    return deviceInfoDto;
  }
}