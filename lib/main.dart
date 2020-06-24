import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:event_bus/event_bus.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oboard/setting.dart';
import 'package:provider/provider.dart';
import 'package:sensors/sensors.dart';
import 'package:window_size/window_size.dart' as window_size;

import 'app_provider.dart';
import 'board.dart';
import 'color_choose.dart';
import 'rotated_view.dart';

Brightness brightness = Brightness.dark;
EventBus eventBus = EventBus();

double sx = 0, sy = 0, sz = 0;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  window_size.getWindowInfo().then((window) {
    if (window.screen != null) {
      final screenFrame = window.screen.visibleFrame;
      final width = math.max((screenFrame.width / 2).roundToDouble(), 600.0);
      final height = math.max((screenFrame.height / 2).roundToDouble(), 800.0);
      final left = ((screenFrame.width - width) / 2).roundToDouble();
      final top = ((screenFrame.height - height) / 3).roundToDouble();
      final frame = Rect.fromLTWH(left, top, width, height);
      window_size.setWindowFrame(frame);
      window_size.setWindowTitle(appTitle);

      if (Platform.isMacOS) {
        window_size.setWindowMinSize(Size(600, 800));
        window_size.setWindowMaxSize(Size(1200, 1600));
      }
    }
  });

  runApp(App());
}

class App extends StatelessWidget {
  Color _themeColor;

  @override
  Widget build(BuildContext context) {
//    Provider.of<AppInfoProvider>(context, listen: false)
//        .setTheme(_colorKey);
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: AppInfoProvider())],
      child: Consumer<AppInfoProvider>(
        builder: (context, appInfo, _) {
          if (themeColorMap[colorKey] != null) {
            _themeColor = themeColorMap[colorKey];
          }
          return MaterialApp(
            theme: ThemeData(
              brightness: brightness,
              primaryColor: _themeColor,
              floatingActionButtonTheme:
                  FloatingActionButtonThemeData(backgroundColor: _themeColor),
            ),
            title: appTitle,
            home: HomePage(),
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      brightness = WidgetsBinding.instance.window.platformBrightness;
      setBarStatus(
          context,
          WidgetsBinding.instance.window.platformBrightness ==
              Brightness.light);

      Provider.of<AppInfoProvider>(context, listen: false).setTheme(null);
    });
    //inform listeners and rebuild widget tree
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    eventBus.on().listen((event) {
      setState(() {});
    });

    _initAsync();
  }

  _initAsync() async {
    /// App启动时读取Sp数据，需要异步等待Sp初始化完成。
    await SpUtil.getInstance();
    bool isFirst = SpUtil.getBool('first', defValue: true);
    int value = SpUtil.getInt('sensor');

    if (value == 3 || value == 1)
      gyroscopeEvents.listen((GyroscopeEvent event) {
        sx += event.x;
        sy += event.y;
        sz += event.z;
        setState(() {});
      });
    if (value == 3 || value == 2)
      accelerometerEvents.listen((AccelerometerEvent event) {
        sx += event.y / 10;
        sy -= event.x / 10;
        sz += event.y / 10;
        setState(() {});
      });
    if (isFirst) {
      SpUtil.putString('key_theme_color', 'teal');
      SpUtil.putInt('sensor', 1);
      SpUtil.putBool('first', false);
    } else {
      setState(() {
        colorKey = SpUtil.getString('key_theme_color');
      });
    }
  }

  setBarStatus(BuildContext context, bool isDarkIcon,
      {Color color: Colors.transparent}) async {
    if (Platform.isAndroid) {
//    if (MediaQueryData.fromWindow(window).viewInsets.bottom < 20) {
//      return;
//    }
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
      Brightness brightness = isDarkIcon ? Brightness.dark : Brightness.light;
      Brightness brightness2 = isDarkIcon ? Brightness.light : Brightness.dark;
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
          statusBarColor: color,
          systemNavigationBarColor: color,
          systemNavigationBarIconBrightness: brightness,
          statusBarIconBrightness: brightness);

      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
  }

  @override
  Widget build(BuildContext context) {
    brightness = MediaQuery.of(context).platformBrightness;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Board(),
          Transform.translate(
            offset:
                Offset(screenW - radius - 16 - 20, screenH - radius - 16 - 20),
            child: RotatedView(
              child: CircleTrianglePage(),
              haveinertia: true,
            ),
          ),
          Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Wrap(
                          spacing: 16.0,
                          children: <Widget>[
                            FloatingActionButton(
                              onPressed: () {
                                turnToPage(context, SettingPage());
                              },
                              mini: true,
                              tooltip: 'Setting',
                              heroTag: 2,
                              child: Icon(Icons.settings),
                            ),
                            FloatingActionButton(
                              onPressed: () {
                                boardEvent.fire('clear');
                              },
                              mini: true,
                              heroTag: 1,
                              tooltip: 'Clear',
                              child: Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                      FloatingActionButton(
                        onPressed: () {},
                        mini: true,
                        heroTag: 3,
                        tooltip: 'Color',
                        backgroundColor: paintColor,
                      )
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

turnToPage(BuildContext context, Widget page) {
  Navigator.push(context, CustomRoute(page));
}

//滑动效果

//class CustomRouteSlide extends PageRouteBuilder {
//  final Widget widget;
//
//  CustomRouteSlide(this.widget)
//      : super(
//            transitionDuration: const Duration(milliseconds: 500),
//            pageBuilder: (BuildContext context, Animation<double> animation1,
//                Animation<double> animation2) {
//              return widget;
//            },
//            transitionsBuilder: (BuildContext context,
//                Animation<double> animation1,
//                Animation<double> animation2,
//                Widget child) {
//              return SlideTransition(
//                position: Tween<Offset>(
//                        begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
//                    .animate(CurvedAnimation(
//                        parent: animation1, curve: Curves.decelerate)),
//                child: BackdropFilter(
//                  filter: ImageFilter.blur(
//                      sigmaX: animation1.value * 10,
//                      sigmaY: animation1.value * 10),
//                  child: child,
//                ),
//              );
//            });
//}
class CustomRoute extends PageRouteBuilder {
  final Widget widget;

  CustomRoute(this.widget)
      : super(
            // 设置过度时间
            transitionDuration: Duration(milliseconds: 500),
            // 构造器
            pageBuilder: (
              // 上下文和动画
              BuildContext context,
              Animation<double> animation1,
              Animation<double> animation2,
            ) {
              return widget;
            },
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation1,
              Animation<double> animation2,
              Widget child,
            ) {
              // 缩放动画效果
              return BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: animation1.value * 10,
                    sigmaY: animation1.value * 10),
                child: Opacity(
                  opacity: animation1.value,
                  child: Container(
                    color: Colors.black12,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 1.0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                            parent: animation1,
                            curve: Curves.linearToEaseOut,
                            reverseCurve: Curves.fastOutSlowIn),
                      ),
                      child: child,
                    ),
                  ),
                ),
              );
            });
}

class FadeRoute extends PageRoute {
  FadeRoute({
    @required this.pageBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.opaque = true,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
    this.maintainState = true,
  });

  final WidgetBuilder pageBuilder;

  @override
  final Duration transitionDuration;

  @override
  final bool opaque;

  @override
  final bool barrierDismissible;

  @override
  final Color barrierColor;

  @override
  final String barrierLabel;

  @override
  final bool maintainState;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
      pageBuilder(context);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: pageBuilder(context),
    );
  }
}
