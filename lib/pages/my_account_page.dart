import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../modules/firebase/firebase_provider.dart';
import '../utils/globals.dart';
import '../utils/i18n.dart';
import '../widgets/fcp_app_bar.dart';

class MyAccountPage extends StatefulWidget {

  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FcpAppBar(
          title: I18n.translate('my_account.title'),
          onPressed: ()=> navigate(routeName: "/settings_page"),
        ),
        body: Consumer<FirebaseProvider>(
          builder: (context, firebaseProvider, child) {
          return Center(
            child: (firebaseProvider.user != null)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  (firebaseProvider.user!.photoURL == null)
                  ? const FaIcon(FontAwesomeIcons.solidCircleUser, color: Colors.grey, size: 100)
                  : CircleAvatar(
                    backgroundImage: NetworkImage(firebaseProvider.user!.photoURL!),
                    backgroundColor: Colors.black,
                    radius: 50,
                  ),
                  const Text(""),
                  (firebaseProvider.user!.displayName == null) ? const Text("") : Text(firebaseProvider.user!.displayName!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(firebaseProvider.user!.email!, style: const TextStyle(fontSize: 15)),
                  Text(I18n.translate((firebaseProvider.purchase == null) ? "my_account.purchase_ko": "my_account.purchase_ok"), style: const TextStyle(fontSize: 15)),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(I18n.translate("my_account.user_not_found"))
                ]
              )
          );
        })
    );
  }
}
