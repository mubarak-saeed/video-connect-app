// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_constants.dart';
import '../call/agora_call_controller.dart';
import '../call/call_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AgoraCallController _controller = AgoraCallController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _channelController;

  @override
  void initState() {
    super.initState();
    _channelController = TextEditingController(
      text: AppConstants.defaultChannelName,
    );
  }

  @override
  void dispose() {
    _channelController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startCall({required bool asHost}) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      await _controller.joinChannel(
        channelName: _channelController.text,
        asHost: asHost,
      );
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CallScreen(controller: _controller, isHost: asHost),
        ),
      );
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validConfiguration = AppConstants.hasValidAgoraConfig;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF07131F), Color(0xFF0B1E31), Color(0xFF031018)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -80,
                left: -60,
                child: _AccentOrb(
                  color: const Color(0xFF31D0AA).withOpacity(0.15),
                  size: 220,
                ),
              ),
              Positioned(
                bottom: -100,
                right: -80,
                child: _AccentOrb(
                  color: const Color(0xFF6EE7FF).withOpacity(0.10),
                  size: 260,
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeroCard(isReady: validConfiguration),
                        const SizedBox(height: 20),
                        const _QuickTipsCard(),
                        const SizedBox(height: 20),
                        if (!validConfiguration) ...[
                          _WarningCard(
                            title: 'App ID not configured',
                            message:
                                'Set your Agora App ID in lib/core/app_constants.dart before testing live calls.',
                          ),
                          const SizedBox(height: 20),
                        ],
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SectionHeader(
                                title: 'ابدأ مكالمة جديدة',
                                subtitle:
                                    'اكتب اسم القناة ثم اختر هل تريد البدء كمضيف أو الانضمام كمشارك.',
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _channelController,
                                onChanged: (_) => setState(() {}),
                                textInputAction: TextInputAction.done,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9_-]'),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  labelText: 'اسم القناة',
                                  hintText: 'أدخل اسم الغرفة',
                                  prefixIcon: Icon(Icons.meeting_room_outlined),
                                  suffixIcon: IconButton(
                                    onPressed: _channelController.text.isEmpty
                                        ? null
                                        : () {
                                            setState(() {
                                              _channelController.clear();
                                            });
                                          },
                                    icon: const Icon(Icons.clear_rounded),
                                    tooltip: 'مسح',
                                  ),
                                ),
                                validator: (value) {
                                  final trimmed = value?.trim() ?? '';
                                  if (trimmed.isEmpty) {
                                    return 'اسم القناة مطلوب';
                                  }
                                  if (trimmed.length < 3) {
                                    return 'استخدم ٣ أحرف على الأقل';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              AnimatedBuilder(
                                animation: _controller,
                                builder: (context, _) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: FilledButton(
                                              onPressed:
                                                  !_controller.isBusy &&
                                                      validConfiguration
                                                  ? () =>
                                                        _startCall(asHost: true)
                                                  : null,
                                              style: FilledButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                backgroundColor: const Color(
                                                  0xFF31D0AA,
                                                ),
                                                foregroundColor: Colors.black,
                                              ),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add_circle_outline,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text('ابدأ'),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed:
                                                  !_controller.isBusy &&
                                                      validConfiguration
                                                  ? () => _startCall(
                                                      asHost: false,
                                                    )
                                                  : null,
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.login_rounded),
                                                  SizedBox(width: 8),
                                                  Text('انضم'),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_controller.isBusy) ...[
                                        const SizedBox(height: 16),
                                        const LinearProgressIndicator(
                                          minHeight: 2,
                                        ),
                                      ],
                                      if (_controller.statusMessage !=
                                          null) ...[
                                        const SizedBox(height: 16),
                                        _StatusChip(
                                          text: _controller.statusMessage!,
                                        ),
                                      ],
                                      if (_controller.errorMessage != null) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          _controller.errorMessage!,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .errorContainer,
                                              ),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.isReady});

  final bool isReady;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.14),
            Colors.white.withOpacity(0.03),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusPill(
                text: isReady ? 'جاهز للاستخدام' : 'يحتاج إعداد',
                color: isReady
                    ? const Color(0xFF31D0AA)
                    : const Color(0xFFFFC857),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isReady
                    ? [const Color(0xFF31D0AA), const Color(0xFF7EF9FF)]
                    : [const Color(0xFFFFC857), const Color(0xFFFF7A59)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.video_call_rounded,
              color: Colors.black,
              size: 32,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            AppConstants.appName,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.appTagline,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.85),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTipsCard extends StatelessWidget {
  const _QuickTipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child:Center()
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.72),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.74),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withOpacity(0.14),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC857).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFC857).withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFFFC857)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Align(
      alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white.withOpacity(0.08),
        ),
        child: Text(text),
      ),
    );
  }
}

class _AccentOrb extends StatelessWidget {
  const _AccentOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
