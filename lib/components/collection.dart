import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CollectionBar extends StatelessWidget {
  const CollectionBar({ super.key });

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
        contentPadding: const EdgeInsets.only(left: 15),
        dense: true,
        child: ExpansionTile(
            title: Text(AppLocalizations.of(context)!.collection,
                style: const TextStyle(fontSize: 16))
        ));
  }
}