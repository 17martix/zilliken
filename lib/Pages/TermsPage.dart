import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zilliken/Components/ZAppBar.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';

import '../i18n.dart';

class TermsPage extends StatefulWidget {
  final Authentication auth;
  final Database db;

  TermsPage({
    required this.auth,
    required this.db,
  });

  @override
  _TermsPageState createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool _isLoading = true;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: buildAppBar(
        context,
        widget.auth,
        true,
        null,
        null,
        null,
        null,
      ),
      body: body(),
    );
  }

  Widget body() {
    return Stack(
      children: [
        WebView(
          initialUrl: Localizations.localeOf(context).languageCode == 'fr'
              ? 'https://isumiro.com/fr/politique-de-confidentialite/'
              : 'https://isumiro.com/privacy-policy/',
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
        if (_isLoading)
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(Styling.accentColor)),
            ),
          )
      ],
    );
  }
}
