import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../core/widgets/expressive_motion.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';
import '../../providers/fitness_provider.dart';

/// ICMR-guided AI health assistant powered by Gemini. Supports
/// multi-turn conversation with context awareness of the user's logged
/// vitals, AQI, and recent health records.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late AnimationController _typingCtrl;
  bool _inputEmpty = true;

  @override
  void initState() {
    super.initState();
    _typingCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadHistory();
    });

    _inputCtrl.addListener(() {
      final empty = _inputCtrl.text.trim().isEmpty;
      if (empty != _inputEmpty) setState(() => _inputEmpty = empty);
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _typingCtrl.dispose();
    super.dispose();
  }

  Future<void> _send([String? text]) async {
    final msg = (text ?? _inputCtrl.text).trim();
    if (msg.isEmpty) return;
    _inputCtrl.clear();
    setState(() => _inputEmpty = true);
    
    final auth = context.read<AuthProvider>();
    final health = context.read<HealthProvider>();
    final fitness = context.read<FitnessProvider>();
    
    final conditionsSet = <String>{};
    if (auth.user?['conditions'] is List) {
      for (final c in auth.user!['conditions']) {
        if (c != null && c.toString().isNotEmpty) {
          conditionsSet.add(c.toString());
        }
      }
    }
    for (var r in health.records) {
      if (r['record_type'] == 'condition') {
        final c = r['data']?['condition_name'];
        if (c != null && c.toString().isNotEmpty) {
          conditionsSet.add(c.toString());
        }
      }
    }

    final medicationsSet = <String>{};
    if (auth.user?['medications'] is List) {
      for (final m in auth.user!['medications']) {
        if (m != null && m.toString().isNotEmpty) {
          medicationsSet.add(m.toString());
        }
      }
    }
    for (var r in health.records) {
      if (r['record_type'] == 'medication') {
        final m = r['data']?['medication_name'];
        if (m != null && m.toString().isNotEmpty) {
          medicationsSet.add(m.toString());
        }
      }
    }

    final Map<String, dynamic> profile = {
      if (auth.user?['age'] != null) 'age': auth.user!['age'],
      if (auth.user?['gender'] != null) 'gender': auth.user!['gender'],
      if (auth.user?['height_cm'] != null) 'height_cm': auth.user!['height_cm'],
      if (auth.user?['weight_kg'] != null) 'weight_kg': auth.user!['weight_kg'],
      'conditions': conditionsSet.toList(),
      'medications': medicationsSet.toList(),
    };

    final Map<String, dynamic> wearable = {
      if (fitness.steps > 0) 'today_steps': fitness.steps,
      if (fitness.heartRate != null) 'heart_rate_bpm': fitness.heartRate,
      if (fitness.spo2 != null) 'spo2_percent': fitness.spo2,
      if (fitness.sleepHours > 0) 'sleep_total_hours': fitness.sleepHours,
      'calories_burned': fitness.calories(),
    };

    await context.read<ChatProvider>().sendMessage(
      msg,
      language: auth.language,
      profile: profile,
      wearable: wearable,
    );
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: AppTheme.durationMedium,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = AppTheme.textPrimaryOf(context);
    final textSec = AppTheme.textSecondaryOf(context);
    final card = AppTheme.cardBg(context);
    final card2 = AppTheme.cardBg2(context);
    final bg = AppTheme.bgOf(context);

    final rawName = auth.user?['first_name'] as String? ?? 'Friend';
    final firstName = rawName.isNotEmpty
        ? '${rawName[0].toUpperCase()}${rawName.substring(1)}'
        : 'Friend';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(children: [
          // AI avatar
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Icon(Icons.psychology_outlined,
                color: Theme.of(context).colorScheme.onPrimaryContainer, size: 20),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Health Assistant',
                style: GoogleFonts.outfit(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: textPri)),
            Row(children: [
              Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentGreen,
                ),
              ),
              const SizedBox(width: 4),
              Text('ICMR-Guided · Online',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppTheme.accentGreen,
                      fontWeight: FontWeight.w500)),
            ]),
          ]),
          const Spacer(),
          // Language selector chip
          GestureDetector(
            onTap: () => _showChatLangSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.translate_rounded,
                      size: 13, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    auth.language.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (chat.messages.isNotEmpty) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  size: 20, color: textSec),
              onPressed: () => _confirmClear(context, chat),
              tooltip: 'Clear chat',
            ),
          ],
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: chat.messages.isEmpty
              ? _EmptyState(
                  userName: firstName,
                  onSuggestion: _send,
                )
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: chat.messages.length +
                      (chat.isTyping ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (chat.isTyping && i == chat.messages.length) {
                      return _TypingIndicator(
                          ctrl: _typingCtrl, isDark: isDark);
                    }
                    return _MessageBubble(
                      message: chat.messages[i],
                      isDark: isDark,
                      textPri: textPri,
                      textSec: textSec,
                      card: card,
                      card2: card2,
                    );
                  },
                ),
        ),

        // ── Input ──
        _InputBar(
          ctrl: _inputCtrl,
          inputEmpty: _inputEmpty,
          onSend: _send,
          onVoice: () => _showVoiceSheet(context),
        ),
      ]),
    );
  }

  void _confirmClear(BuildContext ctx, ChatProvider chat) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Clear Chat?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: const Text('All messages will be deleted locally.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              chat.clearMessages();
            },
            child: const Text('Clear',
                style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  void _showChatLangSheet(BuildContext ctx) {
    final auth = ctx.read<AuthProvider>();
    var currentLang = auth.language;

    final langOptions = [
      {'code': 'en', 'label': 'English'},
      {'code': 'hi', 'label': 'हिंदी (Hindi)'},
      {'code': 'mr', 'label': 'मराठी (Marathi)'},
    ];

    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chat Language',
                  style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryOf(c))),
              const SizedBox(height: 6),
              Text('Aarogya Sathi will respond in this language',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppTheme.textSecondaryOf(c))),
              const SizedBox(height: 16),
              ...langOptions.map((opt) {
                final isSelected = (opt['code'] == currentLang);
                return ListTile(
                  title: Text(opt['label']!,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimaryOf(c),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondaryOf(c),
                  ),
                  onTap: () async {
                    final newLang = opt['code']!;
                    setSheetState(() => currentLang = newLang);
                    await auth.setLanguage(newLang);
                    if (c.mounted) Navigator.pop(c);
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text('Chat language set to ${opt['label']}'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: AppTheme.primaryTeal,
                        ),
                      );
                    }
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showVoiceSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (c) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 60, height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.chatGradient,
              ),
              child: const Icon(Icons.mic_rounded,
                  color: Colors.white, size: 28)),
          const SizedBox(height: 16),
          Text('Voice Input',
              style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryOf(c))),
          const SizedBox(height: 8),
          Text('Voice input coming soon. Use text for now.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textSecondaryOf(c))),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Got it'),
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════════════════════════

class _StarterPrompt {
  final IconData icon;
  final String title;
  final String query;

  const _StarterPrompt({
    required this.icon,
    required this.title,
    required this.query,
  });
}

class _EmptyState extends StatelessWidget {
  final String userName;
  final Function(String) onSuggestion;

  const _EmptyState({
    required this.userName,
    required this.onSuggestion,
  });

  static const _starterPrompts = [
    _StarterPrompt(
      icon: Icons.thermostat_rounded,
      title: 'Fever & headache',
      query: 'I have a fever and headache',
    ),
    _StarterPrompt(
      icon: Icons.water_drop_rounded,
      title: 'Daily hydration',
      query: 'How much water should I drink daily?',
    ),
    _StarterPrompt(
      icon: Icons.restaurant_rounded,
      title: 'Diabetes diet',
      query: 'Best diet for diabetes management',
    ),
    _StarterPrompt(
      icon: Icons.air_rounded,
      title: 'High AQI care',
      query: 'AQI is high, what precautions should I take?',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Gemini Expressive Greeting Header with ShaderMask Gradient
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: isDark
                  ? const [Color(0xFF66F7E2), Color(0xFFA8C8FF)]
                  : const [Color(0xFF006A60), Color(0xFF3F5F90)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'Hello, $userName',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'How can I help with your health today?',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          // Trust Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'ICMR-Guided • Private On-Device',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 2x2 Bento Starter Cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _starterPrompts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, index) {
              final prompt = _starterPrompts[index];
              return SpringPressable(
                onTap: () => onSuggestion(prompt.query),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.surfaceContainerHigh,
                        ),
                        child: Center(
                          child: Icon(
                            prompt.icon,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      Text(
                        prompt.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

// ═══════════════════════════════════════════════════════════════════════════
// MESSAGE BUBBLE
// ═══════════════════════════════════════════════════════════════════════════

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;
  final Color? textPri, textSec, card, card2;
  const _MessageBubble({
    required this.message,
    required this.isDark,
    this.textPri,
    this.textSec,
    this.card,
    this.card2,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final time = _fmtTime(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // User bubble
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(width: 48),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  message.userMessage,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: colorScheme.onPrimaryContainer,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // AI bubble
        if (message.aiResponse.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // AI avatar
              Container(
                width: 28, height: 28, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: message.isEmergency
                      ? AppTheme.accentRed.withValues(alpha: 0.15)
                      : colorScheme.primaryContainer,
                ),
                child: Icon(
                  message.isEmergency
                      ? Icons.warning_rounded
                      : Icons.psychology_outlined,
                  color: message.isEmergency
                      ? AppTheme.accentRed
                      : colorScheme.onPrimaryContainer,
                  size: 16,
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: message.isEmergency
                            ? AppTheme.accentRed.withValues(alpha: 0.12)
                            : colorScheme.surfaceContainerLow,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                        border: message.isEmergency
                            ? Border.all(
                                color: AppTheme.accentRed.withValues(alpha: 0.4))
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.isEmergency)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(children: [
                                const Icon(Icons.warning_rounded,
                                    size: 14, color: AppTheme.accentRed),
                                const SizedBox(width: 4),
                                Text('URGENT — Call 108',
                                    style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.accentRed)),
                              ]),
                            ),
                          Text(
                            message.aiResponse,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '· ICMR Guided',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
      ]),
    );
  }

  String _fmtTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TYPING INDICATOR
// ═══════════════════════════════════════════════════════════════════════════

class _TypingIndicator extends StatelessWidget {
  final AnimationController ctrl;
  final bool isDark;
  const _TypingIndicator({
    required this.ctrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 28, height: 28, margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primaryContainer,
          ),
          child: Icon(Icons.psychology_outlined,
              color: colorScheme.onPrimaryContainer, size: 16),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: AnimatedBuilder(
            animation: ctrl,
            builder: (context, child) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final t = ((ctrl.value - i * 0.15) % 1.0).clamp(0.0, 1.0);
                final bounce = t < 0.5 ? t * 2 : (1 - t) * 2;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.translate(
                    offset: Offset(0, -5 * bounce),
                    child: Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary
                            .withValues(alpha: 0.5 + 0.5 * bounce),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INPUT BAR
// ═══════════════════════════════════════════════════════════════════════════

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool inputEmpty;
  final Function([String?]) onSend;
  final VoidCallback onVoice;

  const _InputBar({
    required this.ctrl,
    required this.inputEmpty,
    required this.onSend,
    required this.onVoice,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 6, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Single unified floating pill container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                // Text input on the left
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    maxLines: 4,
                    minLines: 1,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask about symptoms, diet, vitals...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
                // Microphone icon button on the right
                IconButton(
                  onPressed: onVoice,
                  icon: Icon(
                    Icons.mic_outlined,
                    size: 22,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  splashRadius: 20,
                  tooltip: 'Voice Input',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                const SizedBox(width: 4),
                // Send button inside pill on far right: 36x36 circular button
                GestureDetector(
                  onTap: inputEmpty ? null : () => onSend(),
                  child: AnimatedContainer(
                    duration: AppTheme.durationFast,
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: inputEmpty
                          ? colorScheme.surfaceContainerLow
                          : colorScheme.primary,
                    ),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      size: 20,
                      color: inputEmpty
                          ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                          : colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Subtle disclaimer at bottom
          Text(
            'AI responses are for informational purposes only · ICMR Guidelines',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

