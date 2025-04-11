import '../commands/command_data.dart';

abstract class NearbyProcessor {
  dynamic processCommand(String deviceId, CommandData command) {}
}

