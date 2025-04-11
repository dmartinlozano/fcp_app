import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/i18n.dart';
import '../../widgets/coach_point_maker_widget.dart';

class PlayListDemoWidget extends StatefulWidget {
  const PlayListDemoWidget({super.key});

  @override
  State<PlayListDemoWidget> createState() => PlayListDemoWidgetState();
}

class PlayListDemoWidgetState extends State<PlayListDemoWidget> with TickerProviderStateMixin{

  late SlidableController _slidableController;

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this);
  }

  void openSlidable() {
    _slidableController.openStartActionPane();
  }

  void closeSlidable() {
    _slidableController.close();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      key: UniqueKey(),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (int oldIndex, int newIndex) {},
      children: [
        Slidable(
          key: UniqueKey(),
          controller: _slidableController,
          startActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.20,
                child: CoachPointMakerWidget(
                  initial: '22',
                  showCoachPoint: true,
                  child: SlidableAction(
                    label: I18n.translate('rename'),
                    backgroundColor: Colors.yellow,
                    icon: FontAwesomeIcons.pencil,
                    onPressed: null
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.20,
                child: CoachPointMakerWidget(
                  initial: '23',
                  showCoachPoint: true,
                  child: SlidableAction(
                    label: I18n.translate('delete'),
                    backgroundColor: Colors.red,
                    icon: Icons.playlist_remove,
                    onPressed: null
                  )
                ),
              )
            ],
          ),
          child: ListTile(
              key: UniqueKey(),
              title: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Play List demo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    CoachPointMakerWidget(
                      initial: '24',
                      showCoachPoint: true,
                      child: Icon(Icons.menu)
                    )
                  ]),
              leading: const Icon(Icons.playlist_play, size: 25, color: Colors.black),
              trailing: const CoachPointMakerWidget(
                initial: '25',
                showCoachPoint: true,
                child: Icon(Icons.keyboard_arrow_down_outlined, size: 25)
              )
            )
        )
    ]
        );
  }
}
