import 'dart:convert';

import 'package:flutter/foundation.dart';
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

  /// All words collection where
  /// key - word ID
  /// value - word data.
  final Map<String, Word> _allWords = {};

  /// List of all word collections
  final List<Collection> _collections = [];

  /// The user can turn on/off some collections, so we'll skip them while picking a new word.
  final Map<String, bool> _collectionsState = {};

  /// When the user is editing active collections, we put all changes to this buffet and apply them
  /// only when the user explicitly clicks "OK".
  final Map<String, bool> _bufferCollectionsState = {};
  final InAppReview inAppReview = InAppReview.instance;

  late WordUpdateController _wordUpdateController;

  late SavedWordsManager _savedWordsManager;

  get savedWordsManager => _savedWordsManager;

  Word? _currentWord;
  Word? _nextWord;

  /// Ids of the words we've never shown to the user.
  List<String> _restWordIds = [];

  /// Ids of all words from active collection regardless of were they shown to the user before or not.
  Set<String> _activeWordIds = {};

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

      _restWordIds.removeLast();

      _nextWord = _getNextWord();
      _prefs.setLastUpdateTime(DateTime.now().millisecondsSinceEpoch);

      var messenger = ScaffoldMessenger.of(_context);
      messenger.clearSnackBars();

      if (currentWord != null) {
        _savedWordsManager.addWord(currentWord!.id);
        if (_savedWordsManager.getWordIds.length % 50 == 0 &&
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

  int get activeWordsCount => _activeWordIds.length;

  int get restWordsCount => _restWordIds.length;

  Word? _getNextWord() {
    if (_restWordIds.isEmpty) return null;

    return _allWords[_restWordIds.last];
  }

  Future _loadCollections() async {
    _collections.clear();

    Stopwatch? watch;
    if (kDebugMode) {
      watch = Stopwatch();
      watch.start();
    }
    var assets = DefaultAssetBundle.of(_context);
    String data = await assets.loadString('assets/cooked/combined.json');
    List<dynamic> collections = await jsonDecode(data)['collections'];

    for (var collectionData in collections) {
      var collection = Collection.fromJson(collectionData);
      _collections.add(collection);

      _collectionsState[collection.name] =
          _prefs.getCollectionState(collection.name);

      _allWords.addAll(collection.words);

      log.info('Loaded: ${collection.name}');
    }

    _initActiveCollections(false);

    if (kDebugMode) {
      watch?.stop();
      log.info('Elapsed: ${watch?.elapsedMilliseconds}');
    }
  }

  void _initActiveCollections(bool goToNext) {
    Set<String> savedWordIds = _savedWordsManager.getWordIds;
    _activeWordIds = activeCollections()
        .expand((collection) => collection.words.keys)
        .toSet();

    _restWordIds =
        _activeWordIds.where((word) => !savedWordIds.contains(word)).toList();
    _restWordIds.shuffle();

    if (goToNext) {
      _nextWord = null;
      goToNextWord();
    }
  }

  void _generate() async {
    bool needUpdate = true;
    if (_wordUpdateController.alreadyUpdated() || restWordsCount <= 0) {
      String? savedCurrentWord = _savedWordsManager.getLastSavedWord;
      if (savedCurrentWord != null) {
        _currentWord = _allWords[savedCurrentWord];
      }

      _nextWord = _getNextWord();

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
