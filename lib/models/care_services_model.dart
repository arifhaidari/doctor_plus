// speciality category
class SpecialityCategoryModel {
  int? id;
  String? name;
  String? farsiName;
  String? pashtoName;
  String? icon;

  SpecialityCategoryModel({
    this.id,
    this.name,
    this.farsiName,
    this.pashtoName,
    this.icon,
  });

// it is same as toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'farsi_name': farsiName,
      'pashto_name': pashtoName,
      'icon': icon,
    };
  }

  factory SpecialityCategoryModel.fromJson(Map<String, dynamic> json) {
    return SpecialityCategoryModel(
      id: json['id'],
      name: json['name'],
      farsiName: json['farsi_name'],
      pashtoName: json['pashto_name'],
      icon: json['icon'],
    );
  }
}

// speciallity
class SpecialityModel {
  int? id;
  String? name;
  String? farsiName;
  String? pashtoName;

  SpecialityModel({
    this.id,
    this.name,
    this.farsiName,
    this.pashtoName,
  });

// it is same as toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'farsi_name': farsiName,
      'pashto_name': pashtoName,
    };
  }

  factory SpecialityModel.fromJson(Map<String, dynamic> json) {
    return SpecialityModel(
      id: json['id'],
      name: json['name'],
      farsiName: json['farsi_name'],
      pashtoName: json['pashto_name'],
    );
  }
}

// Condition Model
class ConditionModel {
  int? id;
  String? name;
  String? farsiName;
  String? pashtoName;
  SpecialityModel? speciality;

  ConditionModel({
    this.id,
    this.name,
    this.farsiName,
    this.pashtoName,
    this.speciality,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'farsi_name': farsiName,
      'pashto_name': pashtoName,
      'speciality': speciality != null ? speciality!.toJson() : null,
    };
  }

  factory ConditionModel.fromJson(Map<String, dynamic> json) {
    return ConditionModel(
      id: json['id'],
      name: json['name'],
      farsiName: json['farsi_name'],
      pashtoName: json['pashto_name'],
      speciality: json['speciality'] != null ? SpecialityModel.fromJson(json['speciality']) : null,
    );
  }
}

// Services Model
class ServiceModel {
  int? id;
  String? name;
  String? farsiName;
  String? pashtoName;
  SpecialityModel? speciality;

  ServiceModel({
    this.id,
    this.name,
    this.farsiName,
    this.pashtoName,
    this.speciality,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'farsi_name': farsiName,
      'pashto_name': pashtoName,
      'speciality': speciality != null ? speciality!.toJson() : null,
    };
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      farsiName: json['farsi_name'],
      pashtoName: json['pashto_name'],
      speciality: json['speciality'] != null ? SpecialityModel.fromJson(json['speciality']) : null,
    );
  }
}
