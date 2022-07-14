class DoctorTitleModel {
  int id;
  String title;
  String farsiTitle;
  String pashtoTitle;

  DoctorTitleModel({
    required this.id,
    required this.title,
    required this.farsiTitle,
    required this.pashtoTitle,
  });

// it is same as toJson
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'farsi_title': farsiTitle,
      'pashto_title': pashtoTitle,
    };
  }

  factory DoctorTitleModel.fromJson(Map<String, dynamic> json) {
    return DoctorTitleModel(
      id: json['id'],
      title: json['title'],
      farsiTitle: json['farsi_title'],
      pashtoTitle: json['pashto_title'],
    );
  }
}
