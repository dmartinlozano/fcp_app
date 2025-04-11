import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../utils/globals.dart';
import '../utils/i18n.dart';

class WizardPage extends StatefulWidget {

  const WizardPage({super.key});

  @override
  State<WizardPage> createState() => _WizardPageState();
}

class _WizardPageState extends State<WizardPage> {

  PageDecoration _getPageDecoration() {
    return const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 30.0),
      bodyTextStyle: TextStyle(fontSize: 20.0),
      imagePadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: I18n.translate('wizard.text11'),
          image: Image.asset('assets/images/icon.png', width: 350),
          decoration: _getPageDecoration(),
          bodyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(I18n.translate('wizard.text12'), style: const TextStyle(fontSize: 20.0)),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: I18n.getLocale().languageCode,
                icon: const Icon(Icons.keyboard_arrow_down),
                elevation: 16,
                onChanged: (String? localeValueSelected) async {
                  Locale localeSelected = I18n.supportedLocales.firstWhere((locale) => locale.languageCode == localeValueSelected);
                  await I18n.load(localeSelected);
                  setState(() => preferencesService.localeS = localeSelected.languageCode);
                },
                items: I18n.supportedLocales.map<DropdownMenuItem<String>>((Locale locale) =>DropdownMenuItem<String>(
                  value: locale.languageCode,
                  child: Text(I18n.translate('languagues.${locale.languageCode}'))
                )).toList(),
                style: const TextStyle(fontSize: 20.0),
              )
            ]),
        ),
        PageViewModel(
          title: I18n.translate('wizard.text21'),
          body: I18n.translate('wizard.text22'),
          image: Image.asset('assets/images/using.jpeg', width: 350),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: I18n.translate('wizard.text31'),
          body: I18n.translate('wizard.text32'),
          image: Image.asset('assets/images/coffee.png', width: 350),
          decoration: _getPageDecoration(),
        )
      ],
      showNextButton: false,
      done: Text(I18n.translate('accept')),
      onDone: () {
        preferencesService.hideWizard = true;
        navigate(routeName: "/");
      },
    );
  }
}