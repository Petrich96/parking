import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parking Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // useMaterial3: true,
      ),
      home: const ParkingPage(),
    );
  }
}

class ParkingPage extends StatefulWidget {
  const ParkingPage({super.key});

  @override
  State<ParkingPage> createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  var latControl = TextEditingController();
  var lngControl = TextEditingController();
  var scaleControl = TextEditingController();
  int x = 0;
  int y = 0;
  String imgURL = "";
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    latControl.text = "55.750626";
    lngControl.text = "37.597664";
    scaleControl.text  = '19';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshMap();
    });
  }

  void _refreshMap() async {
    if (!_formKey.currentState!.validate()) return;
    var z = int.tryParse(scaleControl.text);
    var lat = double.tryParse(latControl.text);
    var lng = double.tryParse(lngControl.text);
    if (z == null || lat == null || lng == null) return;

    var e = 0.0818191908426;

    var rho = pow(2, z + 8) / 2;
    var beta = lat * pi / 180;
    var phi = (1 - e * sin(beta)) / (1 + e * sin(beta));
    var theta = tan(pi / 4 + beta / 2) * pow(phi, e / 2);

    var x_p = rho * (1 + lng / 180);
    var y_p = rho * (1 - log(theta) / pi);

    x = (x_p / 256).floor();
    y = (y_p / 256).floor();

    imgURL =
        "https://core-carparks-renderer-lots.maps.yandex.net/maps-rdr-carparks/tiles?l=carparks&x=$x&y=$y&z=${scaleControl.text}&scale=1&lang=ru_RU";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(mainAxisSize: MainAxisSize.max, children: [
          Form(
            key: _formKey,
            onChanged: _refreshMap,
            child: Column(
              children: [
                TextFormField(
                  controller: latControl,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Введите широту",
                    fillColor: Colors.black12,
                    filled: true,
                  ),
                  validator: (text) {
                    if (text == null || text.isEmpty) return "Введите широту";
                    var s = double.tryParse(text);
                    if (s == null || s < -180 || s > 180)
                      return "Введите верное значение";
                  },
                ),
                TextFormField(
                  controller: lngControl,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Введите долготу",
                      fillColor: Colors.black12,
                      filled: true),
                  validator: (text) {
                    if (text == null || text.isEmpty) return "Введите долготу";
                    var s = double.tryParse(text);
                    if (s == null || s < -180 || s > 180)
                      return "Введите верное значение";
                  },
                ),
                TextFormField(
                  controller: scaleControl,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Введите масштаб (от 0 до 30)",
                      fillColor: Colors.black12,
                      filled: true),
                  validator: (text) {
                    if (text == null || text.isEmpty) return "Введите масштаб";
                    var s = int.tryParse(text);
                    if (s == null || s < 0 || s > 30)
                      return "Введите значение от 0 до 30";
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 256,
                height: 256,
                child: CachedNetworkImage(
                  // placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, _, __) =>
                      const Center(child: Text("Нет парковки")),
                  imageUrl: imgURL,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("x:  $x   y:   $y"),
                const SizedBox(
                  width: 20,
                )
              ],
            ),
          )
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: Column(
          children: [
            FloatingActionButton(child: const Text("+"), onPressed: ()=>{scaleControl.text = "${int.parse(scaleControl.text) + 1}"}),
            const SizedBox(height: 5,),
            FloatingActionButton(child: const Text("-"), onPressed: ()=>{scaleControl.text = "${int.parse(scaleControl.text)- 1}"}),
          ],
        ),
      ),
    );
  }
}
