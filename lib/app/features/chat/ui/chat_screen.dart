import 'dart:io';

import 'package:animate_do/animate_do.dart';
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
          _scrollController.position.maxScrollExtent + 100, // Extra padding
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
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
      extendBodyBehindAppBar: true, // For glassy effect if needed
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.close, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Comby AI Agent',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20.sp,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'History',
            onPressed: () {
              context.router.push(const ChatHistoryScreenRoute());
            },
          ),
          IconButton(
            icon: const Icon(Icons.video_call_rounded),
            tooltip: 'Live Stylist',
            onPressed: () {
              context.router.push(const LiveStylistPageRoute());
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FE), // Premium soft background
        ),
        child: SafeArea(
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
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                          content: Text(
                            state.errorMessage ??
                                AppLocalizations.of(context).errorOccurredChat,
                            style: const TextStyle(color: Colors.white),
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
                              "Hi, I'm Comby! 👋\n\nPowered by Gemini 3, I can help you create great outfits based on the weather!",
                          isUser: false,
                        );

                        return ListView(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 24.h),
                          children: [
                            FadeInUp(
                              duration: const Duration(milliseconds: 600),
                              child: _MessageBubble(
                                message: welcomeMessage,
                                fromHistory: widget.fromHistory,
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 24.h),
                        itemCount: state.messages.length +
                            (state.status == ChatStatus.loading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.messages.length) {
                            return FadeInUp(
                              duration: const Duration(milliseconds: 400),
                              child: _LoadingBubble(
                                message: state.agentThinkingText,
                              ),
                            );
                          }

                          final message = state.messages[index];
                          return FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: _MessageBubble(
                                key: ValueKey('$index-${message.text}'),
                                message: message,
                                fromHistory: widget.fromHistory,
                              ),
                            ),
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
                    padding: EdgeInsets.only(bottom: 8.h),
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
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.w, 16.w,
          MediaQuery.of(context).viewInsets.bottom > 0 ? 12.w : 24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment Button
          Container(
            margin: EdgeInsets.only(bottom: 4.h),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.add_photo_alternate_rounded,
                  color: Colors.grey[600], size: 22.sp),
              onPressed: () => _pickMedia(context),
              tooltip: "Add Media",
            ),
          ),
          SizedBox(width: 12.w),
          // Text Input
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.grey[50], // Very light grey input
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _textController,
                minLines: 1,
                maxLines: 5,
                style: TextStyle(fontSize: 15.sp, height: 1.4),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).writeYourMessage,
                  hintStyle:
                      TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Send Button
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final isLoading = state.status == ChatStatus.loading;
              return Container(
                margin: EdgeInsets.only(bottom: 4.h),
                child: CircleAvatar(
                  radius: 22.r,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: isLoading
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Icon(Icons.arrow_upward_rounded,
                            color: Colors.white, size: 22.sp),
                    onPressed: isLoading ? null : _sendMessage,
                    tooltip: "Send Message",
                  ),
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

    // Premium Styling
    final userGradient = LinearGradient(
      colors: [
        Theme.of(context).primaryColor,
        Theme.of(context).primaryColor.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final agentColor = Colors.white;
    final textColor = isUser ? Colors.white : const Color(0xFF2D3748);

    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(20.r),
      topRight: Radius.circular(20.r),
      bottomLeft: isUser ? Radius.circular(20.r) : Radius.circular(4.r),
      bottomRight: isUser ? Radius.circular(4.r) : Radius.circular(20.r),
    );

    return Column(
      crossAxisAlignment: align,
      children: [
        // Optional: Agent Name/Icon
        if (!isUser)
          Padding(
            padding: EdgeInsets.only(left: 8.w, bottom: 4.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 8.r,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(Icons.auto_awesome,
                      size: 10.sp, color: Colors.white),
                ),
                SizedBox(width: 6.w),
                Text(
                  "Comby",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          decoration: BoxDecoration(
            gradient: isUser ? userGradient : null,
            color: isUser ? null : agentColor,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: isUser
                    ? Theme.of(context).primaryColor.withOpacity(0.2)
                    : Colors.black.withOpacity(0.04), // Softer shadow
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            // Subtle border for agent messages to pop from white background
            border: isUser
                ? null
                : Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
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
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.file(
                        File(path),
                        width: 120.w,
                        height: 120.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120.w,
                            height: 120.w,
                            color: Colors.grey[200],
                            child: Icon(Icons.broken_image_rounded,
                                color: Colors.grey[400]),
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
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: message.imageUrls!.map((url) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        url,
                        width: 120.w,
                        height: 120.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120.w,
                            height: 120.w,
                            color: Colors.grey[200],
                            child: Icon(Icons.broken_image_rounded,
                                color: Colors.grey[400]),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 120.w,
                            height: 120.w,
                            color: Colors.grey[100],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),
              ],

              // ✅ Text BELOW (description)
              if (message.text.isNotEmpty)
                MarkdownText(
                  message.text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.5.sp, // Slightly larger for readability
                    height: 1.5, // Better line height
                    fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),

              // ✅ Real-time Image Generation Status
              if (message.visualRequestId != null) ...[
                SizedBox(height: 16.h),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.1)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: FalImageWidget(
                      requestId: message.visualRequestId!,
                      isLive: fromHistory == true ? false : true,
                    ),
                  ),
                ),
              ],

              // 📍 Location Permission Request Button
              if (message.requestsLocation) ...[
                SizedBox(height: 16.h),
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _handlePermission,
        icon: _isProcessing
            ? SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.location_on_rounded, size: 18),
        label: const Text("Share Location"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[50], // Soft accent background
          foregroundColor: Colors.blue[700],
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: Colors.blue.withOpacity(0.3)),
          ),
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
      child: Padding(
        padding: EdgeInsets.only(left: 8.w), // Align with avatar
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h, right: 50.w),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isThought ? const Color(0xFFF0F4FF) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
              bottomLeft: Radius.circular(4.r), // Agent tail
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: isThought
                ? Border.all(color: Colors.blue.withOpacity(0.2), width: 1)
                : Border.all(color: const Color(0xFFE2E8F0), width: 1),
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
                  width: 18.w,
                  height: 18.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
              if (message != null) ...[
                SizedBox(width: 12.w),
                Flexible(
                  child: Text(
                    isThought ? message!.substring(2).trim() : message!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isThought
                          ? Colors.blue[800]
                          : Colors.grey[600], // Cleaner grey
                      fontStyle: FontStyle.italic,
                      fontWeight:
                          isThought ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
