import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final Function press;

  const CategoryItem({
    Key key,
    @required this.context,
    this.title,
    this.isActive = false,
    this.press,
  }) : super(key: key);

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
            Text(
              title,
              style: isActive
                  ? TextStyle(
                      color: Color(Styling.textColor),
                      fontSize: SizeConfig.diagonal * 3,
                      fontWeight: FontWeight.bold,
                    )
                  : TextStyle(
                      color: Color(Styling.textColor).withOpacity(0.30),
                      fontSize: SizeConfig.diagonal * 3,
                    ),
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
