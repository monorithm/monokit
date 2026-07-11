import 'package:flutter/widgets.dart';
// import 'package:monokit/monokit.dart'; // ONLY if a field TYPE needs it

/// Demo state for the messaging section.
class MessagingState extends ChangeNotifier {
  final List<ThreadMessage> _thread = <ThreadMessage>[
    const ThreadMessage(
      id: 'welcome',
      author: 'Monokit',
      text:
          'Welcome! This scroller follows new messages while you are at the latest end.',
      isOwn: false,
      time: '10:24',
    ),
    const ThreadMessage(
      id: 'reply',
      author: 'You',
      text: 'Show me a composable message.',
      isOwn: true,
      time: '10:25',
    ),
    const ThreadMessage(
      id: 'answer',
      author: 'Monokit',
      text:
          'Messages accept headers, footers, bubbles, reactions, and attachments without forcing a data model.',
      isOwn: false,
      time: '10:25',
    ),
  ];

  int _nextMessage = 1;
  bool _liked = false;
  bool _celebrated = false;

  List<ThreadMessage> get thread => _thread;
  bool get liked => _liked;
  bool get celebrated => _celebrated;

  void appendMessage() {
    final index = _nextMessage++;
    final isOwn = index.isOdd;
    _thread.add(
      ThreadMessage(
        id: 'generated-$index',
        author: isOwn ? 'You' : 'Monokit',
        text: isOwn
            ? 'A new message was appended to the bounded thread.'
            : 'MonoMessageScroller noticed the append and stayed pinned to the end.',
        isOwn: isOwn,
        time: '10:${25 + index}',
      ),
    );
    notifyListeners();
  }

  void setLiked(bool value) {
    _liked = value;
    notifyListeners();
  }

  void setCelebrated(bool value) {
    _celebrated = value;
    notifyListeners();
  }

  @override
  void dispose() {
    // No controllers to dispose for this section.
    super.dispose();
  }
}

class ThreadMessage {
  const ThreadMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.isOwn,
    required this.time,
  });

  final String id;
  final String author;
  final String text;
  final bool isOwn;
  final String time;
}

class MessagingScope extends InheritedNotifier<MessagingState> {
  const MessagingScope({
    super.key,
    required MessagingState state,
    required super.child,
  }) : super(notifier: state);
  static MessagingState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MessagingScope>();
    assert(scope != null, 'No MessagingScope found in context.');
    return scope!.notifier!;
  }
}
