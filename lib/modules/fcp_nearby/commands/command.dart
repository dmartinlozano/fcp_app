import 'command_type.dart';

class Command{

  CommandType type;
  String address;
  dynamic data;

  Command({required this.type, required this.address, this.data});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> tmp = <String, dynamic>{};
    tmp['type'] = type.value();
    tmp['address'] = address;
    tmp['data'] = data;
    return tmp;
  }

  factory Command.fromJson(Map<String, dynamic> json) {
    return Command(
      address: json['address'],
      type: CommandType.values.firstWhere((e) => e.toString() == 'CommandType.${json["type"]}'),
      data: json['data']
    );
  }
}