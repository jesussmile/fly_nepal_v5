import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:fly_nepal/experimental/githubissue.dart';
import 'package:fly_nepal/screens/main_screen.dart';
import 'package:fly_nepal/providers/MarkerListProvider.dart';
import 'package:fly_nepal/providers/provider_service.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterMapTileCaching.initialise();
  FMTC.instance('mapStore').manage.create();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ProviderService is a class that extends ChangeNotifier
        ChangeNotifierProvider(create: (_) => ProviderService()),
        // MarkerListProvider is a class that extends ListenableProvider
        ChangeNotifierProvider(create: (_) => MarkerListProvider()),
      ],
      child: Sizer(builder: (BuildContext context, Orientation orientation,
          DeviceType deviceType) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const MyHomePage(),
        );
      }),
    );
  }
}
