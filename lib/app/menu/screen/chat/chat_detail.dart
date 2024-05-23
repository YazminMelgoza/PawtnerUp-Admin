import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawtnerup_admin/config/config.dart';
import 'package:pawtnerup_admin/models/chat_model.dart';
import 'package:pawtnerup_admin/models/message_model.dart';
import 'package:pawtnerup_admin/services/chat_service.dart';
import 'package:pawtnerup_admin/services/pet_service.dart'; 
import 'package:pawtnerup_admin/shared/widgets/custom_image.dart';

import 'package:pawtnerup_admin/app/menu/screen/Pet/petprofile.dart';
import 'package:pawtnerup_admin/app/menu/screen/chat/chat.dart';
import 'package:pawtnerup_admin/models/pet_model.dart';
import 'package:pawtnerup_admin/models/shelter_model.dart';
import 'package:pawtnerup_admin/provider/auth_provider.dart';
import 'package:pawtnerup_admin/services/shelter_service.dart';
import 'package:pawtnerup_admin/utils/ask_confirmation_to_continue.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key, required this.chatData});

  final ChatModel chatData;
  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final ChatService chatService = ChatService();
  final PetService petService = PetService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
  }

  List<MessageModel> _messages = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<MessageModel>>(
        stream: chatService.getMessagesByChatIdStream(widget.chatData.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _messages = snapshot.data!;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
              );
            });
            return getBody(context);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  getMessages() async {
    List<MessageModel> messages =
        await chatService.getMessagesByChatId(widget.chatData.id);
    setState(() {
      _messages = messages;
    });
  }

  Widget _buildTopBar() {

    List<Map<String, dynamic>> options = [
      {
        'value': 'finalizado',
        'color': Colors.green,
        'icon': Icons.check,
      },
      {
        'value': 'en curso',
        'color': Colors.blue,
        'icon': Icons.access_time,
      },
      {
        'value': 'cancelado',
        'color': Colors.red,
        'icon': Icons.cancel,
      },
    ];
    return AppBar(
      title: 
      // show the name of the pet and the shelter in the appbar
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.chatData.userName),
          Text(widget.chatData.petName,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey)
          ),
        ],
      )
      ,
      // show the pet image in the appbar and also the back button without overflow
      leadingWidth: 150,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CustomImage(
            widget.chatData.userImageURL,
            width: 42,
            height: 42,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(20),
            onPressed: () async {
              // go to the pet detail page
              PetModel? petModel = await PetService().getPetById(widget.chatData.petId);
              if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetProfilePage(pet: petModel!, key: Key(petModel.id),)
                ),
              );

              }
            },
          ),
          CustomImage(
            widget.chatData.petImageURL,
            width: 42,
            height: 42,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(20),
            onPressed: () async {
              ShelterModel? shelterModel = await ShelterService().getShelterById(widget.chatData.shelterId);
              if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShelterDetailPage(shelter: shelterModel!)
                ),
              );

              }
            },
            )
        ],
      ),
      actions: [
        // change the conversation status
          DropdownButton(
            items: options.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Row(
                  children: [
                    Icon(option['icon'], color: option['color'], size: 20),
                    const SizedBox(width: 5),
                    Text(option['value']),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) async {
              if (value == null) return;
              bool confirmation = await askConfirmationToContinue(context, '¿Estás seguro de que quieres cambiar el status de la conversación a $value?');
              if (!confirmation) return;
              chatService.updateChatStatus(widget.chatData.id, value.toString());
              setState(() {
                widget.chatData.conversationStatus = value.toString();
              });
            },
            // style the dropdown button
            
          )
        ],
    );
  }

  getBody(context) {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return
              isFromAnotherDay(index) ? 
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(_messages[index].time)),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  _buildMessageItem(_messages[index]),
                ],
              ) : _buildMessageItem(_messages[index]);
            },
          ),
        ),
        _buildInput(),
      ],
    );
  }

  bool isFromAnotherDay(int index) {
    if (index == 0) {
      return true;
    }
    DateTime previousMessageTime =
        DateTime.fromMillisecondsSinceEpoch(_messages[index - 1].time);
    DateTime currentMessageTime =
        DateTime.fromMillisecondsSinceEpoch(_messages[index].time);
    return previousMessageTime.day != currentMessageTime.day;
  }

  Widget _buildMessageItem(MessageModel message) {
    bool isCurrentUser = isMessageFromCurrentUser(message);

    return Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.blue[500] : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(color: 
                  isCurrentUser ? Colors.white : Colors.black
                  ),
                  softWrap: true,
                ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(formatTime(message.time),
                      style: TextStyle(fontSize: 10, 
                      color: isCurrentUser ? Colors.white : Colors.black
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
    );
  }

  String formatTime(int time) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    return DateFormat('HH:mm').format(dateTime);
  }

  bool isMessageFromCurrentUser(MessageModel message) {
    return message.senderId == FirebaseAuth.instance.currentUser!.uid;
  }

  Widget _buildInput() {
    AuthenticationProvider authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: TextField(
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                controller: _messageController,
                decoration: const InputDecoration(
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                  hintText: 'Escribe un mensaje...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColor.darkblue),
            onPressed: () {
              _sendMessage(authProvider.user!);
            },
          ),
        ],
      ),
    );
  }

  _sendMessage(ShelterModel senderUser) async {
    if (_messageController.text.isNotEmpty) {
      MessageModel message = MessageModel(
        id: '',
        content: _messageController.text,
        senderId: senderUser.uid,
        senderName: senderUser.name,
        time: DateTime.now().millisecondsSinceEpoch,
      );
      await chatService.addMessageToChat(widget.chatData.id, message);
      _messageController.clear();
      getMessages();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
