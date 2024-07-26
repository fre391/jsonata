library jsonata;

import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Jsonata {
  HeadlessInAppWebView? headlessWebView;
  Completer<void> webViewCreated = Completer<void>();
  InAppWebViewController? controller;
  String jql = "";
  String data = "";
  late var results = [];
  final Random _random = Random(); // Instance of Random to generate unique IDs

  Jsonata([String? jql]) {
    if (jql != null) {
      this.jql = jql.trim();
    }
  }

  void set({dynamic data, dynamic jql}) {
    if (data != null) {
      this.data = data;
    }
    if (jql != null) {
      this.jql = jql;
    }
  }

  Future<Map> query([String? jql]) async {
    if (jql != null) {
      this.jql = jql.trim();
    }
    var result = await evaluate(data);
    return result;
  }

  Future<void> initialize() async {
    String script = await _loadJavaScriptFromAsset();

    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri("about:blank")),
      onWebViewCreated: (c) {
        controller = c;
        controller!.evaluateJavascript(source: script);
        controller!.evaluateJavascript(source: "initialize($data)");
        controller!.addJavaScriptHandler(
            handlerName: 'json',
            callback: (args) async {
              results.add(args[0]);
            });
        webViewCreated.complete();
      },
      onConsoleMessage: (controller, consoleMessage) {
        // ignore: avoid_print
        print(consoleMessage.message);
      },
    );

    await headlessWebView?.run();
    await webViewCreated.future;
  }

  Future<String> _loadJavaScriptFromAsset() async {
    //return await rootBundle.loadString('lib/assets/script.js');
    return await rootBundle.loadString('packages/jsonata/lib/assets/script.js');
  }

  void dispose() {
    headlessWebView?.dispose();
  }

  Future<Map> evaluate(String data) async {
    this.data = data.trim();
    initialize();

    const timeoutDuration = Duration(seconds: 10); // Adjust timeout as needed
    final id = _generateUniqueId(); // Generate a unique ID

    try {
      var result = {};
      bool found = false;

      await Future.any([
        // This future handles waiting for the controller and executing JavaScript
        () async {
          // Wait until the controller is initialized
          while (!webViewCreated.isCompleted) {
            await Future.delayed(const Duration(milliseconds: 100));
          }

          // Execute the JavaScript with the generated ID
          await controller!.evaluateJavascript(source: "query($id, '${jql.replaceAll("'", '"')}')");

          // Wait for the result
          while (!found) {
            for (var element in results) {
              if (element.containsKey('id') && element['id'] == id) {
                result = {'value': element['value'], 'error': element['error']};
                found = true;
                results.remove(element);
                break;
              }
            }
            if (!found) {
              await Future.delayed(const Duration(milliseconds: 100));
            }
          }
        }(),

        Future.delayed(timeoutDuration).then((_) {
          if (!found) {
            throw TimeoutException('Query timed out');
          }
        }),
      ]);

      return result;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Method to generate a unique ID
  int _generateUniqueId() {
    return _random.nextInt(1000000); // Generates a random integer up to 999999
  }
}
