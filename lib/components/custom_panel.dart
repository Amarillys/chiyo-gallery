import 'package:chiyo_gallery/components/underline.dart';
import 'package:chiyo_gallery/events/eventbus.dart';
import 'package:chiyo_gallery/events/events_definition.dart';
import 'package:chiyo_gallery/utils/config.dart';
import 'package:chiyo_gallery/utils/image_util.dart';
import 'package:chiyo_gallery/utils/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CustomPanel extends StatefulWidget {
  final List<CustomOption> menuOptions;
  const CustomPanel({super.key, required this.menuOptions});

  @override
  State<CustomPanel> createState () => _CustomPanelState();
}

class _CustomPanelState extends State<CustomPanel> {
  Map<String, dynamic> values = {};
  bool inPanel = false;
  static final eventBus = GlobalEventBus.instance;

  @override
  Widget build(BuildContext ctx) {
    return Stack(
      children: [
        Positioned(
            width: MediaQuery.of(ctx).size.width,
            height: MediaQuery.of(ctx).size.height,
            child: GestureDetector(
                onTapUp: (details) {
                  if (!inPanel) { eventBus.fire(HideCustomPanelEvent()); }
                }
            )),
        Positioned(
          right: 0,
          width: 250,
          height: 550,
          child: GestureDetector(
            onTapUp: (details) {
              inPanel = true;
              Future.delayed(const Duration(seconds: 1)).then((value) {
                inPanel = false;
              });
            },
            child:Container(
              padding: const EdgeInsets.all(5.0),
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.95),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: Offset(0, 2), // changes position of shadow
                )]),
              child: Column(
                children: generateOptions(),
              ),
            )
          ))
      ],
    );
  }

  List<Widget> generateOptions() {
    final options = widget.menuOptions;
    return List.generate(options.length, (index) {
        final currentOption = options[index];
        if (currentOption.type == 'checkbox') {
          values[currentOption.valuePath] = GlobalConfig.get(currentOption.valuePath);
          return CheckboxListTile(
              value: values[currentOption.valuePath],
              title: Text(currentOption.title.tr(), style: ThemeUtil.getSubTextStyle()),
              onChanged: (bool? value) {
                onCheckBoxChanged(currentOption.valuePath, value);
              });
        } else if (currentOption.type == 'selections') {
          values[currentOption.valuePath] = GlobalConfig.get(currentOption.valuePath);
          return Container(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(margin: const EdgeInsets.only(bottom: 10), child: Text(currentOption.title.tr(), style: ThemeUtil.getSubTextStyle())),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(currentOption.selections.length, (index) {
                      final currentSelection = currentOption.selections[index];
                      final List<Widget> content = [Icon(currentSelection.icon, size: 40, color: ImageUtil.mapColorFromString(GlobalConfig.get(ConfigMap.baseColor)))];
                      if (currentSelection.value == values[currentOption.valuePath]) {
                        content.add(const SizedBox(height: 2, width: 40, child: CustomUnderline(height: 2, color: Colors.black45)));
                      }
                      return GestureDetector(
                          child: Column(
                              children: content
                          ),
                          onTapDown: (details) {
                            GlobalConfig.set(currentOption.valuePath, currentSelection.value);
                            setState(() {
                              values[currentOption.valuePath] = currentSelection.value;
                            });
                            eventBus.fire(LayoutChangedEvent(currentSelection.value));
                          }
                      );
                    }))
                ]
            )
          );
        }
        return const Text('');
    });
  }

  onCheckBoxChanged(String valuePath, bool? value) {
    switch(valuePath) {
      case ConfigMap.showHidden:
        setState(() {
          values[valuePath] = value;
        });
        GlobalConfig.set(ConfigMap.showHidden, value!);
        eventBus.fire(ShowHiddenOptionChangedEvent(value));
    }
  }
}

class CustomOption {
  String type;
  String valuePath;
  String title;
  List<Selection> selections;

  CustomOption({ required this.type, required this.valuePath, required this.title, this.selections = const [] });
}

class Selection {
  IconData icon;
  String text;
  String value;

  Selection(this.icon, this.text, this.value);
}