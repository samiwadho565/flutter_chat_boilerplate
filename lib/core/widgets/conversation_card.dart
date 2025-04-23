import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_circular_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ConversationCard extends StatelessWidget {
  final String name;
  final String profileImage;
  final String lastMessage;
  final bool isOnline;
  final bool isUnread;
  final bool isTyping;
  final bool readByParticipant;
  final String time;
  final int readCount;
  final bool sentByYou;
  final VoidCallback onPress;
  final VoidCallback onDelete;

  const ConversationCard({
    Key? key,
   required this.readCount,
    required this.name,
    required this.readByParticipant,
    required this.profileImage,
    required this.lastMessage,
    required this.isTyping,
    required this.isOnline,
    required this.isUnread,
    required this.time,
    required this.sentByYou,
    required this.onPress,
    required this.onDelete
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
        key: ValueKey(name),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.17,

          children: [

            CustomSlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: Colors.red,
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete,
                    size: 25, // Bigger icon
                    color: Colors.white
                  ),

                ],
              ),
            ),

          ],
        ),child:  CupertinoButton(
      // color: Colors.white,

      padding: EdgeInsets.zero,
      onPressed:onPress,
        // splashColor: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              // color: Color(0xFF555761),
              color: Color(0xfff3f3f3),

              borderRadius: BorderRadius.circular(20),

            ),

              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    // Profile Picture
                    Stack(
                      children: [
                        CustomCircleAvatar(
                          imageUrl: profileImage,
                          radius: 25, // Custom size
                          borderColor: Colors.black38, // Custom border color
                        ),
                  if(isOnline)  Positioned(
                          bottom: 5,

                          right: 5,
                          child: CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 5,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Name and Last Message
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                         name,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          isTyping?  Text(
                       "Typing...",

                            style: TextStyle(color: Colors.black,fontSize: 15,),
                          ): Text(
                          lastMessage,

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black54,fontSize: 15,),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Status and Time
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        if (isUnread && !sentByYou && readCount > 0)
                           CircleAvatar(
                            radius: 11,
                            backgroundColor: Colors.black,
                            child: Text(
                            readCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Text(
                          time,
                          style: const TextStyle(fontSize: 10, color: Colors.black),
                        ),
                        readByParticipant &&   sentByYou? Text(
                          "Read",


                          style: TextStyle(color: Colors.green,fontSize: 12),
                        ): sentByYou? Text(
                          "Sent",


                          style: TextStyle(color: Colors.black54,fontSize: 12),
                        ):SizedBox(),


                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

      ),
    );
  }
}
