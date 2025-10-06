import 'package:flutter/material.dart';
import '../constants.dart';

class AppTitle extends StatelessWidget {
  final double? logoSize;
  final double? titleFontSize;
  final String titleText;
  final double spacing;

  const AppTitle({
    super.key,
    this.logoSize,
    this.titleFontSize,
    this.titleText = 'HAUrmony',
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('lib/assets/haurmony.png', width: logoSize ?? kLogoSize, height: logoSize ?? kLogoSize),
        SizedBox(width: spacing),
        Text(
          titleText,
          style: TextStyle(
            color: kLogoColor,
            fontWeight: FontWeight.bold,
            fontSize: titleFontSize ?? kTitleFontSize,
          ),
        ),
      ],
    );
  }
}