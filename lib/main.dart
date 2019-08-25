import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Issues',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Issues'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
//  @override
//  _WebViewPageState createWebView() => _WebViewPageState();
}

class Issue {
  Issue({
    this.title,
    this.avataUrl,
    this.htmlUrl,
  });

  final String title;
  final String avataUrl;
  final String htmlUrl;
}

class _MyHomePageState extends State<MyHomePage> {
  List<Issue> _issues = <Issue>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res =
        await http.get('https://api.github.com/repositories/31792824/issues');
    final data = json.decode(res.body);
    setState(() {
      final issues = data as List;
      issues.forEach((dynamic element) {
        final issue = element as Map;
        _issues.add(Issue(
          title: issue['title'] as String,
          avataUrl: issue['user']['avatar_url'] as String,
          htmlUrl: issue['html_url'] as String,
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (index >= _issues.length) {
            return null;
          }

          final issue = _issues[index];
          return ListTile(
            leading: ClipOval(
              child: Image.network(issue.avataUrl),
            ),
            onTap: () {
              print(issue.htmlUrl);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WebViewPage(url: issue.htmlUrl)),
              );
            },
            title: Text(issue.title),
          );
        },
      ),
    );
  }
}

class WebViewPage extends StatefulWidget {
  WebViewPage({Key key, @required this.url}) : super(key: key);
  final String url;

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WebView"),
      ),
      body: WebView(
        initialUrl: (widget.url),
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          print("WebView Created!");
        },
      ),
    );
  }
}
