import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:klinix/models/membersModel.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:progress_dialog/progress_dialog.dart';

class PersonDetailPage extends StatefulWidget {
  final MembersModel member;

  PersonDetailPage({this.member});

  @override
  _PersonDetailPageState createState() => _PersonDetailPageState();
}

class _PersonDetailPageState extends State<PersonDetailPage> {
  ProgressDialog pr;
  MembersModel member;

  Future<void> getMember() async {
    await pr.show();

    var res = await http.get(
        Variables.url + '/getMemberById?id=' + widget.member.mEMID.toString(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      List<MembersModel> _membersList =
          decodeList.map((i) => MembersModel.fromJson(i)).toList();
      if (_membersList.length > 0) {
        setState(() {
          member = _membersList[0];
        });
      }
    }

    await pr.hide();
  }

  Future<void> delete() async {
    await pr.show();

    if (member != null) {
      MembersModel insertedMember = new MembersModel(mEMID: member.mEMID);
      var body = json.encode(insertedMember.toMap());
      var res = await http.post(Variables.url + '/delMember',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer ' + Variables.accessToken
          },
          body: body);
      if (res.statusCode == 200) {
        Navigator.of(context).pop();
      }

      await pr.hide();
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getMember();
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: false);
    pr.style(
        message: AppLocalizations.of(context).translate('please_wait'),
        progressWidget: Image.asset('assets/images/loading.gif'));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Variables.greyColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', width: 100.0),
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back_red.png',
            color: Variables.primaryColor,
            width: 24.0,
            height: 24.0,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        //bottom: _buildBottomBar(),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/white_background.png'),
                fit: BoxFit.cover)),
        child: bodyWidget(),
      ),
      bottomNavigationBar: MyBottomNavigationBar(),
    );
  }

  Widget bodyWidget() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 40.0,
              width: double.infinity,
              color: Variables.greyColor,
            ),
            Column(
              children: [
                SizedBox(
                  height: 10.0,
                ),
                Center(
                  child: Material(
                    color: Colors.white,
                    elevation: 8.0,
                    clipBehavior: Clip.hardEdge,
                    borderRadius: BorderRadius.circular(50),
                    child: IconButton(
                      icon: Image.asset(
                        'assets/images/hospital_button.png',
                        width: 40,
                        height: 40,
                      ),
                      iconSize: 56,
                      splashColor: Variables.primaryColor,
                      onPressed: null,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context).translate('big_person_infos'),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Container(
                        height: 30.0,
                        width: double.infinity,
                        decoration:
                            BoxDecoration(color: Variables.primaryColor),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate('identity_info'),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      listTileWidget(
                          AppLocalizations.of(context).translate('name') +
                              ' ' +
                              AppLocalizations.of(context).translate('surname'),
                          member != null ? member.name : ' '),
                      listTileWidget(
                          AppLocalizations.of(context)
                              .translate('identity_number'),
                          member != null ? member.tCKN : ' '),
                      listTileWidget(
                          AppLocalizations.of(context).translate('birth_date'),
                          member != null
                              ? DateFormat('dd.MM.yyyy')
                                  .format(DateTime.parse(member.bDate))
                              : ' '),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Container(
                        height: 30.0,
                        width: double.infinity,
                        decoration:
                            BoxDecoration(color: Variables.primaryColor),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate('contact_info'),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      listTileWidget(
                          AppLocalizations.of(context).translate('login_email'),
                          member != null ? member.eMail ?? ' ' : ''),
                      listTileWidget(
                          AppLocalizations.of(context).translate('cell_phone'),
                          member != null ? member.gSM ?? '' : ' '),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 60.0, vertical: 10.0),
                  child: Container(
                    width: double.infinity,
                    child: RawMaterialButton(
                      elevation: 0,
                      fillColor: Variables.primaryColor,
                      splashColor: Colors.white,
                      textStyle: TextStyle(color: Colors.white),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 40.0),
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('big_delete'),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: Image.asset(
                              'assets/images/next.png',
                              color: Colors.white,
                              width: 20.0,
                              height: 20.0,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () => delete(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget listTileWidget(String title, String trailingText) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          trailing: Text(trailingText),
          dense: true,
        ),
        Divider(
          color: Colors.black,
          height: 5.0,
        ),
      ],
    );
  }
}
