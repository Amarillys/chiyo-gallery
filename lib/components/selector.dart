import 'package:flutter/material.dart';

import 'package:chiyo_gallery/events/eventbus.dart';
import 'package:chiyo_gallery/utils/config.dart';
import 'package:chiyo_gallery/events/events_definition.dart';

class DropdownSelector extends StatefulWidget {
  final List list;
  final String configPath;
  final String eventType;
  const DropdownSelector({ super.key, required this.list, required this.configPath, required this.eventType });

  @override
  State<DropdownSelector> createState() => _DropdownSelectorState();
}

class _DropdownSelectorState extends State<DropdownSelector> {
  late String dropdownValue;
  final eventBus = GlobalEventBus.instance;

  @override
  void initState() {
    super.initState();
    dropdownValue = GlobalConfig.get(widget.configPath);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: dropdownValue,
      items: widget.list.map<DropdownMenuItem>((item) {
        return DropdownMenuItem(value: item.value, child: Text(item.text));
      }).toList(),
      onChanged: (value) {
        eventBus.fire(buildEventFromString(widget.eventType, value));
        setState(() {
          dropdownValue = value;
        });
      });
  }
}

class Selection {
  final String value;
  final String text;
  Selection(this.value, this.text);
}