import 'package:flutter/material.dart';
import 'package:fly_nepal/colors/custom_colors.dart';
import 'package:fly_nepal/providers/MarkerListProvider.dart';
import 'package:fly_nepal/modified_flutter_class/custom_pop_menu.dart';
import 'package:fly_nepal/services/chip_manager.dart';
import 'package:fly_nepal/widgets/button_flt_pln_window.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

class FlightPlan extends StatelessWidget {
  final VoidCallback procedure;
  final VoidCallback departure;
  final VoidCallback arrival;
  final VoidCallback clear;
  final TextEditingController chipTextController;

  const FlightPlan(
      {super.key,
      requiredZ,
      required this.procedure,
      required this.departure,
      required this.arrival,
      required this.clear,
      required this.chipTextController});

  @override
  Widget build(BuildContext context) {
    // return Positioned FlightPlanContainer() {
    var provider = Provider.of<MarkerListProvider>(context, listen: false);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Positioned(
      top: height * -0.04,
      left: (width - width * 0.7) / 2,
      child: Container(
        color: CustomColor.darkBlue.color,
        height: MediaQuery.of(context).size.height * 0.25,
        width: MediaQuery.of(context).size.width * 0.7,
        margin: const EdgeInsets.only(top: 30),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonFlightPlanWindow(text: 'Procedures', fn: procedure),
                    ButtonFlightPlanWindow(text: 'Departures', fn: departure),
                    ButtonFlightPlanWindow(text: 'Arrivals', fn: arrival),
                    ButtonFlightPlanWindow(text: 'Clear', fn: clear),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "Routes",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Consumer<MarkerListProvider>(
                        builder: (BuildContext context, value, Widget? child) {
                          return ReorderableWrap(
                            needsLongPressDraggable: false,
                            buildDraggableFeedback:
                                (context, constraints, child) {
                              return Material(
                                color: Colors.transparent,
                                child: Chip(
                                  label: Text(provider.movingChip),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            },
                            spacing: 10,
                            onReorder: (oldIndex, newIndex) {
                              provider.reorder(oldIndex, newIndex);
                            },
                            children:
                                value.chipList.asMap().entries.map((entry) {
                              final chip = entry.value;

                              return CustomPopupMenu(
                                arrowSize: 15,
                                verticalMargin: 0,
                                menuBuilder: _buildLongPressMenu,
                                pressType: PressType.singleClick,
                                child: Dismissible(
                                  direction: DismissDirection.up,
                                  key: ValueKey(chip.id),
                                  child: Chip(
                                    label: Text(chip.name),
                                    labelStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    backgroundColor: Colors.yellow,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                      vertical: 3,
                                    ),
                                  ),
                                  onDismissed: (direction) {
                                    if (chip.type == 'sid') {
                                      ChipManager.deleteChip(
                                          context, chip.name, chip.type,
                                          listLatlng: chip.listLatLng!);
                                    } else if (chip.type == 'star') {
                                      ChipManager.deleteChip(
                                          context, chip.name, chip.type,
                                          listLatlng: chip.listLatLng);
                                    } else if (chip.type == 'approach') {
                                      ChipManager.deleteChip(
                                          context, chip.name, chip.type,
                                          listLatlng: chip.listLatLng);
                                    } else if (chip.type == 'user') {
                                      ChipManager.deleteChip(
                                          context, chip.name, chip.type,
                                          latLng: chip.latLng!);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                            onReorderStarted: (index) {
                              final chip = value.chipList[index];
                              provider.movingChipName(chip.name);
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.width * 0.05,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: TextFormField(
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(color: Colors.black),
                          showCursor: true,
                          maxLines: 1,
                          controller: chipTextController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: 'Type a route',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLongPressMenu() {
    List<ItemModel> menuItems = [
      ItemModel('Isert before', Icons.content_copy),
      ItemModel('Insert After', Icons.send),
      ItemModel('Show Chart', Icons.collections),
      ItemModel('Break', Icons.delete),
      ItemModel('多选', Icons.playlist_add_check),
      ItemModel('引用', Icons.format_quote),
      ItemModel('提醒', Icons.add_alert),
      ItemModel('搜一搜', Icons.search),
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 220,
        color: const Color(0xFF4C4C4C),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          itemCount: menuItems.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    item.icon,
                    size: 20,
                    color: Colors.white,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.title,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

//}
class ItemModel {
  String title;
  IconData icon;

  ItemModel(this.title, this.icon);
}
