import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../collections/collection.dart';
import '../words_manager.dart';
import 'collection_toggle.dart';

class CollectionsPopup extends StatelessWidget {
  final List<Collection> _collections;
  final WordsManager _manager;

  const CollectionsPopup(this._collections, this._manager, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 350.w,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          ConstrainedBox(
              constraints: BoxConstraints(minHeight: 100.h, maxHeight: 400.h),
              child: ListView(
                shrinkWrap: true,
                children: _collections
                    .map((collection) => CollectionToggle(collection, _manager))
                    .toList(),
              )),
          Align(
              alignment: Alignment.bottomRight,
              child: Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: FilledButton(
                      onPressed: () => {
                            _manager.updateCollections(),
                            Navigator.pop(context)
                          },
                      child: Text('Добра',
                          style: GoogleFonts.comfortaa(
                              fontSize: 16, fontWeight: FontWeight.bold)))))
        ]));
  }
}
