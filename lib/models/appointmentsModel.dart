class AppointmentsModel {
  int aPPID;
  String cDate;
  String uDate;
  String dDate;
  int cUSRID;
  int dOCID;
  int mEMID;
  String aDate;
  String aNote;
  String aRefNo;
  String uNote;
  int mOK;
  String mOKDate;
  int mOKUSRID;
  int hOK;
  String hOKDate;
  String hOKRef;
  String lastStatus;
  int sKOK;
  String sKDate;
  String sKNote;
  int randevudurum;
  String p1;
  String p2;
  String p3;
  int cancelled;
  String ay;
  String hospitalName;
  String departmentName;
  String doctorName;
  String memberName;

  AppointmentsModel({this.aPPID,
    this.cDate,
    this.uDate,
    this.dDate,
    this.cUSRID,
    this.dOCID,
    this.mEMID,
    this.aDate,
    this.aNote,
    this.aRefNo,
    this.uNote,
    this.mOK,
    this.mOKDate,
    this.mOKUSRID,
    this.hOK,
    this.hOKDate,
    this.hOKRef,
    this.lastStatus,
    this.sKOK,
    this.sKDate,
    this.sKNote,
    this.randevudurum,
    this.p1,
    this.p2,
    this.p3,
    this.cancelled,
    this.ay,
    this.hospitalName,
    this.departmentName,
    this.doctorName,
    this.memberName});

  AppointmentsModel.fromJson(Map<String, dynamic> json) {
    aPPID = json['APP_ID'];
    cDate = json['CDate'];
    uDate = json['UDate'];
    dDate = json['DDate'];
    cUSRID = json['CUSR_ID'];
    dOCID = json['DOC_ID'];
    mEMID = json['MEM_ID'];
    aDate = json['ADate'];
    aNote = json['ANote'];
    aRefNo = json['ARefNo'];
    uNote = json['UNote'];
    mOK = json['MOK'];
    mOKDate = json['MOKDate'];
    mOKUSRID = json['MOKUSR_ID'];
    hOK = json['HOK'];
    hOKDate = json['HOKDate'];
    hOKRef = json['HOKRef'];
    lastStatus = json['LastStatus'];
    sKOK = json['SKOK'];
    sKDate = json['SKDate'];
    sKNote = json['SKNote'];
    randevudurum = json['randevudurum'];
    p1 = json['P1'];
    p2 = json['P2'];
    p3 = json['P3'];
    cancelled = json['Cancelled'];
    ay = json['Ay'];
    hospitalName = json['Hospital_Name'];
    departmentName = json['Department_Name'];
    doctorName = json['Doctor_Name'];
    memberName = json['Member_Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['APP_ID'] = this.aPPID;
    data['CDate'] = this.cDate;
    data['UDate'] = this.uDate;
    data['DDate'] = this.dDate;
    data['CUSR_ID'] = this.cUSRID;
    data['DOC_ID'] = this.dOCID;
    data['MEM_ID'] = this.mEMID;
    data['ADate'] = this.aDate;
    data['ANote'] = this.aNote;
    data['ARefNo'] = this.aRefNo;
    data['UNote'] = this.uNote;
    data['MOK'] = this.mOK;
    data['MOKDate'] = this.mOKDate;
    data['MOKUSR_ID'] = this.mOKUSRID;
    data['HOK'] = this.hOK;
    data['HOKDate'] = this.hOKDate;
    data['HOKRef'] = this.hOKRef;
    data['LastStatus'] = this.lastStatus;
    data['SKOK'] = this.sKOK;
    data['SKDate'] = this.sKDate;
    data['SKNote'] = this.sKNote;
    data['randevudurum'] = this.randevudurum;
    data['P1'] = this.p1;
    data['P2'] = this.p2;
    data['P3'] = this.p3;
    data['Cancelled'] = this.cancelled;
    data['Ay'] = this.ay;
    data['Hospital_Name'] = this.hospitalName;
    data['Department_Name'] = this.departmentName;
    data['Doctor_Name'] = this.doctorName;
    data['Member_Name'] = this.memberName;
    return data;
  }
}
