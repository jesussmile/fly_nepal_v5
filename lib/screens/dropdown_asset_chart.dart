import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:fly_nepal/providers/provider_service.dart';
import 'package:fly_nepal/services/assetFile.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class FolderDropdown extends StatelessWidget {
  final MapController flutterMapC;
  const FolderDropdown({Key? key, required this.flutterMapC}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadAssets(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading assets'),
          );
        } else {
          final data = snapshot.data;
          if (data != null) {
            return ListView.builder(
              itemCount: data.children.length,
              itemBuilder: (BuildContext context, int index) {
                return buildExpansionTile(context, data.children[index]);
              },
            );
          } else {
            return const Center(
              child: Text('No data available'),
            );
          }
        }
      },
    );
  }

  Future<AssetFileList?> loadAssets(BuildContext context) async {
    String jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/assetName.json');
    Map<String, dynamic> json = jsonDecode(jsonString);
    return AssetFileList.fromJson(json);
  }

  Widget buildExpansionTile(BuildContext context, FolderChild folder,
      {String parentPath = ''}) {
    final folderPath =
        parentPath.isEmpty ? folder.name : '$parentPath/${folder.name}';
    // print(folderPath);
    if (folder.type == "file") {
      return ListTile(
        onTap: () {
          // print('assets/charts/$folderPath');
          getImageSize(folderPath, folder.name, context);
          // Provider.of<ProviderService>(context, listen: false)
          //     .addRotatedOverLayImageX(folderPath, folder.name);
        },
        textColor: Colors.green,
        title: Text(_removeExtensionIfPNG(folder.name)),
      );
    } else {
      final sortedChildren = folder.children!.map((child) => child).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return ExpansionTile(
        title: Text(folder.name),
        children: sortedChildren.map((child) {
          return buildExpansionTile(context, child, parentPath: folderPath);
        }).toList(),
      );
    }
  }

  void getImageSize(String folderPath, String fileName, BuildContext context) {
    final imageProvider = AssetImage('assets/charts/$folderPath');
    print(imageProvider);
    final imageStream = imageProvider.resolve(const ImageConfiguration());
    int width = 0;
    int height = 0;

    imageStream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      width = info.image.width;
      height = info.image.height;
      print('Overlay image width: $width, height: $height');
      calculateImageCorners(flutterMapC.center, width, height,
          flutterMapC.zoom + 3.14159265, folderPath, fileName, context);
    }));
  }

  String _removeExtensionIfPNG(String filename) {
    if (filename.toLowerCase().endsWith('.png')) {
      return filename.substring(0, filename.length - 4);
    } else {
      return filename;
    }
  }

  //void calculateImageCorners() {
  void calculateImageCorners(
      LatLng center,
      int imageWidth,
      int imageHeight,
      double mapZoom,
      dynamic folderPath,
      dynamic chartName,
      BuildContext context) {
    final scaleFactor = 1 / (2 * pow(2, mapZoom));
    // print('Zoom Level: $zoomLevel');
    // Calculate half width and half height in latitude and longitude
    final halfWidth = imageWidth * scaleFactor / 2;
    final halfHeight = imageHeight * scaleFactor / 2;
    // Calculate top left corner coordinates
    final topLeftLatitude = center.latitude + halfHeight;
    final topLeftLongitude = center.longitude - halfWidth;
    // Calculate bottom left corner coordinates
    final bottomLeftLatitude = center.latitude - halfHeight;
    final bottomLeftLongitude = center.longitude - halfWidth;
    // Calculate bottom right corner coordinates
    final bottomRightLatitude = center.latitude - halfHeight;
    final bottomRightLongitude = center.longitude + halfWidth;
    LatLng topC = LatLng(topLeftLatitude, topLeftLongitude);
    LatLng botC = LatLng(bottomLeftLatitude, topLeftLongitude);
    LatLng rightC = LatLng(bottomLeftLatitude, bottomRightLongitude);
    Provider.of<ProviderService>(context, listen: false)
        .addTestRotatedOverLayImageX(chartName, folderPath, topC, botC, rightC);
    // print('Top Left: $topLeftLatitude, $topLeftLongitude');
    // print('Bottom Left: $bottomLeftLatitude, $bottomLeftLongitude');
    // print('Bottom Right: $bottomRightLatitude, $bottomRightLongitude');
    // Navigator.pop(context);
  }
}
