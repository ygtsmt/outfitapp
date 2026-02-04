import 'package:auto_route/auto_route.dart';
import 'package:comby/app/features/chat/bloc/chat_bloc.dart';
import 'package:comby/app/features/chat/data/chat_repository.dart';
import 'package:comby/app/features/chat/models/chat_session_model.dart';
import 'package:comby/core/injection/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  // Using Repository directly instead of a new Bloc for simplicity for now
  final ChatRepository _chatRepository = getIt<ChatRepository>();
  List<ChatSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
    });
    final sessions = await _chatRepository.getSessions();
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    await _chatRepository.deleteSession(sessionId);
    await _loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş Sohbetler'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? const Center(child: Text("Henüz geçmiş sohbet yok."))
              : ListView.builder(
                  padding: EdgeInsets.all(16.h),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return Dismissible(
                      key: Key(session.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteSession(session.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        margin: EdgeInsets.only(bottom: 8.h),
                        child: ListTile(
                          title: Text(
                            session.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            DateFormat('dd MMM yyyy, HH:mm')
                                .format(session.lastMessageTime),
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            context
                                .read<ChatBloc>()
                                .add(LoadSessionEvent(session));
                            context.router.pop();
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<ChatBloc>().add(const NewSessionEvent());
          context.router.pop();
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}
