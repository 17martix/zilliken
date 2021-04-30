import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:flutter/material.dart';

import 'ZText.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final press;

  const CategoryItem({
    required this.context,
    required this.title,
    this.isActive = false,
    this.press,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return InkWell(
      onTap: press,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.diagonal * 1.1,
          vertical: SizeConfig.diagonal * 1.1,
        ),
        child: Column(
          children: [
            ZText(
              content: title,
              color: isActive
                  ? Color(Styling.textColor)
                  : Color(Styling.textColor).withOpacity(0.30),
              fontSize:
                  isActive ? SizeConfig.diagonal * 3 : SizeConfig.diagonal * 3,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            if (isActive)
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: SizeConfig.diagonal * 0.2,
                ),
                height: 1,
                width: 22,
                decoration: BoxDecoration(
                  color: Color(Styling.accentColor),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
