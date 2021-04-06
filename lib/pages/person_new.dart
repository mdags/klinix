import 'dart:convert';
import 'package:date_field/date_field.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:klinix/models/membersModel.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:progress_dialog/progress_dialog.dart';

class PersonNewPage extends StatefulWidget {
  @override
  _PersonNewPageState createState() => _PersonNewPageState();
}

class _PersonNewPageState extends State<PersonNewPage> {
  ProgressDialog pr;
  final _formKey = GlobalKey<FormState>();
  final adController = new TextEditingController();
  final soyadController = new TextEditingController();
  final tcknController = new TextEditingController();
  final gsmController = new TextEditingController();

  //DateTime dogumTarihi = DateTime.now();
  List<String> birthDays = [],
      birthMonths = [],
      birthYears = [];
  String bday = DateTime
      .now()
      .day
      .toString()
      .padLeft(2, '0'),
      bmonth = DateTime
          .now()
          .month
          .toString()
          .padLeft(2, '0'),
      byear = DateTime
          .now()
          .year
          .toString();

  Future<void> checkMember() async {
    var res = await http.get(
      Variables.url + '/checkMember?tckn=' + tcknController.text,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'bearer ' + Variables.accessToken
      },
    );
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      List<MembersModel> memberList = decodeList.map((i) =>
          MembersModel.fromJson(i)).toList();
      if (memberList.length == 0) {
        register();
      }
      else {
        _showDialog(AppLocalizations.of(context).translate(
            'error'), AppLocalizations.of(context).translate(
            'exists_member_error'));
      }
    }
  }

  Future<void> register() async {
    await pr.show();

    var res = await http.get(
      Variables.url + '/kimlikDogrula?tckn=' + tcknController.text +
          '&ad=' + adController.text +
          '&soyad=' + soyadController.text +
          '&dogumTarihi=' + bday + '.' + bmonth + '.' + byear,
      //DateFormat('dd.MM.yyyy').format(dogumTarihi).toString(),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'bearer ' + Variables.accessToken
      },
    );
    if (res.statusCode == 200) {
      var result = res.body.split('"').join('');
      if (result == "true") {
        MembersModel member = new MembersModel(
            mMEMID: Variables.memberId,
            name: adController.text + ' ' + soyadController.text,
            tCKN: tcknController.text,
            gSM: gsmController.text,
            bDate: byear+'-'+bmonth+'-'+bday
        );
        var body = json.encode(member.toMap());
        res = await http.post(
            Variables.url + '/addMember',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'bearer ' + Variables.accessToken
            },
            body: body);
        if (res.statusCode == 200) {
          var memberId = res.body.split('"').join('');

          await pr.hide();
          Navigator.of(context).pop();
        }
        else {
          await pr.hide();

          String errorMessage = AppLocalizations.of(context).translate(
              'register_error') + '\n' +
              res.statusCode.toString() + ': ' +
              res.reasonPhrase;
          _showDialog(AppLocalizations.of(context).translate(
              'error'), errorMessage);
        }
      }
      else {
        await pr.hide();

        _showDialog(AppLocalizations.of(context).translate(
            'error'), AppLocalizations.of(context).translate(
            'identity_number_incorrect'));
      }
    }
  }

  @override
  void initState() {
    for (int i = 1; i < 32; i++) {
      birthDays.add(i.toString().padLeft(2, '0'));
    }
    for (int i = 1; i < 13; i++) {
      birthMonths.add(i.toString().padLeft(2, '0'));
    }
    for (int i = 0; i < 121; i++) {
      birthYears.add((1900 + i).toString());
    }

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: false);
    pr.style(message: AppLocalizations.of(context).translate('please_wait'), progressWidget: Image.asset('assets/images/loading.gif'));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Container(
          padding: EdgeInsets.all(26.0),
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/sidemenu_background.png'),
                  fit: BoxFit.cover)
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Image.asset(
                      'assets/images/back_red.png', color: Colors.white,
                      width: 24.0,
                      height: 24.0,),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                Container(
                    child: Image.asset('assets/images/logo_white.png'),
                    width: 180
                ),
                SizedBox(
                  height: 20,
                ),
                formWidget(),
                SizedBox(
                  height: 10.0,
                ),
                // Text(AppLocalizations.of(context).translate(
                //     'activation'),
                //   style: TextStyle(color: Colors.white, fontSize: 11.0),
                // ),
                Spacer(),
                Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/tab_phone.png', color: Colors.white,
                        width: 24.0,
                        height: 24.0,),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text('0850 2 555 112',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget formWidget() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextFormField(
                  controller: adController,
                  cursorColor: Colors.white,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate(
                          'register_name'),
                      labelStyle: TextStyle(color: Colors.white),
                      fillColor: Colors.white38,
                      filled: true,
                      errorStyle: TextStyle(
                        color: Colors.white,
                      )
                  ),
                  style: TextStyle(
                      color: Colors.white
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return AppLocalizations.of(context).translate(
                          'register_name_error');
                    }
                    else {
                      return null;
                    }
                  },
                ),
              ),

              SizedBox(
                width: 5.0,
              ),

              Expanded(
                child: TextFormField(
                  controller: soyadController,
                  cursorColor: Colors.white,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate(
                          'register_surname'),
                      labelStyle: TextStyle(color: Colors.white),
                      fillColor: Colors.white38,
                      filled: true,
                      errorStyle: TextStyle(
                        color: Colors.white,
                      )
                  ),
                  style: TextStyle(
                      color: Colors.white
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return AppLocalizations.of(context).translate(
                          'register_surname_error');
                    }
                    else {
                      return null;
                    }
                  },
                ),
              ),
            ],
          ),

          SizedBox(
            height: 5,
          ),
          TextFormField(
            controller: tcknController,
            cursorColor: Colors.white,
            keyboardType: TextInputType.phone,
            maxLength: 11,
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate(
                    'identity_number'),
                labelStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white38,
                filled: true,
                counterText: '',
                errorStyle: TextStyle(
                  color: Colors.white,
                )
            ),
            style: TextStyle(
              color: Colors.white,
            ),
            validator: (value) {
              if (value.isEmpty) {
                return AppLocalizations.of(context).translate(
                    'identity_number_error');
              }
              else {
                return null;
              }
            },
          ),
          SizedBox(
            height: 5,
          ),
          TextFormField(
            controller: gsmController,
            cursorColor: Colors.white,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate(
                  'register_gsm'),
              labelStyle: TextStyle(color: Colors.white),
              fillColor: Colors.white38,
              filled: true,
              counterText: '',
              errorStyle: TextStyle(
                color: Colors.white,
              ),
              prefix: Text('+90', style: TextStyle(color: Colors.white),),
            ),
            style: TextStyle(
                color: Colors.white
            ),
            validator: (value) {
              if (value.isEmpty) {
                return AppLocalizations.of(context).translate(
                    'register_gsm_error');
              }
              else {
                return null;
              }
            },
          ),
          SizedBox(
            height: 5,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(AppLocalizations.of(context).translate('register_birthdate'),
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: bday,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate(
                        'day'),
                    hintStyle: TextStyle(color: Colors.white),
                    labelText: AppLocalizations.of(context).translate(
                        'day'),
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white38,
                    filled: true,
                    errorStyle: TextStyle(
                        color: Colors.white
                    ),
                  ),
                  icon: Image.asset(
                    'assets/images/dropdown.png', width: 18.0, height: 18.0,),
                  items: birthDays.map((value) {
                    return DropdownMenuItem<String>(
                        child: Text(value), value: value);
                  }).toList(),
                  validator: (value) =>
                  value == null ? AppLocalizations.of(context).translate(
                      'required_field') : null,
                  onChanged: (value) {
                    setState(() {
                      bday = value;
                    });
                  },
                  onTap: (){
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                ),
              ),

              SizedBox(width: 5.0,),

              Expanded(
                child: DropdownButtonFormField<String>(
                  value: bmonth,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate(
                        'month'),
                    hintStyle: TextStyle(color: Colors.white),
                    labelText: AppLocalizations.of(context).translate(
                        'month'),
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white38,
                    filled: true,
                    errorStyle: TextStyle(
                        color: Colors.white
                    ),
                  ),
                  icon: Image.asset(
                    'assets/images/dropdown.png', width: 18.0, height: 18.0,),
                  items: birthMonths.map((value) {
                    return DropdownMenuItem<String>(
                        child: Text(value), value: value);
                  }).toList(),
                  validator: (value) =>
                  value == null ? AppLocalizations.of(context).translate(
                      'required_field') : null,
                  onChanged: (value) {
                    setState(() {
                      bmonth = value;
                    });
                  },
                  onTap: (){
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                ),
              ),

              SizedBox(width: 5.0,),

              Expanded(
                child: DropdownButtonFormField<String>(
                  value: byear,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate(
                        'year'),
                    hintStyle: TextStyle(color: Colors.white),
                    labelText: AppLocalizations.of(context).translate(
                        'year'),
                    labelStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.white38,
                    filled: true,
                    errorStyle: TextStyle(
                        color: Colors.white
                    ),
                  ),
                  icon: Image.asset(
                    'assets/images/dropdown.png', width: 18.0, height: 18.0,),
                  items: birthYears.map((value) {
                    return DropdownMenuItem<String>(
                        child: Text(value), value: value);
                  }).toList(),
                  validator: (value) =>
                  value == null ? AppLocalizations.of(context).translate(
                      'required_field') : null,
                  onChanged: (value) {
                    setState(() {
                      byear = value;
                    });
                  },
                  onTap: (){
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                ),
              ),
            ],
          ),
          // DateTimeField(
          //   selectedDate: dogumTarihi,
          //   label: '',
          //   lastDate: DateTime(DateTime
          //       .now()
          //       .year + 1),
          //   mode: DateFieldPickerMode.date,
          //   dateFormat: DateFormat('dd.MM.yyyy'),
          //   decoration: InputDecoration(
          //       labelText: AppLocalizations.of(context).translate(
          //           'register_birthdate'),
          //       labelStyle: TextStyle(color: Colors.white),
          //       fillColor: Colors.white38,
          //       filled: true,
          //       errorStyle: TextStyle(
          //         color: Colors.white,
          //       )
          //   ),
          //   textStyle: TextStyle(
          //       color: Colors.white
          //   ),
          //   onDateSelected: (DateTime date) {
          //     FocusScope.of(context).requestFocus(FocusNode());
          //     setState(() {
          //       dogumTarihi = date;
          //     });
          //   },
          // ),
          SizedBox(
            height: 5,
          ),
          // CheckboxListTile(
          //   title: Text(AppLocalizations.of(context).translate(
          //       'conract_approve'),
          //     style: TextStyle(color: Colors.white, fontSize: 11.0,),
          //   ),
          //   value: _sozlesme,
          //   controlAffinity: ListTileControlAffinity.leading,
          //   onChanged: (newValue) {
          //     setState(() {
          //       _sozlesme = newValue;
          //     });
          //   },
          // ),
          // SizedBox(
          //   height: 10.0,
          // ),
          // Text(AppLocalizations.of(context).translate(
          //     'information_confirm'),
          //   style: TextStyle(color: Colors.white, fontSize: 11.0,),
          // ),
          // SizedBox(
          //   height: 5.0,
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     InkWell(
          //       child: Row(
          //         children: [
          //           Radio(
          //             value: 1,
          //             activeColor: Colors.white,
          //             groupValue: _radioValue,
          //             onChanged: (newValue) {
          //               setState(() {
          //                 _radioValue = newValue;
          //               });
          //             },
          //           ),
          //           Text(AppLocalizations.of(context).translate(
          //               'yes'), style: TextStyle(color: Colors.white),)
          //         ],
          //       ),
          //       onTap: () {
          //         setState(() {
          //           _radioValue = 1;
          //         });
          //       },
          //     ),
          //     InkWell(
          //       child: Row(
          //         children: [
          //           Radio(
          //             value: 2,
          //             activeColor: Colors.white,
          //             groupValue: _radioValue,
          //             onChanged: (newValue) {
          //               setState(() {
          //                 _radioValue = newValue;
          //               });
          //             },
          //           ),
          //           Text(AppLocalizations.of(context).translate(
          //               'no'), style: TextStyle(color: Colors.white),)
          //         ],
          //       ),
          //       onTap: () {
          //         setState(() {
          //           _radioValue = 2;
          //         });
          //       },
          //     ),
          //   ],
          // ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            width: double.infinity,
            height: 50.0,
            child: RaisedButton(
              color: Colors.black12,
              child: Text(AppLocalizations.of(context).translate(
                  'big_save'),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0),
              ),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  checkMember();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: Text(title),
            content: Text(message),
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
}
