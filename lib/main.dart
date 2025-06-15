import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewFullScreen(),
    );
  }
}

class MyInAppBrowser extends InAppBrowser {
  @override
  Future onExit() async {
    debugPrint("InAppBrowser closed");
  }
}

class WebViewFullScreen extends StatefulWidget {
  const WebViewFullScreen({super.key});

  @override
  State<WebViewFullScreen> createState() => _WebViewFullScreenState();
}

class _WebViewFullScreenState extends State<WebViewFullScreen> {
  InAppWebViewController? _controller;
  final MyInAppBrowser _browser = MyInAppBrowser();

  void _injectCSS() {
    _controller?.evaluateJavascript(
      source: '''
        const style = document.createElement('style');
        style.innerHTML = '.top-gradient { background: transparent !important; }';
        document.head.appendChild(style);
      ''',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        bottom: false,
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri('https://www.tapcargo.com/'),
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            allowsBackForwardNavigationGestures: true,
            supportZoom: false,
          ),
          onWebViewCreated: (controller) {
            _controller = controller;
          },
          onLoadStop: (controller, url) {
            _injectCSS();
          },
          shouldOverrideUrlLoading: (controller, navAction) async {
            final uri = navAction.request.url;

            if (uri != null &&
                uri.host.isNotEmpty &&
                !uri.host.contains('tapcargo.com')) {
              await _browser.openUrlRequest(urlRequest: URLRequest(url: uri));
              return NavigationActionPolicy.CANCEL;
            }

            return NavigationActionPolicy.ALLOW;
          },
        ),
      ),
    );
  }
}
