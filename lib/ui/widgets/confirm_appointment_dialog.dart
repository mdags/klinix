import 'package:flutter/material.dart';
import 'package:klinix/models/departmentsModel.dart';
import 'package:klinix/models/doctorsModel.dart';
import 'package:klinix/models/hospitalsModel.dart';
import 'package:klinix/ui/helper/app_localizations.dart';
import 'package:klinix/ui/helper/variables.dart';

class ConfirmAppointmentDialog extends StatelessWidget {
  final String title, description, buttonText, tckn, adsoyad, tarih;
  final HospitalsModel hospital;
  final DepartmentsModel department;
  final DoctorsModel doctor;
  final Image image;

  ConfirmAppointmentDialog({
    @required this.title,
    this.description,
    @required this.buttonText,
    this.tckn,
    this.adsoyad,
    this.tarih,
    this.hospital,
    this.department,
    this.doctor,
    this.image,
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
    return Stack(
      children: <Widget>[
        Container(
          width: 280.0,
          height: 400.0,
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

              SizedBox(
                height: 10.0,
              ),

              Text(tckn ?? ' ',
                textAlign: TextAlign.center,),
              Text(adsoyad ?? ' ',
                textAlign: TextAlign.center,),
              Text(hospital != null ? hospital.name : ' ',
                textAlign: TextAlign.center,),
              Text(department != null ? department.name : ' ',
                textAlign: TextAlign.center,),
              Text(doctor != null ? doctor.name : ' ',
                textAlign: TextAlign.center,),
              Text(tarih != null ? tarih : ' ',
                textAlign: TextAlign.center,),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop('0');
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
                        Navigator.of(context).pop('1');
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
            child: Image.asset(
              'assets/images/appointment.png', width: 64, height: 64,),
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
