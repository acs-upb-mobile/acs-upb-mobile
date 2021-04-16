import 'package:acs_upb_mobile/pages/classes/model/class.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';

extension ClassExtension on ClassHeader {
  Color get colorFromAcronym {
    int r = 0, g = 0, b = 0;
    if (acronym.isNotEmpty) {
      b = acronym[0].codeUnitAt(0);
      if (acronym.length >= 2) {
        g = acronym[1].codeUnitAt(0);
        if (acronym.length >= 3) {
          r = acronym[2].codeUnitAt(0);
        }
      }
    }
    const int brightnessFactor = 2;
    return Color.fromRGBO(
        r * brightnessFactor, g * brightnessFactor, b * brightnessFactor, 1);
  }
}

class ClassIcon extends StatelessWidget {
  const ClassIcon({
    @required this.classHeader,
    Key key,
    this.selected = false,
  }) : super(key: key);

  final ClassHeader classHeader;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: classHeader.colorFromAcronym,
      child: Container(
        width: 30,
        child: selected
            ? Icon(
                Icons.check_outlined,
                color: classHeader.colorFromAcronym.highEmphasisOnColor,
              )
            : Align(
                alignment: Alignment.center,
                child: AutoSizeText(
                  classHeader.acronym,
                  minFontSize: 0,
                  maxLines: 1,
                  style: TextStyle(
                    color: classHeader.colorFromAcronym.highEmphasisOnColor,
                  ),
                ),
              ),
      ),
    );
  }
}
