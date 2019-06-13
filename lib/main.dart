import 'package:flutter/material.dart';
import 'package:wireless_street_lamp/provide/config_provide.dart';
import 'package:provide/provide.dart';
import 'package:wireless_street_lamp/pages/config_connect_page.dart';

void main() {
  var configProvide = ConfigProvide();
  var providers  =Providers();
  providers
    ..provide(Provider<ConfigProvide>.value(configProvide));

  runApp(ProviderNode(child:MyApp(),providers:providers));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: MaterialApp(
        title: '无线路灯控制器',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.red
        ),
        home: ConfigConnectPage(),
      ),
    );
  }
}

