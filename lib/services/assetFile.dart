class AssetFileList {
  String name;
  String type;
  List<FolderChild> children;

  AssetFileList({
    required this.name,
    required this.type,
    required this.children,
  });

  factory AssetFileList.fromJson(Map<String, dynamic> json) => AssetFileList(
        name: json["name"],
        type: json["type"],
        children: List<FolderChild>.from(
            json["children"].map((x) => FolderChild.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "type": type,
        "children": List<dynamic>.from(children.map((x) => x.toJson())),
      };
}

class FolderChild {
  String name;
  String type;
  List<FolderChild>? children;

  FolderChild({
    required this.name,
    required this.type,
    this.children,
  });

  factory FolderChild.fromJson(Map<String, dynamic> json) => FolderChild(
        name: json["name"],
        type: json["type"],
        children: json["children"] == null
            ? []
            : List<FolderChild>.from(
                json["children"].map((x) => FolderChild.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "type": type,
        "children": children == null
            ? []
            : List<dynamic>.from(children!.map((x) => x.toJson())),
      };
}
