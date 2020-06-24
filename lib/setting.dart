import 'dart:async';
import 'dart:ui';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'about.dart';
import 'app_provider.dart';
import 'main.dart';

String colorKey = 'teal', appTitle = '小板子';
int sensorKey = 1;

Map<String, Color> themeColorMap = {
  'gray': Colors.grey,
  'blue': Colors.blue,
  'blueAccent': Colors.blueAccent,
  'cyan': Colors.cyan,
  'deepPurple': Colors.purple,
  'deepPurpleAccent': Colors.deepPurpleAccent,
  'deepOrange': Colors.orange,
  'green': Colors.green,
  'indigo': Colors.indigo,
  'indigoAccent': Colors.indigoAccent,
  'orange': Colors.orange,
  'purple': Colors.purple,
  'pink': Colors.pink,
  'red': Colors.red,
  'teal': Colors.teal,
  'black': Colors.black,
};

Map<int, String> sensorMap = {
  0: '无',
  1: '仅陀螺仪',
  2: '仅加速度传感器',
  3: '两者共用',
};

class SettingPage extends StatefulWidget {
  const SettingPage({Key key}) : super(key: key);

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  @override
  Future didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('设置'),
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    ExpansionTile(
                      leading: Icon(Icons.color_lens),
                      title: Text('颜色主题'),
                      initiallyExpanded: false,
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: themeColorMap.keys.map((key) {
                              Color value = themeColorMap[key];
                              return InkWell(
                                onTap: () {
                                  SpUtil.putString('key_theme_color', key);
                                  setState(() {
                                    colorKey = key;
                                  });

                                  Provider.of<AppInfoProvider>(context,
                                          listen: false)
                                      .setTheme(key);
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  color: value,
                                  child: colorKey == key
                                      ? Icon(
                                          Icons.done,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                    ExpansionTile(
                      leading: Icon(Icons.settings_overscan),
                      title: Text('传感器模式'),
                      initiallyExpanded: false,
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          child: Wrap(
                            spacing: 3,
                            runSpacing: 3,
                            children: sensorMap.keys.map((key) {
                              int value = SpUtil.getInt('sensor');
                              return InkWell(
                                onTap: () {
                                  SpUtil.putInt('sensor', key);
                                  setState(() {
                                    sensorKey = key;
                                  });
                                },
                                child: Container(
                                  height: 40,
                                  child: Row(
                                    children: [
                                      Text(sensorMap[key]),
                                      value == key
                                          ? Icon(
                                              Icons.done,
                                            )
                                          : Icon(
                                              Icons.done,
                                              color: Colors.transparent,
                                            ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                    ListTile(
                      leading: Icon(Icons.help),
                      title: Text(
                        '关于',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () {
                        turnToPage(context, AboutPage());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
