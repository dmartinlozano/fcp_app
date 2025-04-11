import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../dark_mode/dark_mode_provider.dart';
import 'providers/nearby_parents_provider.dart';

class NearbyWidget extends StatelessWidget {
  final NearbyRemoteDevice nearbyRemoteDevice;

  const NearbyWidget({super.key, required this.nearbyRemoteDevice});

  @override
  Widget build(BuildContext context) {
    DarkModeProvider darkModeProvider = Provider.of<DarkModeProvider>(context);
    switch (nearbyRemoteDevice.nearbyState) {
      case SessionState.notConnected:
        return const FaIcon(FontAwesomeIcons.mobileScreen);
      case SessionState.connecting:
        return const FaIcon(FontAwesomeIcons.mobileScreen, color: Colors.amber);
      case SessionState.connected:
        if (nearbyRemoteDevice.numBuilder == null) {
          return const FaIcon(FontAwesomeIcons.mobileScreen, color: Colors.amber);
        } else {
          return const FaIcon(FontAwesomeIcons.mobileScreen, color: Colors.green);
        }
    }
  }
}