import 'package:fcp/modules/connectivity/bluetooth/bluetooth_provider.dart';
import 'package:fcp/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class BluetoothWidget extends StatelessWidget {

  BluetoothWidget({super.key}){
    Provider.of<BluetoothProvider>(navigatorKey.currentContext!, listen: false).init();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (_, bluetoothManager, __) {
        return SizedBox(
          width: 25.0,
          child: IconButton(
            icon: const FaIcon(FontAwesomeIcons.bluetoothB, size: 20.0),
            color: (bluetoothManager.isValid()) ? Colors.green : Colors.red,
            onPressed: () => navigate(routeName: '/connectivity_page'),
          ),
        );
      }
    );
  }
}
