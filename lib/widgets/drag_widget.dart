import 'package:flutter/material.dart';
import 'package:mova_cards/widgets/word_card.dart';
import 'package:mova_cards/words_manager.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

import '../word.dart';

enum Swipe { left, right, none }

class DraggableCard extends StatefulWidget {
  const DraggableCard(this._manager,
      {Key? key, required this.word, required this.swipeNotifier})
      : super(key: key);
  final Word? word;
  final ValueNotifier<Swipe> swipeNotifier;
  final WordsManager _manager;

  @override
  State<DraggableCard> createState() => DraggableCardState();
}

class DraggableCardState extends State<DraggableCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _rotationAnimationController;
  CurvedAnimation? _curvedAnimation;

  ValueNotifier<Swipe> swipeNotifier = ValueNotifier(Swipe.none);
  ValueNotifier<double> opacityNotifier = ValueNotifier(1.0);

  Swipe _prevSwipe = Swipe.none;
  Offset _startPosition = Offset.zero;
  bool _goToNext = false;

  final _turnTweensLeft = Tween<double>(begin: 0, end: -15 / 360);
  final _turnTweensRight = Tween<double>(begin: 0, end: 15 / 360);

  void changeOpacity(double opacity) {
    if (opacity == opacityNotifier.value) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      opacityNotifier.value = opacity;
    });
  }

  @override
  void initState() {
    super.initState();
    _rotationAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _curvedAnimation = CurvedAnimation(
        parent: _rotationAnimationController!, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _rotationAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    opacityNotifier.value = 1;
    return Center(
      child: Draggable<DraggableCardState>(
        axis: Axis.horizontal,
        // Data is the value this Draggable stores.
        data: this,
        feedback: MultiValueListenableBuilder(
          valueListenables: [swipeNotifier, opacityNotifier],
          builder: (context, values, _) {
            Swipe swipe = values[0];

            // We can get here if only opacity value changed.
            // In this case we don't need to re-play the animation.
            if (_prevSwipe != swipe) {
              _rotationAnimationController?.reset();

              if (swipe != Swipe.none) {
                _rotationAnimationController?.forward();
              }

              _prevSwipe = swipe;
            }

            double opacity = values[1];

            return RotationTransition(
                turns: swipe != Swipe.none
                    ? swipe == Swipe.left
                        ? _turnTweensLeft.animate(_curvedAnimation!)
                        : _turnTweensRight.animate(_curvedAnimation!)
                    : const AlwaysStoppedAnimation(0),
                child: Opacity(
                    opacity: opacity, child: WordCard(word: widget.word)));
          },
        ),
        onDragStarted: () => {_startPosition = Offset.zero, _goToNext = false},
        onDragUpdate: (DragUpdateDetails dragUpdateDetails) {
          // When Draggable widget is dragged right
          if (dragUpdateDetails.delta.dx > 0 &&
              dragUpdateDetails.globalPosition.dx >
                  MediaQuery.of(context).size.width / 2) {
            swipeNotifier.value = Swipe.right;
          }
          // When Draggable widget is dragged left
          if (dragUpdateDetails.delta.dx < 0 &&
              dragUpdateDetails.globalPosition.dx <
                  MediaQuery.of(context).size.width / 2) {
            swipeNotifier.value = Swipe.left;
          }

          if (_startPosition == Offset.zero) {
            _startPosition = dragUpdateDetails.globalPosition;
            return;
          }

          if ((_startPosition - dragUpdateDetails.globalPosition).dx.abs() >
              80) {
            changeOpacity(0.5);
            _goToNext = true;
          } else {
            changeOpacity(1);
            _goToNext = false;
          }
        },
        onDragEnd: (drag) {
          swipeNotifier.value = Swipe.none;
          _prevSwipe = Swipe.none;

          if (_goToNext) {
            widget._manager.goToNextWord();
          }
        },

        childWhenDragging: Container(
          color: Colors.transparent,
        ),

        child: WordCard(word: widget.word),
      ),
    );
  }
}
