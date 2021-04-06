import 'package:flutter/material.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';

class SmsDialog extends StatelessWidget {
  final String title, description, buttonText, smscode;
  final Image image;

  SmsDialog({
    @required this.title,
    this.description,
    @required this.buttonText,
    this.image,
    this.smscode
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    String retVal = '';
    return Stack(
      children: <Widget>[
        Container(
          width: 280.0,
          height: 300.0,
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(child: Row(
                children: <Widget>[
                  new Expanded(
                      child: new TextField(
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        decoration: new InputDecoration(
                          labelText: AppLocalizations.of(context).translate(
                              'sms_code'),
                        ),
                        onChanged: (value) {
                          retVal = value;
                        },
                      ))
                ],
              ),
                flex: 2,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop('');
                      },
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Variables.primaryColor,
                        ),
                        child: Text(
                          AppLocalizations.of(context).translate(
                              'big_cancel'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if(smscode==retVal) {
                          Navigator.of(context).pop(retVal);
                        }
                        else{
                          showDialog(
                            context: context,
                            builder: (_) =>
                                AlertDialog(
                                  title: Text(AppLocalizations.of(context).translate(
                                      'error')),
                                  content: Text(AppLocalizations.of(context).translate(
                                      'sms_incorrect')),
                                  actions: [
                                    TextButton(
                                      child: Text(AppLocalizations.of(context).translate(
                                          'big_ok'),
                                        style: TextStyle(
                                            color: Variables.primaryColor),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Variables.primaryColor,
                        ),
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),


              ),
            ],
          ),
        ),

        Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: CircleAvatar(
            backgroundColor: Variables.greyColor,
            radius: Consts.avatarRadius,
            child: Icon(Icons.sms, size: 64.0, color: Variables.primaryColor,),
          ),
        ),
      ],
    );
  }
}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}
