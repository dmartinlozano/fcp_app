import 'package:fcp/modules/volume/volume_provider.dart';
import 'package:provider/provider.dart';
import 'package:volume_controller/volume_controller.dart';
import '../../utils/globals.dart';
import '../fcp_nearby/commands/command_data.dart';
import '../fcp_nearby/commands/command_type.dart';

class VolumeService{

  VolumeProvider volumeProvider = Provider.of<VolumeProvider>(navigatorKey.currentContext!, listen: false);

  init() async{
    VolumeController().listener((double volume) {
      VolumeController().showSystemUI = true;
      volumeProvider.volume = volume;
      fcpNearbyService.sendBroadcastMessage(
        CommandData(
          command: CommandType.volume,
          data: volume
        )
      );
    });
    volumeProvider.volume = await VolumeController().getVolume();
    fcpNearbyService.sendBroadcastMessage(
      CommandData(
        command: CommandType.volume,
        data: volumeProvider.volume
      )
    );
  }

  getVolume() async {
    volumeProvider.volume = await VolumeController().getVolume();
    return volumeProvider.volume;
  }

  setVolume(double volume){
    VolumeController().showSystemUI = true;
    volumeProvider.volume = volume;
    VolumeController().setVolume(volume);
  }

}