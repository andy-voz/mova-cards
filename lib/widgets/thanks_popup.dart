import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mova_cards/words_manager.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ThanksPopup extends StatelessWidget {
  final WordsManager _manager;

  const ThanksPopup(this._manager, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
            child: Text('Натхненне',
                style: GoogleFonts.comfortaa(
                    fontSize: 16.sp, fontWeight: FontWeight.bold))),
        Center(
            child: InkWell(
                child: Text(
                  'Мова Нанова',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comfortaa(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp),
                ),
                onTap: () =>
                    {launchUrlString('https://uroki.movananova.by/')})),
        SizedBox(
          height: 10.h,
        ),
        Center(
            child: Text('Малюнкі',
                style: GoogleFonts.comfortaa(
                    fontSize: 16.sp, fontWeight: FontWeight.bold))),
        Center(
            child: InkWell(
                child: Text(
                  'Pixabay',
                  style: GoogleFonts.comfortaa(
                      color: Colors.red,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold),
                ),
                onTap: () => {launchUrlString('https://pixabay.com/')})),
        SizedBox(height: 50.h),
        Center(
            child: TextButton.icon(
                onPressed: () => _manager.openStorePage(),
                icon: const Icon(Icons.star_rate_rounded),
                label: Text('Ацаніць',
                    style: GoogleFonts.comfortaa(fontSize: 18.sp)))),
        SizedBox(height: 5.h),
        Align(
            alignment: Alignment.center,
            child: Text('Распрацавана з любовью',
                textAlign: TextAlign.center,
                style: GoogleFonts.comfortaa(fontSize: 16.sp))),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('by ', style: GoogleFonts.comfortaa(fontSize: 16.sp)),
          Text('Skaryna',
              style: GoogleFonts.comfortaa(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
          Text('Labs',
              style: GoogleFonts.comfortaa(
                  fontSize: 16.sp, fontWeight: FontWeight.bold)),
        ]),
      ],
    );
  }
}
