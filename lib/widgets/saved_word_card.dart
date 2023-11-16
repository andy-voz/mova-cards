import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mova_cards/words_manager.dart';

import '../saves/saved_word.dart';
import '../utils/utils.dart';
import '../word.dart';

class SavedWordCard extends StatelessWidget {
  final SavedWord _savedWord;
  final WordsManager _manager;

  const SavedWordCard(this._manager, this._savedWord, {super.key});

  @override
  Widget build(BuildContext context) {
    Word? word = _manager.findWord(_savedWord.id);

    return Card(
        child: Stack(children: [
      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Container(
            padding: const EdgeInsets.only(top: 10, left: 5),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                    imgAssetsDir + word!.imgPath(),
                    scale: 3))),
        Column(children: <Widget>[
          Container(
              padding: const EdgeInsets.only(top: 15, left: 10),
              width: 200.w,
              child: FittedBox(
                  alignment: Alignment.bottomLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(word.by,
                      softWrap: false,
                      style: GoogleFonts.comfortaa(
                          fontWeight: FontWeight.bold, fontSize: 24)))),
          Container(
              padding: const EdgeInsets.only(left: 10, top: 5),
              width: 200.w,
              child: FittedBox(
                  alignment: Alignment.bottomLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                      'Катэгорыя:\n${word.collection}',
                      softWrap: false,
                      style: GoogleFonts.comfortaa(fontSize: 14)))),
        ])
      ]),
      Container(
        padding: const EdgeInsets.only(right: 15),
        height: 120.w,
        alignment: Alignment.centerRight,
        child: IconButton.filledTonal(
            onPressed: () => {goToDefinition(word.by)},
            icon: const Icon(FontAwesomeIcons.question, size: 30)),
      )
    ]));
  }
}
