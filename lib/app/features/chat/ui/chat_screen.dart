import 'dart:io';

import 'package:comby/app/features/chat/widgets/chat_suggestion_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/features/chat/bloc/chat_bloc.dart';
import 'package:comby/app/features/chat/widgets/markdown_text.dart';
import 'package:comby/app/features/chat/widgets/media_preview_widget.dart';
import 'package:comby/app/features/chat/widgets/fal_image_widget.dart';
import 'package:comby/core/ui/widgets/reusable_gallery_picker.dart';
import 'package:comby/generated/l10n.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final message = _textController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatBloc>().add(SendMessageEvent(message));
      _textController.clear();
      _scrollToBottom();
    }
  }

  Future<void> _pickMedia(BuildContext context) async {
    final result = await ReusableGalleryPicker.show(
      context: context,
      title: AppLocalizations.of(context).selectMedia,
      mode: GallerySelectionMode.multi,
      maxSelection: 5,
      enableCrop: false,
      showCameraButton: true,
    );

    if (result != null && result.selectedFiles.isNotEmpty && mounted) {
      final paths = result.selectedFiles.map((f) => f.path).toList();
      context.read<ChatBloc>().add(SelectMediaEvent(paths));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: BlocListener<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state.status == ChatStatus.success) {
                  _scrollToBottom();
                } else if (state.status == ChatStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.errorMessage ??
                            AppLocalizations.of(context).errorOccurredChat)),
                  );
                }
              },
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state.messages.isEmpty &&
                      state.status == ChatStatus.initial) {
                    return Center(
                      child: Text(
                        'Start Chatting',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(8.h),
                    itemCount: state.messages.length +
                        (state.status == ChatStatus.loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.messages.length) {
                        return const _LoadingBubble();
                      }
                      final message = state.messages[index];
                      return _MessageBubble(message: message);
                    },
                  );
                },
              ),
            ),
          ),

          // Media preview above input
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              return MediaPreviewWidget(
                mediaPaths: state.selectedMedia,
                onClear: () {
                  context.read<ChatBloc>().add(const ClearMediaEvent());
                },
              );
            },
          ),
          // Suggestion Chips (Only show if not loading)
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state.status == ChatStatus.loading) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: ChatSuggestionChips(
                  hasMedia: state.selectedMedia.isNotEmpty,
                  onChipSelected: (text) {
                    context.read<ChatBloc>().add(SendMessageEvent(text));
                  },
                ),
              );
            },
          ),

          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // ✅ Attachment button
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () => _pickMedia(context),
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).writeYourMessage,
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                return CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: state.status == ChatStatus.loading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: state.status == ChatStatus.loading
                        ? null
                        : _sendMessage,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color =
        isUser ? Theme.of(context).primaryColor : Theme.of(context).cardColor;
    final textColor =
        isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color;
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(12.r),
      topRight: Radius.circular(12.r),
      bottomLeft: isUser ? Radius.circular(12.r) : Radius.zero,
      bottomRight: isUser ? Radius.zero : Radius.circular(12.r),
    );

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: EdgeInsets.only(
              bottom: 8.h, left: isUser ? 50.w : 0, right: isUser ? 0 : 50.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
            boxShadow: [
              if (!isUser)
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Kullanıcının gönderdiği local media (user messages)
              if (message.localMediaPaths != null &&
                  message.localMediaPaths!.isNotEmpty) ...[
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: message.localMediaPaths!.map((path) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        File(path),
                        width: 120.w,
                        height: 120.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120.w,
                            height: 120.w,
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 12.h),
              ],
              // ✅ AI'dan gelen görseller (imageUrls)
              if (message.imageUrls != null &&
                  message.imageUrls!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: message.imageUrls!.map((url) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        url,
                        width: 120.w,
                        height: 120.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120.w,
                            height: 120.w,
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 80.w,
                            height: 80.w,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 12.h),
              ],

              // ✅ Metin ALTA (açıklama) - Bold desteğiyle
              MarkdownText(
                message.text,
                style: TextStyle(
                  color: textColor?.withOpacity(0.8),
                  fontSize: 12.sp,
                ),
              ),

              // ✅ Real-time Image Generation Status
              if (message.visualRequestId != null) ...[
                SizedBox(height: 12.h),
                FalImageWidget(requestId: message.visualRequestId!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadingBubble extends StatelessWidget {
  const _LoadingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h, right: 50.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.r),
            topRight: Radius.circular(12.r),
            bottomRight: Radius.circular(12.r),
          ),
        ),
        child: SizedBox(
          width: 40.w,
          height: 20.h,
          child: Center(
              child: SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Theme.of(context).primaryColor))),
        ),
      ),
    );
  }
}
