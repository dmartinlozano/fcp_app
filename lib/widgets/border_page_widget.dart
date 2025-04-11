import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modules/dark_mode/dark_mode_provider.dart';

class BorderPageWidget extends StatelessWidget {

  
  final Widget child;
  final AlignmentGeometry alignment;

  const BorderPageWidget({super.key, required this.child, required this.alignment});

  Card _getCard(DarkModeProvider darkModeProvider) {
    return Card(
      elevation: 4,
      color: Colors.transparent,
      margin: const EdgeInsets.all(10),
      child: Container(
        color: (darkModeProvider.enabledDarkMode)
            ? Colors.black12.withOpacity(0.7)
            : Colors.white.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DarkModeProvider>(
      builder: (_, darkModeProvider, __) {
        return Stack(
          children: [
            Container(
              decoration:  BoxDecoration(
                image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                    darkModeProvider.enabledDarkMode
                        ? Colors.black.withOpacity(0.7)
                        : Colors.transparent,
                    BlendMode.srcOver
                  ),
                  image: const AssetImage('assets/images/background.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SafeArea(
              child: (alignment == Alignment.center) 
              ? Center(
                  child: _getCard(darkModeProvider)
              )
              : SingleChildScrollView(
                  child: _getCard(darkModeProvider)
              )
            )
          ]
        );
      }
    );
  }
}
