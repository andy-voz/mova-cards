import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mova_cards/words_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../collections/collection.dart';
import '../utils/utils.dart';

class CollectionToggle extends StatefulWidget {
  final Collection _collection;
  final WordsManager _manager;

  const CollectionToggle(this._collection, this._manager, {super.key});

  @override
  State<StatefulWidget> createState() {
    return CollectionToggleState();
  }
}

class CollectionToggleState extends State<CollectionToggle> {
  void _setCollectionState(bool state) {
    setState(() {
      if (!widget._manager.setCollectionState(widget._collection.name, state)) {
        Fluttertoast.cancel();
        Fluttertoast.showToast(
            msg: "Як мінімум адна катэгорыя павінна быць актыўнай :)",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
          
      child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imgAssetsDir + widget._collection.backImg),
                fit: BoxFit.cover,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          height: 80.h,
          child: Stack(
            children: <Widget>[
                         Container(
                width: 200.w,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    gradient: LinearGradient(colors: [
                      Colors.black54,
                      Colors.transparent,
                    ]))),
              Align(
                  alignment: Alignment.centerLeft,
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Container(
                        padding: const EdgeInsets.only(left: 10),
                        width: 200.w,
                        child: FittedBox(
                            alignment: Alignment.bottomLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget._collection.name,
                              softWrap: false,
                              style: GoogleFonts.comfortaa(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    const Shadow(
                                        color: Colors.red,
                                        offset: Offset(1, 1),
                                        blurRadius: 1)
                                  ]),
                            ))),
                    Container(
                        padding: const EdgeInsets.only(left: 10),
                        width: 200.w,
                        height: 20.h,
                        child: (FittedBox(
                            alignment: Alignment.bottomLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Словаў: ${widget._collection.words.length}',
                              textAlign: TextAlign.left,
                              softWrap: false,
                              style: GoogleFonts.comfortaa(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ))))
                  ])),
              Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Switch(
                          value: widget._manager
                              .getCollectionState(widget._collection.name),
                          onChanged: (state) => _setCollectionState(state))))
            ],
          )),
    );
  }
}
