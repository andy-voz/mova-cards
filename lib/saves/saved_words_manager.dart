import 'dart:collection';
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
const int currentVersion = 3;

const savesFileName = 'savedData.txt';

class SavedWordsManager {
  final Set<String> _wordIds = {};
  final LinkedHashSet<SavedWord> _words = LinkedHashSet();
  final WordsManager _manager;
  final Function _wipeAllCallback;

  late File _saveFile;

  SavedWordsManager(this._manager, this._wipeAllCallback);

  void init() async {
    var supportDir = await getApplicationDocumentsDirectory();
    _saveFile = File('${supportDir.path}/$savesFileName');

    if (_saveFile.existsSync()) {
      String content = _saveFile.readAsStringSync();
      List<String> lines = content.split('\n');
      String version = lines[0];
      int? savedVersion = int.tryParse(version);
      if (savedVersion == null || savedVersion < currentVersion) {
        log.warning(
            'Wiping data. Old save has a lower version or incorrect format: $savedVersion Current: $currentVersion');
        _wipeAll();
        return;
      }

      for (int i = 1; i < lines.length; ++i) {
        try {
          var savedWord = SavedWord.read(lines[i].split(SavedWord.separator));

          _words.add(savedWord);
          _wordIds.add(savedWord.id);
        } catch (e) {
          log.shout('Failed to read a saved word!', e);
          continue;
        }
      }

      log.info('Loaded from file: $_words');
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

    String line = savedWord.write();
    log.info('Saving: $line');

    if (!_saveFile.existsSync()) {
      _saveFile.createSync();
      _saveFile.writeAsStringSync('$currentVersion\n');
    }

    // Appending only the word itself, so the write operation is expected to be pretty fast.
    _saveFile.writeAsStringSync('$line\n', mode: FileMode.append);
  }

  List<Widget> getWords() {
    return _words
        .map((word) => SavedWordCard(_manager, word))
        .toList()
        .reversed
        .toList();
  }

  void wipeAllConfirmation(BuildContext context, {Function? updateUICallback}) {
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
