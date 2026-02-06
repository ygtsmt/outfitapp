import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:comby/app/features/chat/widgets/fal_image_widget.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:comby/core/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:comby/app/features/chat/bloc/chat_bloc.dart';
import 'package:comby/app/features/chat/widgets/chat_suggestion_chips.dart';
import 'package:comby/app/features/chat/widgets/media_preview_widget.dart';
import 'package:comby/app/features/chat/widgets/markdown_text.dart';
import 'package:comby/core/ui/widgets/reusable_gallery_picker.dart';
import 'package:comby/generated/l10n.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';

class ChatScreen extends StatefulWidget {
  final bool fromHistory;
  const ChatScreen({super.key, this.fromHistory = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _useDeepThink = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _textController.text.trim();
    if (message.isEmpty) return;

    context.read<ChatBloc>().add(
          SendMessageEvent(message, useDeepThink: _useDeepThink),
        );

    _textController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
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

    if (!mounted) return;

    if (result != null && result.selectedFiles.isNotEmpty) {
      final paths = result.selectedFiles.map((f) => f.path).toList();
      context.read<ChatBloc>().add(SelectMediaEvent(paths));
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Comby AI Agent',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.router.push(const ChatHistoryScreenRoute());
            },
          ),
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              context.router.push(const LiveStylistPageRoute());
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            /// MESSAGES
            Expanded(
              child: BlocListener<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state.status == ChatStatus.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.errorMessage ??
                              AppLocalizations.of(context).errorOccurredChat,
                        ),
                      ),
                    );
                  }
                  _scrollToBottom();
                },
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state.messages.isEmpty &&
                        state.status == ChatStatus.initial) {
                      const welcomeMessage = ChatMessage(
                        text:
                            "Hi, I'm Comby! 👋\n\nHow about creating a great outfit based on the weather?",
                        isUser: false,
                      );

                      return ListView(
                        controller: _scrollController,
                        padding: EdgeInsets.all(12.h),
                        children: [
                          _MessageBubble(
                            message: welcomeMessage,
                            fromHistory: widget.fromHistory,
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(12.h),
                      itemCount: state.messages.length +
                          (state.status == ChatStatus.loading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.messages.length) {
                          return _LoadingBubble(
                            message: state.agentThinkingText,
                          );
                        }

                        final message = state.messages[index];
                        return _MessageBubble(
                          key: ValueKey('$index-${message.text}'),
                          message: message,
                          fromHistory: widget.fromHistory,
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            /// MEDIA PREVIEW
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

            /// SUGGESTIONS
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state.status == ChatStatus.loading) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: ChatSuggestionChips(
                    hasMedia: state.selectedMedia.isNotEmpty,
                    onChipSelected: (text) {
                      context.read<ChatBloc>().add(
                            SendMessageEvent(
                              text,
                              useDeepThink: _useDeepThink,
                            ),
                          );
                      _scrollToBottom();
                    },
                  ),
                );
              },
            ),

            /// INPUT
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.w, 12.w,
          MediaQuery.of(context).viewInsets.bottom > 0 ? 8.w : 16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () => _pickMedia(context),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: TextField(
                controller: _textController,
                minLines: 1,
                maxLines: 5,
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
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                  onPressed:
                      state.status == ChatStatus.loading ? null : _sendMessage,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool? fromHistory;

  const _MessageBubble(
      {super.key, required this.message, required this.fromHistory});

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
              // ✅ Local media sent by the user (user messages)
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
              // ✅ Visuals from AI (imageUrls)
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

              // ✅ Text BELOW (description) - with bold support
              MarkdownText(
                message.text,
                style: TextStyle(
                  color: textColor?.withOpacity(0.8),
                  fontSize: 12.sp,
                ),
              ),

              // ✅ Real-time Image Generation Status
              if (message.visualRequestId != null)
                FalImageWidget(
                  requestId: message.visualRequestId!,
                  isLive: fromHistory == true ? false : true,
                ),

              // 📍 Location Permission Request Button
              if (message.requestsLocation) ...[
                SizedBox(height: 12.h),
                _LocationPermissionButton(
                  onPermissionGranted: () {
                    context.read<ChatBloc>().add(
                          const SendMessageEvent(
                            "Location permission granted! Please optimize my outfit for the real-time weather in my current city.",
                          ),
                        );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationPermissionButton extends StatefulWidget {
  final VoidCallback? onPermissionGranted;

  const _LocationPermissionButton({this.onPermissionGranted});

  @override
  State<_LocationPermissionButton> createState() =>
      _LocationPermissionButtonState();
}

class _LocationPermissionButtonState extends State<_LocationPermissionButton> {
  bool _isProcessing = false;

  Future<void> _handlePermission() async {
    setState(() => _isProcessing = true);
    try {
      final locationService = GetIt.I<LocationService>();
      final permission = await locationService.requestPermission();

      if (permission == LocationPermission.deniedForever) {
        await locationService.openAppSettings();
      }

      if (mounted) {
        final granted = permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always;

        if (granted) {
          widget.onPermissionGranted?.call();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(granted
                ? "Location permission granted! ✨"
                : "Location permission denied."),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isProcessing ? null : _handlePermission,
      icon: _isProcessing
          ? SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.location_on_rounded),
      label: const Text("Grant Location Permission"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[700],
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

class _LoadingBubble extends StatelessWidget {
  final String? message;
  const _LoadingBubble({this.message});

  @override
  Widget build(BuildContext context) {
    // Check if message is a thought signature (starts with 💭)
    final isThought = message?.startsWith('💭') ?? false;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h, right: 50.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isThought ? Colors.blue[50] : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.r),
            topRight: Radius.circular(12.r),
            bottomRight: Radius.circular(12.r),
          ),
          border:
              isThought ? Border.all(color: Colors.blue[200]!, width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isThought) ...[
              // Thought signature indicator
              Text(
                '🧠',
                style: TextStyle(fontSize: 20.sp),
              ),
            ] else ...[
              // Loading spinner
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Theme.of(context).primaryColor),
              ),
            ],
            if (message != null) ...[
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  isThought ? message!.substring(2).trim() : message!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isThought ? Colors.blue[900] : Colors.grey[600],
                    fontStyle: FontStyle.italic,
                    fontWeight: isThought ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
