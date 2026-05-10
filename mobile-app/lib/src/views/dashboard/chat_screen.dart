import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../models/response/session_summary.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  final List<SessionSummary> _sessions = [];
  bool _loading = true;
  bool _sending = false;
  bool _loadingHistory = false;
  String _currentSubject = 'general';
  int? _sessionId;
  String _sessionName = 'New Chat';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      final profile = await AuthController.instance.loadCurrentUser();
      final sessions = await ChatController.instance.getSessions();
      if (!mounted) return;
      setState(() {
        _currentSubject = profile.currentSubject;
        _sessions
          ..clear()
          ..addAll(sessions);
        _loading = false;
      });
      if (_currentSubject != 'general') {
        await _selectSession(sessions.isNotEmpty ? sessions.first.id : null);
      } else {
        _messages.add(const _ChatMessage(
          isUser: false,
          text: 'Select a subject to start your study session.',
        ));
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _messages
          ..clear()
          ..add(_ChatMessage(
            isUser: false,
            text: 'Chat is ready once your session loads. ${error.toString()}',
          ));
      });
    }
  }

  Future<void> _refreshSessions() async {
    final sessions = await ChatController.instance.getSessions();
    if (!mounted) return;
    setState(() {
      _sessions
        ..clear()
        ..addAll(sessions);
    });
  }

  Future<void> _selectSession(int? sessionId) async {
    if (sessionId == null) {
      setState(() {
        _sessionId = null;
        _sessionName = 'New Chat';
        _messages
          ..clear()
          ..add(const _ChatMessage(
            isUser: false,
            text: 'New chat started. Ask anything about coding, quizzes, or debugging.',
          ));
      });
      return;
    }

    setState(() {
      _loadingHistory = true;
      _sessionId = sessionId;
    });

    try {
      final session = await ChatController.instance.getSession(sessionId);
      final history = await ChatController.instance.getMessages(sessionId);
      if (!mounted) return;

      setState(() {
        _sessionName = session['name']?.toString() ?? 'Chat Session';
        _currentSubject = session['subject']?.toString() ?? _currentSubject;
        _messages
          ..clear()
          ..addAll(
            history.reversed.map(
              (item) => _ChatMessage(
                isUser: item['role']?.toString() == 'user',
                text: item['content']?.toString() ?? '',
              ),
            ),
          );
        if (_messages.isEmpty) {
          _messages.add(const _ChatMessage(
            isUser: false,
            text: 'This session is empty. Start the conversation below.',
          ));
        }
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session load failed: ${error.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingHistory = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final prompt = _messageController.text.trim();
    if (prompt.isEmpty || _sending) return;

    if (_currentSubject == 'general') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First select a subject to continue.')),
      );
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: prompt));
      _sending = true;
      _messageController.clear();
    });

    try {
      final result = await ChatController.instance.sendMessage(
        prompt: prompt,
        sessionId: _sessionId,
        subject: _currentSubject,
      );

      if (!mounted) return;
      setState(() {
        _sessionId = result.sessionId ?? _sessionId;
        _sessionName = result.sessionName ?? _sessionName;
        _messages.add(_ChatMessage(isUser: false, text: result.response));
      });

      await _refreshSessions();
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chat failed: ${error.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _startNewChat() async {
    await _selectSession(null);
  }

  Future<void> _chooseSubject(String subject) async {
    try {
      await AuthController.instance.selectSubject(subject);
      final profile = await AuthController.instance.loadCurrentUser();
      if (!mounted) return;
      setState(() {
        _currentSubject = profile.currentSubject;
      });
      await _startNewChat();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subject update failed: ${error.toString()}')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _sessionName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _startNewChat,
                    icon: const Icon(Icons.add),
                    label: const Text('New Chat'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Current subject: ${_currentSubject.toUpperCase()}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _SubjectChip(label: 'Coding', selected: _currentSubject == 'coding', onTap: () => _chooseSubject('coding')),
                    const SizedBox(width: 8),
                    _SubjectChip(label: 'Math', selected: _currentSubject == 'math', onTap: () => _chooseSubject('math')),
                    const SizedBox(width: 8),
                    _SubjectChip(label: 'Physics', selected: _currentSubject == 'physics', onTap: () => _chooseSubject('physics')),
                    const SizedBox(width: 8),
                    _SubjectChip(label: 'IELTS', selected: _currentSubject == 'ielts', onTap: () => _chooseSubject('ielts')),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return ChoiceChip(
                      label: Text(session.name),
                      selected: session.id == _sessionId,
                      onSelected: (_) => _selectSession(session.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loadingHistory
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _MessageBubble(
                      isUser: message.isUser,
                      text: message.text,
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(top: BorderSide(color: theme.dividerColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 4,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: _currentSubject == 'general'
                        ? 'Select a subject first...'
                        : 'Ask anything...',
                    prefixIcon: const Icon(Icons.chat_outlined),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _sending ? null : _sendMessage,
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatMessage {
  const _ChatMessage({required this.isUser, required this.text});

  final bool isUser;
  final String text;
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.isUser, required this.text});

  final bool isUser;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bubbleColor = isUser ? theme.colorScheme.primary : theme.colorScheme.surface;
    final textColor = isUser ? Colors.white : theme.colorScheme.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(14),
          border: isUser ? null : Border.all(color: theme.dividerColor),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(color: textColor, height: 1.45),
        ),
      ),
    );
  }
}
