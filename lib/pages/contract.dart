import 'package:flutter/material.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ContractPage extends StatefulWidget {
  @override
  _ContractPageState createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Variables.primaryColor,
        centerTitle: true,
        title: Text(AppLocalizations.of(context).translate('contract_title')),
      ),
      body: WebView(
        initialUrl: 'http://www.klinix.com.tr/sozlesme.html',
        gestureNavigationEnabled: true,
        javascriptMode: JavascriptMode.unrestricted,
      ),
      bottomNavigationBar: Container(
        height: 64,
        padding: EdgeInsets.only(bottom: 16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Variables.primaryColor),
          child: Text(
            'Onaylıyorum',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
