import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService{

  SharedPreferences? _sp;

  Future<void> init() async {
    _sp = await SharedPreferences.getInstance();
  }

  bool get hideWizard{
    bool? tmp = _sp?.getBool('hideWizard');
    return (tmp == null) ? false : tmp;
  }
  
  String? get customName => _sp?.getString('customName');
  bool get showCoachMakerDashboard => _sp?.getBool('showCoachMakerDashboard') ?? true;
  bool get showCoachMakerPlayList => _sp?.getBool('showCoachMakerPlayList') ?? true;
  String? get localeS => _sp?.getString('locale');
  String get playList => _sp?.getString("playList") ?? "[]";
  bool? get enabledDarkMode => _sp?.getBool('enabledDarkMode');
  bool? get restorePurchase => _sp?.getBool('restorePurchase');
  int? get pin => _sp?.getInt('pin');

  set hideWizard(bool hideWizard){
    _sp?.setBool('hideWizard', hideWizard);
  }

  set customName(String? customName){
    _sp?.setString('customName', customName!);
  }

  set localeS(String? localeS){
    _sp?.setString('locale', localeS!);
  }

  set playList(String playList){
    _sp?.setString("playList", playList);
  }

  set showCoachMakerDashboard(bool showCoachMakerDashboard){
    _sp?.setBool('showCoachMakerDashboard', showCoachMakerDashboard);
  }

  set showCoachMakerPlayList(bool showCoachMakerPlayList){
    _sp?.setBool('showCoachMakerPlayList', showCoachMakerPlayList);
  }

  set enabledDarkMode(bool? enabledDarkMode){
    _sp?.setBool('enabledDarkMode', enabledDarkMode!);
  }

  set restorePurchase(bool? restorePurchase){
    _sp?.setBool('restorePurchase', restorePurchase!);
  }

  set pin(int? pin){
    if (pin == null){
      _sp?.remove('pin');
    }else{
      _sp?.setInt('pin', pin);
    }
  }
}