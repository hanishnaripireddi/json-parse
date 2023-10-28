import 'dart:convert';

import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JsonViewerScreen extends StatefulWidget {
  @override
  _JsonViewerScreenState createState() => _JsonViewerScreenState();
}

class _JsonViewerScreenState extends State<JsonViewerScreen> {
  TextEditingController jsonInputController = TextEditingController();
  List<Widget> formattedJson = [];
  String formattedJsonText = ''; // Store the formatted JSON text

  void formatJson() {
    try {
      final inputJson = jsonInputController.text;
      final parsedData = json.decode(inputJson);

      setState(() {
        formattedJsonText =
            _formatJsonText(parsedData); // Store the formatted JSON text
        formattedJson = [_buildJsonWidget(parsedData)];
      });
    } catch (e) {
      setState(() {
        formattedJson = [
          Text('Invalid JSON', style: TextStyle(color: Colors.red))
        ];
      });
    }
  }

  String _formatJsonText(dynamic data) {
    return JsonEncoder.withIndent('  ').convert(data);
  }

  void copyJsonToClipboard() {
    Clipboard.setData(ClipboardData(text: formattedJsonText));
    if (formattedJsonText.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('JSON copied to clipboard'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No JSON to copy'),
      ));
    }
  }

  Widget _buildJsonWidget(dynamic data, {bool isNested = false}) {
    if (data is Map) {
      final List<Widget> children = [];

      data.forEach((key, value) {
        final valueWidget = _buildJsonWidget(value, isNested: true);
        final keyWidget = Text(
          '"$key": ',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        );

        children.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isNested ? SizedBox(width: 16) : Container(),
            keyWidget,
            valueWidget,
            if (key != data.keys.last)
              Text(',', style: TextStyle(color: Colors.blue)),
          ],
        ));
      });

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('{', style: TextStyle(color: Colors.blue)),
        ...children,
        Text('}', style: TextStyle(color: Colors.blue)),
      ]);
    } else if (data is List) {
      final List<Widget> children = [];

      for (var i = 0; i < data.length; i++) {
        final valueWidget = _buildJsonWidget(data[i], isNested: true);
        children.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isNested ? SizedBox(width: 16) : Container(),
            Text('$i: '),
            valueWidget,
            if (i < data.length - 1)
              Text(',', style: TextStyle(color: Colors.blue)),
          ],
        ));
      }

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('[', style: TextStyle(color: Colors.blue)),
        ...children,
        Text(']', style: TextStyle(color: Colors.blue)),
      ]);
    } else if (data is String) {
      return Text('"$data"', style: TextStyle(color: Colors.orange));
    } else if (data is num) {
      return Text(data.toString(), style: TextStyle(color: Colors.orange));
    } else if (data is bool) {
      return Text(data.toString(), style: TextStyle(color: Colors.green));
    } else if (data == null) {
      return Text('null', style: TextStyle(color: Colors.red));
    } else {
      return Text(data.toString(), style: TextStyle(color: Colors.black));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JSON Viewer'),
      ),
      body: Column(
        children: <Widget>[
          // Top Container for JSON Input
          Container(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: jsonInputController,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: 'Paste JSON Here',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Button to Format JSON
          ElevatedButton(
            onPressed: formatJson,
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).primaryColor,
            ),
            child: Text('Format JSON', style: TextStyle(color: Colors.white)),
          ),
          // Button to Copy JSON
          ElevatedButton(
            onPressed: copyJsonToClipboard,
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).primaryColor,
            ),
            child: Text('Copy JSON', style: TextStyle(color: Colors.white)),
          ),
          // Bottom Container for Formatted JSON Output
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: formattedJson,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
