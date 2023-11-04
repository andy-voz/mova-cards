import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:logging/logging.dart';
import 'package:mova_cards/saves/saved_words_manager.dart';
import 'package:mova_cards/utils/prefs.dart';
import 'package:mova_cards/utils/word_update_controller.dart';
import 'package:mova_cards/word.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'collections/collection.dart';

final log = Logger('WordsManager');

class WordsManager {
  final BuildContext _context;
  final Prefs _prefs;
  final Function _updateUICallback;
  final Map<String, Word> _allWords = {};
  final List<Collection> _collections = [];
  final Map<String, bool> _collectionsState = {};
  final Map<String, bool> _bufferCollectionsState = {};
  final InAppReview inAppReview = InAppReview.instance;

  late WordUpdateController _wordUpdateController;

  late SavedWordsManager _savedWordsManager;
  get savedWordsManager => _savedWordsManager;

  Word? _currentWord;
  Word? _nextWord;

  List<String> _restWords = [];
  Set<String> _activeWords = {};

  WordsManager(this._context, this._prefs, this._updateUICallback);

  void init() async {
    initializeDateFormatting('be', null);

    _savedWordsManager =
        SavedWordsManager(this, () => _initActiveCollections(true));
    _savedWordsManager.init();

    _wordUpdateController =
        WordUpdateController(_context, _prefs, goToNextWord);
    _wordUpdateController.init();

    _loadCollections().then((value) => _generate());
  }

  void configureUpdateTime() {
    _wordUpdateController.configureUpdateTime();
  }

  void goToNextWord() {
    _updateUICallback(() {
      if (restWordsCount <= 0) {
        return;
      }

      _nextWord ??= _getNextWord();
      _currentWord = nextWord;

      _restWords.removeLast();

      _nextWord = _getNextWord();

      _prefs.setCurrentWord(_currentWord!);
      _prefs.setNextWord(_nextWord);
      _prefs.setLastUpdateTime(DateTime.now().millisecondsSinceEpoch);

      var messenger = ScaffoldMessenger.of(_context);
      messenger.clearSnackBars();

      if (currentWord != null) {
        _savedWordsManager.addWord(currentWord!.word);
        if (_savedWordsManager.getWordStrings.length % 100 == 0 &&
            _prefs.getRateUsShowed() != true) {
          showRateAs();
          _prefs.setRateUsShowed();
        }
      }
    });
  }

  void showRateAs() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  void openStorePage() async {
    inAppReview.openStoreListing();
  }

  void reset() {
    _savedWordsManager.wipeAllConfirmation(_context);
  }

  bool getCollectionState(String collectionName) {
    return _bufferCollectionsState.containsKey(collectionName)
        ? _bufferCollectionsState[collectionName]!
        : _collectionsState[collectionName]!;
  }

  bool setCollectionState(String collectionName, bool state) {
    _bufferCollectionsState[collectionName] = state;
    bool atLeastOneActive = false;

    for (String key in _collectionsState.keys) {
      if (getCollectionState(key)) {
        atLeastOneActive = true;
        break;
      }
    }

    if (!atLeastOneActive) {
      _bufferCollectionsState[collectionName] = !state;
      return false;
    }

    return true;
  }

  void cleanBufferCollectionStates() {
    _bufferCollectionsState.clear();
  }

  void updateCollections() {
    bool needUpdate = false;

    for (var entry in _bufferCollectionsState.entries) {
      if (_collectionsState[entry.key] != entry.value) {
        _collectionsState[entry.key] = entry.value;
        _prefs.setCollectionState(entry.key, entry.value);
        needUpdate = true;
      }
    }
    _bufferCollectionsState.clear();

    if (needUpdate) {
      _initActiveCollections(true);
    }
  }

  List<Collection> activeCollections() {
    return _collections
        .where((collection) => _collectionsState[collection.name]!)
        .toList();
  }

  Word? findWord(String word) {
    return _allWords[word];
  }

  List<Collection> get collections => _collections;

  Word? get currentWord => _currentWord;
  Word? get nextWord => _nextWord;
  int get allWordsCount => _allWords.length;
  int get activeWordsCount => _activeWords.length;
  int get restWordsCount => _restWords.length;

  Word? _getNextWord() {
    if (_restWords.isEmpty) return null;

    return _allWords[_restWords.last];
  }

  Future _loadCollections() async {
    _collections.clear();

    var assets = DefaultAssetBundle.of(_context);
    String data = await assets.loadString('assets/words-collections/base.json');
    List<dynamic> collections = await jsonDecode(data)['collections'];

    for (var collectionInfo in collections) {
      String? collectionPath = collectionInfo['path'];
      if (collectionPath == null) continue;

      String collectionData = await assets.loadString(collectionPath);
      var collection = Collection.fromJson(jsonDecode(collectionData));
      _collections.add(collection);

      _collectionsState[collection.name] =
          _prefs.getCollectionState(collection.name);

      _allWords.addAll(collection.words);

      log.info('Loaded: $collectionPath');
    }

    _initActiveCollections(false);
  }

  void _initActiveCollections(bool goToNext) {
    Set<String> savedWords = _savedWordsManager.getWordStrings;
    _activeWords = activeCollections()
        .expand((collection) => collection.words.keys)
        .toSet();

    _restWords =
        _activeWords.where((word) => !savedWords.contains(word)).toList();
    _restWords.shuffle();

    if (goToNext) {
      _nextWord = null;
      goToNextWord();
    }
  }

  void _generate() async {
    bool needUpdate = true;
    if (_wordUpdateController.alreadyUpdated()) {
      String? savedCurrentWord = _prefs.getCurrentWord();
      String? savedNextWord = _prefs.getNextWord();
      if (savedCurrentWord != null) {
        _currentWord = _allWords[savedCurrentWord];
      }

      if (savedNextWord != null) {
        _nextWord = _allWords[savedNextWord];
      }

      needUpdate = _currentWord == null;
      if (!needUpdate) {
        _updateUICallback(() {});
      }
    }

    if (needUpdate) {
      goToNextWord();
    }
  }
}
