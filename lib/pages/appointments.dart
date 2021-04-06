import 'dart:convert';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:group_button/group_button.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:klinix/models/apiRandevuModel.dart';
import 'package:klinix/models/departmentsModel.dart';
import 'package:klinix/models/doctorsModel.dart';
import 'package:klinix/models/hospitalsModel.dart';
import 'package:klinix/models/membersModel.dart';
import 'package:klinix/pages/person_new.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';
import 'package:klinix/ui/widgets/bottom_navigation.dart';
import 'package:klinix/ui/widgets/confirm_appointment_dialog.dart';
import 'package:klinix/ui/widgets/my_drawer.dart';
import 'package:klinix/ui/widgets/success_dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

class AppointmentsPage extends StatefulWidget {
  final HospitalsModel hospital;
  final DoctorsModel doctor;

  AppointmentsPage({ this.hospital, this.doctor });

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  ProgressDialog pr;
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  final _firstFormKey = GlobalKey<FormState>();
  final _tcKimlikNo = new TextEditingController();
  MembersModel _kiminAdina;
  String _sehir;
  HospitalsModel _hospital;
  DepartmentsModel _department;
  DoctorsModel _doctor;
  DateTime _currentDate = DateTime.now();
  String _selectedTime;
  bool isSwitched = false;

  final _pageController = new PageController(
      initialPage: 0
  );

  List<MembersModel> submemberList = new List<MembersModel>();
  List<HospitalsModel> hospitalsList = new List<HospitalsModel>();
  List<HospitalsModel> filteredHospitalsList = new List<HospitalsModel>();
  List<DepartmentsModel> departmentsList = new List<DepartmentsModel>();
  List<DoctorsModel> doctorsList = new List<DoctorsModel>();
  List<ApiRandevuModel> apiRandevuList = new List<ApiRandevuModel>();
  List<String> _cityList = new List<String>();
  List<String> bosSaatler = [];

  Future<void> getListItems() async {
    await pr.show();

    var res = await http.get(
        Variables.url + '/getSubMembers?id=' + Variables.memberId.toString(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      submemberList = decodeList.map((i) =>
          MembersModel.fromJson(i)).toList();

      submemberList.add(new MembersModel(
          mEMID: Variables.memberId,
          tCKN: Variables.tckn,
          gSM: Variables.gsm,
          eMail: Variables.email,
          sex: Variables.sex,
          name: AppLocalizations.of(context).translate('myself'),
          p1: 'D'
      ));

      setState(() {
        submemberList.sort((a, b) => a.name.compareTo(b.name));
        _kiminAdina = submemberList.firstWhere((element) =>
        element.p1 == 'D');
        _tcKimlikNo.text = Variables.tckn;
      });
    }

    res = await http.get(
        Variables.url + '/getHospitals?lang=' + Variables.lang+'&category=*',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      await pr.hide();

      var decodeList = json.decode(res.body) as List<dynamic>;
      hospitalsList = decodeList.map((i) =>
          HospitalsModel.fromJson(i)).toList();
      filteredHospitalsList = List.from(hospitalsList);

      hospitalsList.forEach((hospital) {
        if (hospital.sehir != null) {
          if (_cityList.indexWhere((element) => element == hospital.sehir) ==
              -1) {
            _cityList.add(hospital.sehir);
          }
        }
      });

      setState(() {
        if (widget.hospital != null) {
          _sehir = widget.hospital.sehir;
          _hospital =
              filteredHospitalsList.firstWhere((element) =>
              element.hOSID ==
                  widget.hospital.hOSID);
          getDepartments(false).whenComplete(() {
            if (widget.doctor != null) {
              _department =
                  departmentsList.firstWhere((element) =>
                  element.depWebId ==
                      widget.doctor.depWebId);
              if (_department != null) {
                getDoctors(false).whenComplete(() {
                  _doctor = doctorsList.firstWhere((element) =>
                  element.dOCID ==
                      widget.doctor.dOCID);
                });
              }
            }
          });
        }
      });
    }
  }

  filterHospitals() async {
    setState(() {
      _hospital = null;
      filteredHospitalsList =
          hospitalsList.where((element) => element.sehir == _sehir).toList();
    });
  }

  Future<void> getHospitals() async {
    await pr.show();

    var res = await http.get(
        Variables.url + '/getHospitals?lang=' + Variables.lang+'&category=*',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      await pr.hide();

      var decodeList = json.decode(res.body) as List<dynamic>;
      hospitalsList = decodeList.map((i) =>
          HospitalsModel.fromJson(i)).toList();

      hospitalsList.forEach((hospital) {
        if (hospital.sehir != null) {
          if (_cityList.indexWhere((element) => element == hospital.sehir) ==
              -1) {
            _cityList.add(hospital.sehir);
          }
        }
      });

      setState(() {
        _hospital = null;
        if (Variables.tckn != null) {
          _tcKimlikNo.text = Variables.tckn;
        }
      });
    }
  }

  Future<void> getDepartments(bool showWait) async {
    if (showWait) await pr.show();

    var res = await http.get(
        Variables.url + '/getDepartmentsByHospital?id=' +
            _hospital.hOSID.toString() +
            '&lang=' + Variables.lang,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      if (showWait) await pr.hide();

      var decodeList = json.decode(res.body) as List<dynamic>;
      departmentsList = decodeList.map((i) =>
          DepartmentsModel.fromJson(i)).toList();
      setState(() {
        _department = null;
      });
    }
  }

  Future<void> getDoctors(bool showWait) async {
    if (showWait) await pr.show();

    var res = await http.get(
        Variables.url + '/getDoctorsByHosNDep?hosid=' +
            _hospital.hOSID.toString() +
            '&depid=' + _department.depWebId.toString() +
            '&lang=' + Variables.lang,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      if (showWait) await pr.hide();

      var decodeList = json.decode(res.body) as List<dynamic>;
      doctorsList = decodeList.map((i) =>
          DoctorsModel.fromJson(i)).toList();

      setState(() {
        _doctor = null;
      });

      if (doctorsList.length == 0) {
        _showDialog(AppLocalizations.of(context).translate('error'),
            AppLocalizations.of(context).translate('no_doctor_error'));
      }
    }
  }

  Future<void> getBosRandevular(_date) async {
    await pr.show();

    var res = await http.get(
        Variables.url + '/getRandevuBosListe?memberId=' +
            _kiminAdina.mEMID.toString() +
            '&doctorId=' + _doctor.dOCID.toString() +
            '&date=' + _date.toString(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer ' + Variables.accessToken
        });
    if (res.statusCode == 200) {
      var decodeList = json.decode(res.body) as List<dynamic>;
      apiRandevuList = decodeList.map((i) =>
          ApiRandevuModel.fromJson(i)).toList();
      List<String> saatler = new List<String>();
      apiRandevuList.forEach((element) {
        saatler.add(element.saat);
      });

      if (saatler.length > 0) {
        saatler.sort();
        await pr.hide();

        setState(() {
          _currentDate = _date;
          bosSaatler = saatler;
          _selectedTime = bosSaatler[0];
          _pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn);
        });
      }
      else {
        await pr.hide();
        await _showDialog(AppLocalizations.of(context).translate(
            'error'), AppLocalizations.of(context).translate(
            'emptyappointment_api_error'));
      }
    }
    else {
      await pr.hide();

      await _showDialog(AppLocalizations.of(context).translate(
          'error'), AppLocalizations.of(context).translate(
          'emptyappointment_api_error'));
    }
  }

  Future<void> randevuAl() async {
    await pr.show();

    String result = await showDialog(
      context: context,
      builder: (BuildContext context) =>
          ConfirmAppointmentDialog(
            title: AppLocalizations.of(context).translate(
                'appointment_confirm'),
            buttonText: AppLocalizations.of(context).translate(
                'big_ok'),
            tckn: _tcKimlikNo.text,
            adsoyad: _kiminAdina.p1 == 'D'
                ? Variables.adsoyad
                : _kiminAdina.name,
            tarih: DateFormat('yyyy-MM-dd').format(_currentDate) + " " +
                _selectedTime,
            hospital: _hospital,
            department: _department,
            doctor: _doctor,
          ),
    );
    String confirm = result;
    if (confirm == '1') {
      var res = await http.get(
          Variables.url + '/getRandevuAl?memberId=' +
              _kiminAdina.mEMID.toString() +
              '&doctorId=' + _doctor.dOCID.toString() +
              '&date=' + DateFormat('yyyy-MM-dd').format(_currentDate) + " " +
              _selectedTime +
              '&lang=' + Variables.lang,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'bearer ' + Variables.accessToken
          });
      if (res.statusCode == 200) {
        await pr.hide();

        var result = res.body.split('"').join('');
        if (!result.contains("err")) {
          await showDialog(
            context: context,
            builder: (BuildContext context) =>
                SuccessDialog(
                  title: AppLocalizations.of(context).translate(
                      'succesfully_completed'),
                  description: AppLocalizations.of(context).translate(
                      'appointment_complete'),
                  buttonText: AppLocalizations.of(context).translate('big_ok'),
                  image: Icon(Icons.check, size: 48, color: Colors.white,),
                ),
          );
        }
        else {
          await showDialog(
            context: context,
            builder: (BuildContext context) =>
                SuccessDialog(
                  title: AppLocalizations.of(context).translate('error'),
                  description: AppLocalizations.of(context).translate(
                      'appointment_error'),
                  buttonText: AppLocalizations.of(context).translate('big_ok'),
                  image: Icon(Icons.error, size: 48, color: Colors.white,),
                ),
          );
        }
      }
      else {
        await pr.hide();

        await showDialog(
          context: context,
          builder: (BuildContext context) =>
              SuccessDialog(
                title: AppLocalizations.of(context).translate('error'),
                description: AppLocalizations.of(context).translate(
                    'appointment_error'),
                buttonText: AppLocalizations.of(context).translate('big_ok'),
                image: Icon(Icons.error, size: 48, color: Colors.white,),
              ),
        );
      }
    }
    else {
      await pr.hide();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getListItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, isDismissible: false);
    pr.style(message: AppLocalizations.of(context).translate('please_wait'),
        progressWidget: Image.asset('assets/images/loading.gif'));

    return SideMenu(
      key: _sideMenuKey,
      menu: MyDrawer(),
      type: SideMenuType.shrinkNSlide,
      inverse: Variables.lang == 'ar' ? true : false,
      background: Variables.primaryColor,
      radius: BorderRadius.circular(0),
      child: Stack(
          children: [
            Image(
              image: AssetImage("assets/images/home_background.png"),
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              fit: BoxFit.cover,
            ),
            Scaffold(
              appBar: AppBar(
                backgroundColor: Variables.greyColor,
                elevation: 0,
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: Stack(
                    children: [
                      Container(
                        width: 80.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: IconButton(
                                icon: Image.asset(
                                  'assets/images/back_red.png',),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            Expanded(
                              child: IconButton(
                                icon: Icon(
                                  Icons.menu, color: Variables.primaryColor,
                                  size: 32.0,),
                                onPressed: () {
                                  final _state = _sideMenuKey.currentState;
                                  if (_state.isOpened)
                                    _state.closeSideMenu();
                                  else
                                    _state.openSideMenu();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Center(child: Image.asset(
                          'assets/images/logo.png', width: 100.0,)),
                      ),
                    ]
                ),
              ),
              body: Container(
                constraints: BoxConstraints.expand(),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            'assets/images/sidemenu_background.png'),
                        fit: BoxFit.cover)
                ),
                child: bodyWidget(),
              ),
              bottomNavigationBar: MyBottomNavigationBar(),
            ),
          ]
      ),
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
                        'assets/images/appointment_button.png',
                        width: 40, height: 40,),
                      iconSize: 56,
                      splashColor: Variables.primaryColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Center(
                  child: Text(AppLocalizations.of(context).translate(
                      'online_appointment'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),

                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  width: double.infinity,
                  height: 5000,
                  child: PageView(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    children: [
                      firstPageWidget(),
                      secondPageWidget(),
                      thirdPageWidget(),
                    ],
                    onPageChanged: (page) {

                    },
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget firstPageWidget() {
    return Container(
      child: Form(
        key: _firstFormKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: DropdownButtonFormField<MembersModel>(
                    value: _kiminAdina,
                    style: TextStyle(
                        color: Colors.black
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).translate(
                          'appointment_person'),
                      hintStyle: TextStyle(color: Colors.white),
                      fillColor: Colors.white38,
                      filled: true,
                      errorStyle: TextStyle(
                          color: Colors.white
                      ),
                    ),
                    icon: Image.asset(
                      'assets/images/dropdown.png', width: 18.0,
                      height: 18.0,),
                    items: submemberList.map((value) {
                      return DropdownMenuItem<MembersModel>(
                          child: Text(value.name), value: value);
                    }).toList(),
                    validator: (value) {
                      if (submemberList.length > 1) {
                        if (value == null) {
                          return AppLocalizations.of(context).translate(
                              'required_field');
                        }
                        else {
                          return null;
                        }
                      }
                      else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      setState(() {
                        _kiminAdina = value;
                        if (value.p1 == 'D') {
                          if (Variables.tckn != null) {
                            _tcKimlikNo.text = Variables.tckn;
                          }
                        }
                        else {
                          _tcKimlikNo.text = value.tCKN;
                        }
                      });
                    },
                  ),
                ),

                SizedBox(
                  width: 5.0,
                ),

                Expanded(
                  flex: 1,
                  child: Container(
                      color: Colors.white,
                      child: IconButton(
                        icon: Icon(
                          Icons.add_circle, color: Variables.primaryColor,),
                        onPressed: () {
                          Navigator.of(context).push(
                              new MaterialPageRoute(
                                  builder: (context) => PersonNewPage()
                              )).whenComplete(() => getListItems());
                        },
                      )
                  ),
                ),
              ],
            ),

            SizedBox(
              height: 10.0,
            ),

            TextFormField(
              controller: _tcKimlikNo,
              enabled: false,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate(
                    'identity_number'),
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white38,
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                    vertical: 5.0, horizontal: 10.0),
              ),
              cursorColor: Colors.white,
              style: TextStyle(
                  color: Colors.black
              ),
            ),

            SizedBox(
              height: 10.0,
            ),

            DropdownButtonFormField<String>(
              value: _sehir,
              style: TextStyle(
                  color: Colors.black
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('city'),
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white38,
                filled: true,
                errorStyle: TextStyle(
                    color: Colors.white
                ),
              ),
              icon: Image.asset(
                'assets/images/dropdown.png', width: 18.0, height: 18.0,),
              items: _cityList.map((value) {
                return DropdownMenuItem<String>(
                    child: Text(value), value: value);
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _sehir = value;
                  filterHospitals();
                });
              },
            ),

            SizedBox(
              height: 10.0,
            ),

            DropdownButtonFormField<HospitalsModel>(
              value: _hospital,
              style: TextStyle(
                  color: Colors.black
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate(
                    'appointment_hospital'),
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white38,
                filled: true,
                errorStyle: TextStyle(
                    color: Colors.white
                ),
              ),
              icon: Image.asset(
                'assets/images/dropdown.png', width: 18.0, height: 18.0,),
              items: filteredHospitalsList.map((value) {
                return DropdownMenuItem<HospitalsModel>(
                    child: Text(value.name), value: value);
              }).toList(),
              validator: (value) =>
              value == null ? AppLocalizations.of(context).translate(
                  'required_field') : null,
              onChanged: (value) {
                if (value.anlasmavarmi == "1") {
                  setState(() {
                    _hospital = value;
                    _department=null;
                    _doctor=null;
                    getDepartments(true);
                  });
                }
                else{
                  showDialog(
                    context: context,
                    builder: (_) =>
                        AlertDialog(
                          title: Text(
                              AppLocalizations.of(context)
                                  .translate(
                                  'information')),
                          content: Text(
                              AppLocalizations.of(context)
                                  .translate(
                                  'not_agreement')),
                          actions: [
                            TextButton(
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate(
                                    'big_ok'),
                                style: TextStyle(
                                    color: Variables
                                        .primaryColor),
                              ),
                              onPressed: () {
                                setState(() {
                                  _hospital = null;
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                  );
                }
              },
            ),

            SizedBox(
              height: 10.0,
            ),

            DropdownButtonFormField<DepartmentsModel>(
              value: _department,
              style: TextStyle(
                  color: Colors.black
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate(
                    'appointment_department'),
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white38,
                filled: true,
                errorStyle: TextStyle(
                    color: Colors.white
                ),
              ),
              icon: Image.asset(
                'assets/images/dropdown.png', width: 18.0, height: 18.0,),
              items: departmentsList.map((value) {
                return DropdownMenuItem<DepartmentsModel>(
                    child: Text(value.name), value: value);
              }).toList(),
              validator: (value) =>
              value == null ? AppLocalizations.of(context).translate(
                  'required_field') : null,
              onChanged: (value) {
                setState(() {
                  _department = value;
                  getDoctors(true);
                });
              },
            ),

            SizedBox(
              height: 10.0,
            ),

            DropdownButtonFormField<DoctorsModel>(
              value: _doctor,
              style: TextStyle(
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate(
                    'choose_doctor'),
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white38,
                filled: true,
                errorStyle: TextStyle(
                    color: Colors.white
                ),
              ),
              icon: Image.asset(
                'assets/images/dropdown.png', width: 18.0, height: 18.0,),
              items: doctorsList.map((value) {
                return DropdownMenuItem<DoctorsModel>(
                    child: Text(value.title + ' ' + value.name), value: value);
              }).toList(),
              validator: (value) =>
              value == null ? AppLocalizations.of(context).translate(
                  'required_field') : null,
              onChanged: (value) {
                setState(() {
                  _doctor = value;
                });
              },
            ),

            Container(
              padding: EdgeInsets.only(top: 20.0),
              width: double.infinity,
              child: RawMaterialButton(
                fillColor: Colors.black12,
                splashColor: Variables.primaryColor,
                textStyle: TextStyle(color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Text(
                        AppLocalizations.of(context).translate('big_continue'),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: Image.asset(
                        'assets/images/next.png', color: Colors.white,
                        width: 20.0,
                        height: 20.0,),
                    ),
                  ],
                ),
                onPressed: () {
                  if (_firstFormKey.currentState.validate()) {
                    setState(() {
                      _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget secondPageWidget() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Text(
              AppLocalizations.of(context).translate('appointment_date'),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Divider(
          color: Colors.white,
          height: 5.0,
        ),
        SizedBox(
          height: 10.0,
        ),

        Container(
          color: Colors.white70,
          child: calendarCarouselWidget(),
        ),

        SizedBox(
          height: 10.0,
        ),

        Container(
          padding: EdgeInsets.only(top: 20.0),
          width: double.infinity,
          child: RawMaterialButton(
            fillColor: Colors.black12,
            splashColor: Variables.primaryColor,
            textStyle: TextStyle(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: Image.asset(
                        'assets/images/next.png', color: Colors.white,
                        width: 20.0,
                        height: 20.0,),
                    )
                ),
                SizedBox(
                  width: 10.0,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Text(
                    AppLocalizations.of(context).translate('big_back'),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            onPressed: () {
              setState(() {
                _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn);
              });
            },
          ),
        )
      ],
    );
  }

  Widget thirdPageWidget() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                AppLocalizations.of(context).translate('appointment_time'),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Divider(
            color: Colors.white,
            height: 5.0,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 20.0),
                  width: double.infinity,
                  child: RawMaterialButton(
                    fillColor: Colors.black12,
                    splashColor: Variables.primaryColor,
                    textStyle: TextStyle(color: Colors.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(math.pi),
                              child: Image.asset(
                                'assets/images/next.png', color: Colors.white,
                                width: 20.0,
                                height: 20.0,),
                            )
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 20.0),
                          child: Text(
                            AppLocalizations.of(context).translate('big_back'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn);
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 20.0),
                  width: double.infinity,
                  child: RawMaterialButton(
                    fillColor: Colors.black12,
                    splashColor: Variables.primaryColor,
                    textStyle: TextStyle(color: Colors.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Text(AppLocalizations.of(context).translate(
                              'big_complete'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () => randevuAl(),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            height: 5.0,
          ),

          timeWidget(),

          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }

  Widget calendarCarouselWidget() {
    return CalendarCarousel(
      height: 410,
      dayPadding: 5,
      isScrollable: false,
      pageScrollPhysics: NeverScrollableScrollPhysics(),
      weekFormat: false,
      minSelectedDate: DateTime.now().subtract(Duration(days: 1)),
      selectedDateTime: _currentDate,
      daysHaveCircularBorder: true,
      selectedDayButtonColor: Variables.primaryColor,
      selectedDayTextStyle: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold),
      locale: Variables.lang,
      weekdayTextStyle: TextStyle(color: Colors.black),
      weekendTextStyle: TextStyle(color: Colors.white),
      showHeaderButton: true,
      headerTextStyle: TextStyle(color: Colors.black, fontSize: 20.0,),
      iconColor: Colors.white,
      onDayPressed: (DateTime date, List<Event> events) {
        getBosRandevular(date);
        //setState(() {
        //_currentDate = date;
        // _pageController.nextPage(
        //     duration: Duration(milliseconds: 300),
        //     curve: Curves.easeIn);
        //});
      },
    );
  }

  Widget timeWidget() {
    return GroupButton(
      isRadio: true,
      spacing: 5,
      direction: Axis.horizontal,
      buttons: bosSaatler,
      selectedColor: Variables.primaryColor,
      selectedBorderColor: Colors.black,
      selectedTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.white,
      ),
      onSelected: (val, isSelected) {
        setState(() {
          _selectedTime = bosSaatler[val];
        });
      },
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
