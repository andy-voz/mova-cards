import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mova_cards/screens/dictionary_screen.dart';
import 'package:mova_cards/utils/dark_mode_controller.dart';
import 'package:mova_cards/utils/tutorial_manager.dart';
import 'package:mova_cards/widgets/cards_stack.dart';
import 'package:mova_cards/widgets/collections_popup.dart';
import 'package:mova_cards/widgets/thanks_popup.dart';
import 'package:mova_cards/words_manager.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../utils/prefs.dart';

final log = Logger('HomeScreen');

class HomeScreen extends StatefulWidget {
  const HomeScreen(
      {super.key, required this.title, required this.darkModeController});

  final String title;

  final DarkModeController darkModeController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum MailOption {
  suggestion,
  bug,
  other,
}

class _HomeScreenState extends State<HomeScreen> {
  final _prefs = Prefs();

  late TutorialManager _tutorialManager;
  late WordsManager _manager;

  void _showSnack(String text) {
    var messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(style: GoogleFonts.comfortaa(), text),
      ),
    );
  }

  void _sendMail(MailOption option) async {
    String subject = '';

    switch (option) {
      case MailOption.suggestion:
        {
          subject = 'Mova: Cards - Прапанова';
          break;
        }
      case MailOption.bug:
        {
          subject = 'Mova: Cards - Памылка';
          break;
        }
      case MailOption.other:
        {
          subject = 'Mova: Cards - Іншае';
          break;
        }
    }

    final Email email = Email(
      subject: subject,
      recipients: ['skaryna.labs@gmail.com'],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
    _showSnack('Дзякуй!');
  }

  @override
  void initState() {
    super.initState();

    _manager = WordsManager(context, _prefs, setState);
    _tutorialManager = TutorialManager(_prefs);
    _prefs.init().then((value) => {
          _manager.init(),
          if (_prefs.getTutorialPassed() != true)
            {
              _tutorialManager.createTutorial(),
              Future.delayed(const Duration(milliseconds: 1000),
                  () => _tutorialManager.showTutorial(context))
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title,
            key: _tutorialManager.appTitleKey,
            style: GoogleFonts.comfortaa()),
        actions: [
          IconButton(
            key: _tutorialManager.clockBtnKey,
            icon: const Icon(Icons.alarm_on_rounded),
            onPressed: _manager.configureUpdateTime,
          ),
          IconButton(
            key: _tutorialManager.collectionsBtnKey,
            icon: const Icon(Icons.collections_bookmark_rounded),
            onPressed: () {
              _manager.cleanBufferCollectionStates();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                  title: Text('Катэгорыі',
                      style: GoogleFonts.comfortaa(
                          fontSize: 24.sp, fontWeight: FontWeight.bold)),
                  content: CollectionsPopup(_manager.collections, _manager),
                ),
              );
            },
          ),
          PopupMenuButton<MailOption>(
            key: _tutorialManager.mailBtnKey,
            onSelected: (value) => _sendMail(value),
            position: PopupMenuPosition.under,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            icon: const Icon(Icons.mail),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<MailOption>>[
              PopupMenuItem<MailOption>(
                value: MailOption.suggestion,
                child: Row(children: [
                  Container(
                      padding: EdgeInsets.only(right: 5.w),
                      child: const Icon(FontAwesomeIcons.lightbulb)),
                  Text('Прапанова', style: GoogleFonts.comfortaa())
                ]),
              ),
              PopupMenuItem<MailOption>(
                  value: MailOption.bug,
                  child: Row(
                    children: [
                      Container(
                          padding: EdgeInsets.only(right: 5.w),
                          child: const Icon(FontAwesomeIcons.bug)),
                      Text(
                        'Памылка',
                        style: GoogleFonts.comfortaa(),
                      )
                    ],
                  )),
              PopupMenuItem<MailOption>(
                  value: MailOption.other,
                  child: Row(
                    children: [
                      Container(
                          padding: EdgeInsets.only(right: 5.w),
                          child: const Icon(Icons.mail)),
                      Text('Іншае', style: GoogleFonts.comfortaa())
                    ],
                  )),
            ],
          ),
          IconButton(
            key: _tutorialManager.thanksBtnKey,
            icon: const Icon(FontAwesomeIcons.peopleGroup),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    title: Row(children: [
                      const Icon(FontAwesomeIcons.heart),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text('Падзякі',
                          style: GoogleFonts.comfortaa(
                              fontSize: 24.sp, fontWeight: FontWeight.bold))
                    ]),
                    content: ThanksPopup(_manager)),
              );
            },
          )
        ],
      ),
      body: Stack(children: <Widget>[
        Align(
            alignment: Alignment.topRight,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                child: Switch(
                    thumbIcon: MaterialStateProperty.all(
                        widget.darkModeController.darkTheme
                            ? const Icon(FontAwesomeIcons.solidMoon)
                            : const Icon(FontAwesomeIcons.solidSun)),
                    value: widget.darkModeController.darkTheme,
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          widget.darkModeController.setValue(value);
                        });
                      }
                    }))),
        Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Text(
                '${_manager.activeWordsCount - _manager.restWordsCount} / ${_manager.activeWordsCount}',
                style: GoogleFonts.comfortaa(
                    fontWeight: FontWeight.w900, fontSize: 20.sp))),
        Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 80.h),
              _manager.restWordsCount <= 0
                  ? ElevatedButton.icon(
                      onPressed: _manager.reset,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: Text('Спачатку', style: GoogleFonts.comfortaa()))
                  : Container(),
              Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton.icon(
                      onPressed: () => launchUrlString(
                          'https://www.buymeacoffee.com/skarynalabs'),
                      icon: Icon(
                        Icons.coffee_maker_rounded,
                        size: 35.r,
                      ),
                      label: Text(
                        'Распрацоўшчыку\nна каву',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.comfortaa(fontSize: 14.sp),
                      ))),
              CardsStackWidget(
                  wordsManager: _manager,
                  cardKey: _tutorialManager.cardsStackKey),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                          left: 10.w, right: 10.w, top: 20.h, bottom: 10.h),
                      child: ElevatedButton.icon(
                          onPressed: () => {
                                if (_manager.currentWord != null)
                                  {
                                    _showSnack(
                                        'Пераклад: ${_manager.currentWord!.en}')
                                  }
                              },
                          icon: const Icon(FontAwesomeIcons.language),
                          label: const Text(' EN')),
                    ),
                    Container(
                        padding: EdgeInsets.only(
                            left: 10.w, right: 10.w, top: 20.h, bottom: 10.h),
                        child: ElevatedButton.icon(
                            onPressed: () => {
                                  if (_manager.currentWord != null)
                                    {
                                      _showSnack(
                                          'Пераклад: ${_manager.currentWord!.ru}')
                                    }
                                },
                            icon: const Icon(FontAwesomeIcons.language),
                            label: const Text(' RU')))
                  ]),
            ])
      ]),
      floatingActionButton: FloatingActionButton.large(
        key: _tutorialManager.dictionaryBtnKey,
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DictionaryScreen(_manager.savedWordsManager)),
          ),
        },
        tooltip: 'Слоўнік',
        child: const Icon(FontAwesomeIcons.book),
      ),
    );
  }
}
