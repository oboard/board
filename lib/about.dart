import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String ver = '1.0beta';
String bun = '1';
String nam = '小板子';

class AboutPage extends StatefulWidget {
  const AboutPage({Key key}) : super(key: key);

  @override
  AboutPageState createState() => new AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  @override
  Future didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: Theme.of(context),
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text("关于"),
        ),
        body: ListView(
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(8.0),
              child: Center(
                child: new Column(
                  children: <Widget>[
                    Container(
                      decoration: new BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: InkResponse(
                        radius: 1000,
                        onLongPress: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          '''
小板子
                        ''',
                          style: Theme.of(context).textTheme.title.copyWith(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      padding: EdgeInsets.all(50),
                    ),
                    new Divider(),
                    new Text(
                      '$nam',
                      style: new TextStyle(fontSize: 20),
                    ),
                    new Text('$ver($bun)'),
                    new Divider(),
                    new Text(
                      '''
\
本软件永久免费
酷安：一块小板子
QQ:2232442466\"''',
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    )
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

final key = new GlobalKey<ScaffoldState>();

class DonatePage extends StatefulWidget {
  const DonatePage({Key key}) : super(key: key);

  @override
  DonatePageState createState() => new DonatePageState();
}

class DonatePageState extends State<DonatePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Theme(
      data: Theme.of(context),
      child: new Scaffold(
        key: key,
        appBar: new AppBar(
          title: new Text("捐赠"),
        ),
        body: new Padding(
          padding: EdgeInsets.all(8.0),
          child: new SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                //new Image.asset("images/qrpay.png"),
                new FlatButton.icon(
                  icon: new Icon(Icons.attach_money),
                  label: new Text('复制捐款链接'),
                  onPressed: () async {
                    const url = 'http://esa7y5.coding-pages.com/';
                    Clipboard.setData(new ClipboardData(text: url));
                    key.currentState.showSnackBar(
                        new SnackBar(content: new Text('已复制到剪辑版')));
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
