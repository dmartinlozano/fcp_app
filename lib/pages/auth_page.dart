import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/globals.dart';
import '../utils/i18n.dart';
import '../widgets/border_page_widget.dart';
import '../widgets/fcp_app_bar.dart';
import '../widgets/outlined_button_ext.dart';

class AuthPage extends StatefulWidget {

  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  final TextEditingController controller = TextEditingController();
  bool showIncorrectPinMessage = false;

   @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.text.isNotEmpty && showIncorrectPinMessage) {
        setState(() {
          showIncorrectPinMessage = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool setMode = (preferencesService.pin) == null;
    return Scaffold(
       appBar: FcpAppBar(
        title: I18n.translate('authenticate.title'),
        onPressed: ()=> Navigator.pop(context, false)
      ),
      body: BorderPageWidget(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(I18n.translate((setMode) ? 'authenticate.set_pin': 'authenticate.get_pin')),
                  TextFormField(
                    key: UniqueKey(),
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4)
                    ]
                  ),
                  (showIncorrectPinMessage) ? Text(I18n.translate('authenticate.incorrect_pin'), style: const TextStyle(color: Colors.red)) : Container(),
                  OutlinedButtonExt(
                    title: Text(I18n.translate('accept')), 
                    onPressed: (){
                      if (controller.text != ""){
                        int pin = int.parse(controller.text);
                        if (setMode){
                          preferencesService.pin = pin;
                          Navigator.pop(context, true);
                        }else{
                          if (preferencesService.pin == pin){
                            Navigator.pop(context, true);
                          }else{
                            setState(() {
                              showIncorrectPinMessage = true;
                            });
                          }
                        }
                      }
                    },
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  ),

            ]
      ),
      )
    );
  }
}
