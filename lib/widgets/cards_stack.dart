import 'package:flutter/material.dart';
import 'package:mova_cards/widgets/word_card.dart';
import 'package:mova_cards/words_manager.dart';

import 'drag_widget.dart';

class CardsStackWidget extends StatefulWidget {
  const CardsStackWidget(
      {required this.wordsManager, required this.cardKey, Key? key})
      : super(key: key);

  final WordsManager wordsManager;
  final GlobalKey cardKey;

  @override
  State<CardsStackWidget> createState() => _CardsStackWidgetState();
}

class _CardsStackWidgetState extends State<CardsStackWidget> {
  ValueNotifier<Swipe> swipeNotifier = ValueNotifier(Swipe.none);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ValueListenableBuilder(
          valueListenable: swipeNotifier,
          builder: (context, swipe, _) => Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: widget.wordsManager.allWordsCount > 0
                  ? <Widget>[
                      widget.wordsManager.restWordsCount > 0
                          ? SlideTransition(
                              position: const AlwaysStoppedAnimation(
                                  Offset(-0.03, 0.03)),
                              child:
                                  WordCard(word: widget.wordsManager.nextWord))
                          : Container(),
                      widget.wordsManager.restWordsCount > 0
                          ? DraggableCard(
                            widget.wordsManager,
                              key: widget.cardKey,
                              word: widget.wordsManager.currentWord,
                              swipeNotifier: swipeNotifier)
                          : WordCard(word: widget.wordsManager.currentWord, key: widget.cardKey),
                    ]
                  : <Widget>[]),
        ),
      ],
    );
  }
}
