import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:fcp/modules/connectivity/bluetooth/bluetooth_widget.dart';
import 'package:fcp/modules/connectivity/location/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:provider/provider.dart';
import '../modules/connectivity/bluetooth/bluetooth_provider.dart';
import '../modules/connectivity/location/location_widget.dart';
import '../utils/globals.dart';
import '../utils/i18n.dart';
import '../widgets/border_page_widget.dart';
import '../widgets/fcp_app_bar.dart';
import '../widgets/outlined_button_ext.dart';

class ConnectivityPage extends StatelessWidget {

  const ConnectivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FcpAppBar(
        title: I18n.translate('connectivity.title'),
        onPressed: () => Navigator.pop(navigatorKey.currentContext!, false),
      ),
      body: Consumer2<BluetoothProvider, LocationProvider>(
        builder: (context, bluetoothProvider, locationProvider, child) {
          return BorderPageWidget(
            alignment: Alignment.topCenter,
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                //bluetooth
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: BluetoothWidget(),
                        title: Text(I18n.translate('connectivity.bluetooth')),
                      ),
                      ListTile(title: Text(I18n.translate('connectivity.bluetooth_text'))),
                      ListTile(
                        title: Text(I18n.translate('connectivity.permissions')),
                        trailing: (bluetoothProvider.permission == PermissionStatus.granted)
                        ? const SizedBox(
                            width: 25.0, 
                            child: FaIcon(FontAwesomeIcons.check, color: Colors.green)
                          )
                        : SizedBox(
                            width: 105.0,
                            child: OutlinedButtonExt(
                              onPressed: () => bluetoothProvider.requestPermissions(),
                              title: Text(I18n.translate('enable'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.black))
                            ),
                          )
                      ),
                      ListTile(
                        title: Text(I18n.translate('connectivity.service')),
                        trailing: (bluetoothProvider.state == BluetoothAdapterState.on)
                        ? const SizedBox(
                            width: 25.0,
                            child: FaIcon(FontAwesomeIcons.check, color: Colors.green)
                          )
                        : SizedBox(
                            width: 105.0,
                            child: OutlinedButtonExt(
                              onPressed: () => bluetoothProvider.enableService(),
                              title: Text(I18n.translate('enable'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.black))
                            ),
                          )
                      )
                    ],
                  ),
                ),
                //location
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: LocationWidget(),
                        title: Text(I18n.translate('connectivity.location')),
                      ),
                      ListTile(title: Text(I18n.translate('connectivity.location_text'))),
                      ListTile(
                        title: Text(I18n.translate('connectivity.permissions')),
                        trailing: (locationProvider.permission == PermissionStatus.granted)
                        ? const SizedBox(
                            width: 25.0,
                            child: FaIcon(FontAwesomeIcons.check, color: Colors.green)
                          )
                        : SizedBox(
                            width: 105.0,
                            child: OutlinedButtonExt(
                              onPressed: () => locationProvider.requestPermissions(),
                              title: Text(I18n.translate('enable'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.black))
                            ),
                          )
                      ),
                      ListTile(
                        title: Text(I18n.translate('connectivity.service')),
                        trailing: (locationProvider.state == true)
                        ?  const SizedBox(
                            width: 25.0,
                            child: FaIcon(FontAwesomeIcons.check, color: Colors.green)
                          )
                        : SizedBox(
                            width: 105.0,
                            child: OutlinedButtonExt(
                              onPressed: () => locationProvider.enableService(),
                              title: Text(I18n.translate('enable'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.black))
                            ),
                          )
                      )
                    ],
                  ),
                ),
                //local network
                if (Platform.isIOS)
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(FontAwesomeIcons.networkWired),
                        title: Text(I18n.translate('connectivity.local_network')),
                      ),
                      ListTile(
                        title: Text(I18n.translate('connectivity.local_network_text')),
                        trailing: SizedBox(
                          width: 105.0,
                          child: OutlinedButtonExt(
                            onPressed: () async => await AppSettings.openAppSettings(asAnotherTask: true),
                            title: Text(I18n.translate('check'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.black))
                          ),
                        )
                      )
                    ],
                  ),
                ),
                if (Platform.isIOS)
                OutlinedButtonExt(
                  onPressed: () => Navigator.pop(navigatorKey.currentContext!, true),
                  title: Text(I18n.translate('next'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.black))
                )
              ]
            )
          );
        }
      )
    );
  }
}
