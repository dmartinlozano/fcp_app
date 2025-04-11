import 'dart:convert';
import 'command_type.dart';

class CommandData{
  CommandType? command;
  dynamic data;

  CommandData({this.command, this.data});

  Map<String, dynamic> toJson(){
    return {
      'command': command?.value(),
      'data': data
    };
  }

  factory CommandData.fromJson(data) {
    dynamic message = jsonDecode(data['message']);
    return CommandData(
      data: message['data'],
      command: CommandType.values.firstWhere((e) => e.toString() == 'CommandType.${message["command"]}')
    );
  }
  
}