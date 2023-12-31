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

/// If we need to reset users saves for any reason, just need to up this version.
const int currentVersion = 2;

const String versionKey = 'version';
const String wordsKey = 'words';

class SavedWordsManager {
  final Set<String> _wordIds = {};
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
        var saveData = jsonDecode(content);
        if (saveData is Map)
        {
          // Now we can check the save version
          int saveVersion = saveData['version'];
          if (currentVersion > saveVersion)
          {
            log.warning('Wiping data. Old save has a lower version: $saveVersion Current: $currentVersion');
            _wipeAll();
            return;
          }
        }
        else
        {
          // In old saves we used a List.
          log.warning('Old save detected, wiping data.');
          _wipeAll();
          return;
        }

        List<dynamic> words = saveData['words'];

        for (var word in words) {
          var savedWord = SavedWord.fromJson(word);
          _words.add(savedWord);
          _wordIds.add(savedWord.id);
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

  void addWord(String id) {
    var dateTime = DateTime.now();
    var savedWord = SavedWord(id, dateTime);
    if (_words.contains(savedWord)) {
      _words.remove(savedWord);
    }

    _words.add(savedWord);
    _wordIds.add(id);

    Map<String, dynamic> saveData = {
      versionKey: currentVersion,
      wordsKey: _words.map((savedWord) => savedWord.toJson()).toList()
    };

    String serialized = jsonEncode(saveData);
    log.info('Saving: ${_saveFile.path} | $serialized');

    if (!_saveFile.existsSync()) {
      _saveFile.createSync();
    }

    // TODO: It looks too heavy to rewrite the whole save when the user swipes a word.
    // Require a better solution
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
    _wordIds.clear();
    _words.clear();

    _saveFile.deleteSync();

    _wipeAllCallback();
  }

  Set<String> get getWordIds => _wordIds;
}
