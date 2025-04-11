import 'package:fcp/utils/i18n.dart';
import 'package:flutter/material.dart';
import 'package:coachmaker/coachmaker.dart';
import 'outlined_button_ext.dart';

mixin CoachMakerMixin<T extends StatefulWidget> on State<T> {

  late CoachMaker _coachMaker;
  bool showCoachMark = true;

  @override
  void initState() {
    super.initState();
    _coachMaker = CoachMaker(
      context,
      initialList: getCoachModels(),
      customNavigator: (onSkip, onNext) => OutlinedButtonExt(
        title: Text(_coachMaker.currentIndex == _coachMaker.initialList.length - 1
                ? I18n.translate('accept')
                : I18n.translate('next')
          ),
        textColor: Colors.white,
        backgroundColor: Colors.black,
        onPressed: () => onNext(),
      ),
    );

    //show when page init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (showCoachMark) {
        _coachMaker.show();
      }
    });
  }

  List<CoachModel> getCoachModels();

}
