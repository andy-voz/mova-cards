import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/utils.dart';
import '../word.dart';

class WordCard extends StatelessWidget {
  final Word? word;
  const WordCard({Key? key, required this.word}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: WordCardContent(word: word));
  }
}

class WordCardContent extends StatelessWidget {
  final Word? word;
  const WordCardContent({Key? key, required this.word}) : super(key: key);

  // -----------------------------------
  // WARNING
  // We intentionally scale by heights here. Because our card should always stay ~square.
  // -----------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
            width: 270.h,
            height: 70.h,
            padding: EdgeInsets.only(
                left: 10.h, right: 10.h, top: 10.h, bottom: 5.h),
            child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  word != null ? word!.word : "",
                  softWrap: false,
                  style: GoogleFonts.comfortaa(fontWeight: FontWeight.bold),
                ))),
        GestureDetector(
            onTap: () {
              if (word != null) goToDefinition(word!.word);
            },
            child: Stack(children: [
              SizedBox(
                  width: 270.h,
                  height: 250.h,
                  child: Center(
                    child: Container(
                        padding: EdgeInsets.only(
                            left: 16.h, right: 16.h, top: 5.h, bottom: 16.h),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: word != null
                                ? Image.asset(
                                    imgAssetsDir + word!.imgPath(),
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        const Icon(Icons.warning_amber_rounded),
                                  )
                                : const Icon(Icons.warning_amber_rounded))),
                  )),
              SizedBox(
                  width: 250.h,
                  height: 230.h,
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: Opacity(
                          opacity: 0.7,
                          child: Icon(
                            Icons.touch_app,
                            size: 50.r,
                            color: Colors.white,
                          ))))
            ])),
      ],
    );
  }
}
