import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mova_cards/saves/saved_words_manager.dart';

class DictionaryScreen extends StatefulWidget {
  final SavedWordsManager _savedWordsManager;

  const DictionaryScreen(this._savedWordsManager, {super.key});

  @override
  State<StatefulWidget> createState() {
    return DictionaryScreenState();
  }
}

class DictionaryScreenState extends State<DictionaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Папярэднія словы',
            style: GoogleFonts.comfortaa(fontSize: 20)),
        actions: widget._savedWordsManager.getWords().isNotEmpty
            ? [
                IconButton(
                    onPressed: () {
                      widget._savedWordsManager
                          .wipeAllConfirmation(context, updateUICallback: setState);
                    },
                    icon: const Icon(FontAwesomeIcons.trashCan))
              ]
            : [],
      ),
      body: Center(
          child: Stack(children: <Widget>[
        Container(
            margin: const EdgeInsets.only(top: 40),
            child: ListView(children: widget._savedWordsManager.getWords())),
        Container(
            height: 40,
            alignment: Alignment.center,
            child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              const Icon(
                Icons.book_rounded,
                size: 30,
              ),
              Text(
                  style: GoogleFonts.comfortaa(fontSize: 18),
                  '${widget._savedWordsManager.getWords().length}')
            ])),
      ])),
    );
  }
}
