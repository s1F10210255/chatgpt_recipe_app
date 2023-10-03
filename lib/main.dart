import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  Future<void> _sendMessage(String text) async {
    final String endpoint = 'https://api.openai.iniad.org/api/v1/chat/completions'; // 新しいエンドポイント
    final String apiKey = '';

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',  // モデル名を指定
      'messages': [
        {
          'role': 'system',
          'content': 'You are a helpful assistant.'
        },
        {
          'role': 'user',
          'content': text,  // ユーザからのテキスト
        },
      ],
    });

    final response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: body,
    );



    if (response.statusCode != 200) {
      print('Error: ${response.body}');
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data != null &&
          data.containsKey('choices') &&
          data['choices'] is List &&
          data['choices'].isNotEmpty &&
          data['choices'][0] is Map &&
          data['choices'][0].containsKey('message') &&
          data['choices'][0]['message'] is Map &&
          data['choices'][0]['message'].containsKey('content') &&
          data['choices'][0]['message']['content'] is String) {
        final String reply = data['choices'][0]['message']['content'].trim();
        print('Decoded text: $reply');  // コンソールにデコードされたテキストを出力
        setState(() {
          _messages.add('User: $text');
          _messages.add('GPT: $reply');
        });
      } else {
        print('Unexpected response format');
      }
    } else {
      print('Error: ${response.body}');
    }



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with GPT'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final text = _controller.text;
                    _controller.clear();
                    _sendMessage(text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
