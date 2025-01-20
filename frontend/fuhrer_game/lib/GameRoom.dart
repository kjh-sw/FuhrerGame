// game_room.dart
import 'package:flutter/material.dart';
import 'WebsocketService.dart';

class GameRoomPage extends StatefulWidget {
  final String roomName;

  const GameRoomPage({super.key, required this.roomName});

  @override
  _GameRoomPageState createState() => _GameRoomPageState();
}

class _GameRoomPageState extends State<GameRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  late WebSocketService _webSocketService; // WebSocketService 필드 정의
  final List<Map<String, dynamic>> _messages = []; // 메시지 리스트


  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketService();
    _webSocketService.connect((messageData) {
      setState(() {
        // JSON 데이터만 추가
        if (messageData is Map<String, dynamic>) {
          _messages.add(messageData);
          print('_messages: $_messages'); // 추가된 메시지 확인
        } else {
          print('Invalid message format: $messageData');
        }
      });
    });
  }


  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final username = "User1"; // 사용자 이름 설정
      final content = _messageController.text;

      _webSocketService.sendMessage(username, content); // 메시지 전송
      _messageController.clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(widget.roomName),
        backgroundColor: Colors.brown[400],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length, // 전체 메시지 개수
              reverse: true, // 최신 메시지가 아래에 표시되도록
              itemBuilder: (context, index) {
                // 메시지를 Map<String, dynamic> 타입으로 캐스팅
                final Map<String, dynamic> message = _messages[_messages.length - 1 - index];

                return Align(
                  alignment: message['username'] == "User1"
                      ? Alignment.centerRight // 본인의 메시지는 오른쪽
                      : Alignment.centerLeft, // 다른 사용자의 메시지는 왼쪽
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: message['username'] == "User1"
                          ? Colors.brown[400] // 본인의 메시지는 브라운 색상
                          : Colors.grey[700], // 다른 사용자의 메시지는 회색
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${message['username'] ?? 'Unknown'}: ${message['content'] ?? 'No content'}",
                      style: const TextStyle(color: Colors.white), // 텍스트 색상은 흰색
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.orange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
