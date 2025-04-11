import 'package:accordion/accordion.dart';
import 'package:fcp/modules/dark_mode/dark_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/globals.dart';
import '../utils/i18n.dart';
import '../widgets/fcp_app_bar.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {

  static const headerStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static const contentStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);

  @override
  Widget build(BuildContext context) {
    return Consumer<DarkModeProvider>(
      builder: (context, darkModeProvider, child) {
        return Scaffold(
          appBar: FcpAppBar(
            title: I18n.translate('help.title'),
            onPressed: ()=> navigate(routeName: "/settings_page"),
          ),
          body: Accordion(
            headerPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            headerBackgroundColor: darkModeProvider.enabledDarkMode ? Colors.black: Colors.white,
            headerBorderColor: Colors.blue,
            headerBorderWidth: 1.0,
            contentBorderColor: Colors.blue,
            contentBorderWidth: 1.0,
            contentBackgroundColor: darkModeProvider.enabledDarkMode ? Colors.black: Colors.white,
            children: [
              AccordionSection(
                isOpen: false,
                contentVerticalPadding: 20,
                header: Text(I18n.translate('help.faq11'), style: headerStyle),
                content: Text(I18n.translate('help.faq12'), style: contentStyle),
                rightIcon: Icon(
                  Icons.keyboard_arrow_down,
                  color: (darkModeProvider.enabledDarkMode == true)? Colors.white : Colors.black,
                  size: 20,
                ),
              ),
              AccordionSection(
                isOpen: false,
                contentVerticalPadding: 20,
                header: Text(I18n.translate('help.faq21'), style: headerStyle),
                content: Text(I18n.translate('help.faq22'), style: contentStyle),
                rightIcon: Icon(
                  Icons.keyboard_arrow_down,
                  color: (darkModeProvider.enabledDarkMode == true)? Colors.white : Colors.black,
                  size: 20,
                ),
              ),
              AccordionSection(
                isOpen: false,
                contentVerticalPadding: 20,
                header: Text(I18n.translate('help.faq31'), style: headerStyle),
                content: Text(I18n.translate('help.faq32'), style: contentStyle),
                rightIcon: Icon(
                  Icons.keyboard_arrow_down,
                  color: (darkModeProvider.enabledDarkMode == true)? Colors.white : Colors.black,
                  size: 20,
                ),
              ),
              AccordionSection(
                isOpen: false,
                contentVerticalPadding: 20,
                header: Text(I18n.translate('help.faq41'), style: headerStyle),
                content: Text(I18n.translate('help.faq42'), style: contentStyle),
                rightIcon: Icon(
                  Icons.keyboard_arrow_down,
                  color: (darkModeProvider.enabledDarkMode == true)? Colors.white : Colors.black,
                  size: 20,
                ),
              )
            ],
          )
        );
      }
    );
  }
}
