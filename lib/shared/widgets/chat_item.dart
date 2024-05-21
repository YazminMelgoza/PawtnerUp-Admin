import 'package:flutter/material.dart';
import 'custom_image.dart';
import 'package:pawtnerup_admin/models/chat_model.dart';
import 'package:relative_time/relative_time.dart';

class ChatItem extends StatelessWidget {
  const ChatItem(
    this.chatData, {
    super.key,
    this.onTap,
    this.isNotified = true,
    this.profileSize = 50,
  });

  final ChatModel chatData;
  final bool isNotified;
  final GestureTapCallback? onTap;
  final double profileSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildPhoto(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  buildNameAndTime(),
                  const SizedBox(
                    height: 5,
                  ),
                  _buildTextAndNotified(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextAndNotified() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            chatData.recentMessageContent ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoto() {
    if (chatData.userImageURL != '') {
      return CustomImage(
        chatData.userImageURL,
        width: profileSize,
        height: profileSize,
        fit: BoxFit.cover,
        radius: 50,
      );
    }
    else {
      return Container(
        width: profileSize,
        height: profileSize,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(
          Icons.person,
          color: Colors.grey,
          size: 30,
        ),
      );
    }
  }

  Widget buildNameAndTime() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            chatData.userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          chatData.recentMessageTime != null
              ? DateTime.fromMillisecondsSinceEpoch(chatData.recentMessageTime!)
                  .toString()
              : '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        )
      ],
    );
  }
}
