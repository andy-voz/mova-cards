import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mova_cards/utils/prefs.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialManager {
  final Prefs _prefs;

  late TutorialCoachMark tutorialCoachMark;

  GlobalKey appTitleKey = GlobalKey();
  GlobalKey cardsStackKey = GlobalKey();
  GlobalKey clockBtnKey = GlobalKey();
  GlobalKey collectionsBtnKey = GlobalKey();
  GlobalKey mailBtnKey = GlobalKey();
  GlobalKey thanksBtnKey = GlobalKey();
  GlobalKey dictionaryBtnKey = GlobalKey();

  TutorialManager(this._prefs);

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black54,
      textSkip: "Прапусціць навучанне",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () => _prefs.setTutorialPassed(),
      onSkip: () { _prefs.setTutorialPassed(); return true; },
    );
  }

  void showTutorial(BuildContext context) {
    tutorialCoachMark.show(context: context);
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "appTitleKey1",
        keyTarget: appTitleKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Вітаю!\nКаб працягнуць націсні ў любым месцы :)",
                    style: GoogleFonts.comfortaa(fontSize: 20, color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "cardsStackKey1",
        keyTarget: cardsStackKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Словы абнаўляюцца аўтаматычна кожны дзень.",
                    style: GoogleFonts.comfortaa(fontSize: 20, color: Colors.white),
                  ),
                ],
              );
            },
          ),
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Каб перайсці на наступнае слова - смахні картку ў лева ці ў права",
                    style: GoogleFonts.comfortaa(fontSize: 20, color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "clockBtnKey1",
        keyTarget: clockBtnKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Націсні на гадзіннік каб наладзіць час абнаўлення слова",
                    style: GoogleFonts.comfortaa(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Text(
                    "У гэты час цябе прыйдзе павядомленне",
                    style: GoogleFonts.comfortaa(fontSize: 20, color: Colors.white),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "dictionaryBtnKey",
        keyTarget: dictionaryBtnKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Уся гісторыя словаў захоўваецца!",
                      style: GoogleFonts.comfortaa(fontSize: 20, color: Colors.white)),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "collectionsBtnKey1",
        keyTarget: collectionsBtnKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Тут можна кіраваць актыўнымі наборамі словаў",
                    style: GoogleFonts.comfortaa(fontSize: 20, color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "mailBtnKey1",
        keyTarget: mailBtnKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Цісні калі заўважыш памылку, ці захочаш зрабіць прапанову!",
                    style: GoogleFonts.comfortaa(fontSize: 20, color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "thanksBtnKey1",
        keyTarget: thanksBtnKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Падзякі і іншая інфармацыя аб прыладзе",
                    style: GoogleFonts.comfortaa(fontSize: 20, color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "appTitleKey2",
        keyTarget: appTitleKey,
        shape: ShapeLightFocus.RRect,
        alignSkip: Alignment.bottomLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Дзякуй!", style: GoogleFonts.comfortaa(fontSize: 26, color: Colors.white)),
                  const SizedBox(
                    height: 50,
                  ),
                  Text("Прыемнага карыстання!",
                      style: GoogleFonts.comfortaa(fontSize: 20, color: Colors.white)),
                ],
              );
            },
          ),
        ],
      ),
    );
    return targets;
  }
}
