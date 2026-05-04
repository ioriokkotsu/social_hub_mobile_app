import 'package:flutter/material.dart';
import 'package:social_hub/theme/theme.dart';
class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMuted),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.blue500.withOpacity(0.1), shape: BoxShape.circle), child: const Center(child: Text('EG', style: TextStyle(color: AppColors.blue500, fontSize: 12, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('EduGlobal Team', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Online', style: TextStyle(color: AppColors.secondary, fontSize: 10)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              children: [
                const Center(child: Padding(padding: EdgeInsets.only(bottom: 16), child: Text('Today', style: TextStyle(fontSize: 10, color: AppColors.textMuted)))),
                _buildMessageBubble(msg: 'Hello Alex! Thanks for joining the Rural Tech initiative. Do you have experience with HTML?', isMe: false),
                _buildMessageBubble(msg: 'Hi! Yes, I\'m a web developer. I\'d love to help out with the curriculum.', isMe: true),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.gray100))),
            child: Row(
              children: [
                const Icon(Icons.attach_file, color: AppColors.textMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: AppColors.appBg, borderRadius: BorderRadius.circular(24)),
                    child: const TextField(decoration: InputDecoration(hintText: 'Type a message...', border: InputBorder.none, hintStyle: TextStyle(fontSize: 14, color: AppColors.textMuted))),
                  ),
                ),
                const SizedBox(width: 12),
                Container(width: 40, height: 40, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.send, color: Colors.white, size: 18)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessageBubble({required String msg, required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          border: isMe ? null : Border.all(color: AppColors.gray100),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Text(msg, style: TextStyle(fontSize: 14, color: isMe ? Colors.white : AppColors.textMain, height: 1.4)),
      ),
    );
  }
}