import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:mova_cards/widgets/saved_word_card.dart';
import 'package:mova_cards/words_manager.dart';
import 'package:path_provider/path_provider.dart';

import 'saved_word.dart';

final log = Logger('SavedWordManager');

class SavedWordsManager {
  final Set<String> _wordStrings = {};
  final LinkedHashSet<SavedWord> _words = LinkedHashSet();
  final WordsManager _manager;
  final Function _wipeAllCallback;

  late File _saveFile;

  SavedWordsManager(this._manager, this._wipeAllCallback);

  void init() async {
    var supportDir = await getApplicationDocumentsDirectory();
    _saveFile = File('${supportDir.path}/savedData.json');

    if (_saveFile.existsSync()) {
      String content = _saveFile.readAsStringSync();
      try {
        List<dynamic> dynamicWords = jsonDecode(content);
        for (var word in dynamicWords) {
          var savedWord = SavedWord.fromJson(word);
          _words.add(savedWord);
          _wordStrings.add(savedWord.word);
        }

        log.info('Loaded from file: $_words');
      } catch (e) {
        log.shout(e);
        _saveFile.deleteSync();
      }
    } else {
      log.info('Save file doesn\'t exist');
    }
  }

  void addWord(String word) {
    var dateTime = DateTime.now();
    var savedWord = SavedWord(word, dateTime);
    if (_words.contains(savedWord)) {
      _words.remove(savedWord);
    }

    _words.add(savedWord);
    _wordStrings.add(word);

    String serialized =
        jsonEncode(_words.map((savedWord) => savedWord.toJson()).toList());
    log.info('Saving: $serialized');

    if (!_saveFile.existsSync()) {
      _saveFile.createSync();
    }
    _saveFile.writeAsString(serialized);
  }

  List<Widget> getWords() {
    return _words
        .map((word) => SavedWordCard(_manager, word))
        .toList()
        .reversed
        .toList();
  }

  void wipeAllConfirmation(BuildContext context,
      {Function? updateUICallback}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(20),
        actionsPadding: const EdgeInsets.all(5),
        title: Text('Вы ўпэўнены?',
            style: GoogleFonts.comfortaa(
                fontSize: 24, fontWeight: FontWeight.bold)),
        content: Text('Гісторыя будзе выдалена. Сгенеруецца 1 новае слова.',
            style: GoogleFonts.comfortaa(fontSize: 18)),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (updateUICallback != null) {
                  updateUICallback(() {
                    _wipeAll();
                  });
                } else {
                  _wipeAll();
                }
              },
              child: Text(
                'Так',
                style: GoogleFonts.comfortaa(),
              )),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Не', style: GoogleFonts.comfortaa())),
        ],
      ),
    );
  }

  void _wipeAll() {
    _wordStrings.clear();
    _words.clear();

    _saveFile.deleteSync();

    _wipeAllCallback();
  }

  Set<String> get getWordStrings => _wordStrings;
}
