import 'dart:convert';

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());

class Data {
  List<Fix> fixes;
  List<String> rnws;
  List<Sid> sids;
  List<Star> stars;
  List<Approach> approaches;
  Data({
    required this.fixes,
    required this.rnws,
    required this.sids,
    required this.stars,
    required this.approaches,
  });
  factory Data.fromJson(Map<String, dynamic> json) => Data(
        fixes: List<Fix>.from(json["fixes"].map((x) => Fix.fromJson(x))),
        rnws: List<String>.from(json["rnws"].map((x) => x)),
        sids: List<Sid>.from(json["sids"].map((x) => Sid.fromJson(x))),
        stars: List<Star>.from(json["stars"].map((x) => Star.fromJson(x))),
        approaches: List<Approach>.from(
            json["approaches"].map((x) => Approach.fromJson(x))),
      );
  Map<String, dynamic> toJson() => {
        "fixes": List<dynamic>.from(fixes.map((x) => x.toJson())),
        "rnws": List<dynamic>.from(rnws.map((x) => x)),
        "sids": List<dynamic>.from(sids.map((x) => x.toJson())),
        "stars": List<dynamic>.from(stars.map((x) => x.toJson())),
        "approaches": List<dynamic>.from(approaches.map((x) => x.toJson())),
      };
}

class Approach {
  String name;
  Map<String, String> fixes;
  List<ApproachTransition> transitions;
  Approach({
    required this.name,
    required this.fixes,
    required this.transitions,
  });
  factory Approach.fromJson(Map<String, dynamic> json) => Approach(
        name: json["name"],
        fixes: Map.from(json["fixes"])
            .map((k, v) => MapEntry<String, String>(k, v)),
        transitions: List<ApproachTransition>.from(
            json["transitions"].map((x) => ApproachTransition.fromJson(x))),
      );
  Map<String, dynamic> toJson() => {
        "name": name,
        "fixes": Map.from(fixes).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "transitions": List<dynamic>.from(transitions.map((x) => x.toJson())),
      };
}

class ApproachTransition {
  String name;
  Map<String, String> fixes;
  ApproachTransition({
    required this.name,
    required this.fixes,
  });
  factory ApproachTransition.fromJson(Map<String, dynamic> json) =>
      ApproachTransition(
        name: json["name"],
        fixes: Map.from(json["fixes"])
            .map((k, v) => MapEntry<String, String>(k, v)),
      );
  Map<String, dynamic> toJson() => {
        "name": name,
        "fixes": Map.from(fixes).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}

class Fix {
  String name;
  double lat;
  double lon;
  Fix({
    required this.name,
    required this.lat,
    required this.lon,
  });
  factory Fix.fromJson(Map<String, dynamic> json) => Fix(
        name: json["name"],
        lat: json["lat"]?.toDouble(),
        lon: json["lon"]?.toDouble(),
      );
  Map<String, dynamic> toJson() => {
        "name": name,
        "lat": lat,
        "lon": lon,
      };
}

class Sid {
  String name;
  String rnw;
  Map<String, String> fixes;
  List<SidTransition> transitions;
  Sid({
    required this.name,
    required this.rnw,
    required this.fixes,
    required this.transitions,
  });
  factory Sid.fromJson(Map<String, dynamic> json) => Sid(
        name: json["name"],
        rnw: json["rnw"],
        fixes: Map.from(json["fixes"])
            .map((k, v) => MapEntry<String, String>(k, v)),
        transitions: List<SidTransition>.from(
            json["transitions"].map((x) => SidTransition.fromJson(x))),
      );
  Map<String, dynamic> toJson() => {
        "name": name,
        "rnw": rnw,
        "fixes": Map.from(fixes).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "transitions": List<dynamic>.from(transitions.map((x) => x.toJson())),
      };
}

class SidTransition {
  String name;
  List<String> fixes;
  SidTransition({
    required this.name,
    required this.fixes,
  });
  factory SidTransition.fromJson(Map<String, dynamic> json) => SidTransition(
        name: json["name"],
        fixes: List<String>.from(json["fixes"].map((x) => x)),
      );
  Map<String, dynamic> toJson() => {
        "name": name,
        "fixes": List<dynamic>.from(fixes.map((x) => x)),
      };
}

class Star {
  String name;
  String runway;
  Map<String, String> fixes;
  Star({
    required this.name,
    required this.runway,
    required this.fixes,
  });
  factory Star.fromJson(Map<String, dynamic> json) => Star(
        name: json["name"],
        runway: json["runway"],
        fixes: Map.from(json["fixes"])
            .map((k, v) => MapEntry<String, String>(k, v)),
      );
  Map<String, dynamic> toJson() => {
        "name": name,
        "runway": runway,
        "fixes": Map.from(fixes).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}
