import 'package:fcp/modules/connectivity/location/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../utils/globals.dart';

class LocationWidget extends StatelessWidget {

  LocationWidget({super.key}){
    Provider.of<LocationProvider>(navigatorKey.currentContext!, listen: false).init();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return FutureBuilder<bool>(
          future: locationProvider.isValid(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData){
              return SizedBox(
                width: 25.0,
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.locationDot, size: 20.0),
                  color: (snapshot.data == true) ? Colors.green : Colors.red,
                  onPressed: () => navigate(routeName: '/connectivity_page'),
                ),
              );
            }else{
              return const SizedBox(
                width: 25.0,
                height: 25.0,
                child: CircularProgressIndicator(strokeWidth: 2)
              );
            }
          }
        );
      }
    );
  }
}
