import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FadingTextAnimation(),
    );
  }
}

class FadingTextAnimation extends StatefulWidget {
  const FadingTextAnimation({super.key});

  @override
  State<FadingTextAnimation> createState() => _FadingTextAnimationState();
}

class _FadingTextAnimationState extends State<FadingTextAnimation> {
  bool _isVisible = true;
  bool _isDark = false;
  Color _textColor = Colors.black; // never null
  bool _showFrame = false;         // screen 2 frame toggle

  void _toggleVisibility() => setState(() => _isVisible = !_isVisible);

  Future<void> _pickColorDialog() async {
    final swatches = <Color>[
      Colors.black, Colors.white, Colors.red, Colors.blue, Colors.green,
      Colors.purple, Colors.orange, Colors.teal, Colors.pink, Colors.brown,
    ];
    final selected = await showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pick text color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in swatches)
              InkWell(
                onTap: () => Navigator.pop(ctx, c),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                    color: c,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (selected != null) setState(() => _textColor = selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = _isDark ? ThemeData.dark() : ThemeData.light();
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fading Text Animation'),
          actions: [
            IconButton(
              tooltip: 'Pick text color',
              icon: const Icon(Icons.palette),
              onPressed: _pickColorDialog,
            ),
            IconButton(
              tooltip: _isDark ? 'Switch to Day Mode' : 'Switch to Night Mode',
              icon: Icon(_isDark ? Icons.dark_mode : Icons.light_mode),
              onPressed: () => setState(() => _isDark = !_isDark),
            ),
          ],
        ),
        body: PageView(
          children: <Widget>[
            // SCREEN 1 — 1.0s fade; the button-like container + text fade together
            _FadePanel(
              label: 'Screen 1: 1.0s',
              isVisible: _isVisible,
              duration: const Duration(seconds: 1),
              textColor: _textColor,
              onTap: _toggleVisibility,
              showImageControls: false,
              showFrame: _showFrame,
              onToggleFrame: (v) => setState(() => _showFrame = v),
              buttonLikeText: true,
              fadeTextAndImageTogether: false, // only the text/button fades here
            ),

            // SCREEN 2 — 2.5s fade; text + switch + image fade together
            _FadePanel(
              label: 'Screen 2: 2.5s',
              isVisible: _isVisible,
              duration: const Duration(milliseconds: 2500),
              textColor: _textColor,
              onTap: _toggleVisibility,
              showImageControls: true,
              showFrame: _showFrame,
              onToggleFrame: (v) => setState(() => _showFrame = v),
              buttonLikeText: false,
              fadeTextAndImageTogether: true, // whole section fades
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleVisibility,
          tooltip: 'Fade',
          child: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}

class _FadePanel extends StatelessWidget {
  const _FadePanel({
    required this.label,
    required this.isVisible,
    required this.duration,
    required this.textColor,
    required this.onTap,
    required this.showImageControls,
    required this.showFrame,
    required this.onToggleFrame,
    required this.buttonLikeText,
    required this.fadeTextAndImageTogether,
  });

  final String label;
  final bool isVisible;
  final Duration duration;
  final Color textColor;
  final VoidCallback onTap;

  final bool showImageControls;
  final bool showFrame;
  final ValueChanged<bool> onToggleFrame;

  final bool buttonLikeText;           // screen 1
  final bool fadeTextAndImageTogether; // screen 2

  @override
  Widget build(BuildContext context) {
    // Build the primary text widget (button-like or plain)
    Widget textWidget = buttonLikeText
        ? _ButtonLikeText(textColor: textColor)
        : Text('Hello, Flutter!', style: TextStyle(fontSize: 24, color: textColor));

    // If we are NOT fading the whole section, wrap ONLY the text widget so it fades
    if (!fadeTextAndImageTogether) {
      textWidget = AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: duration,
        curve: Curves.easeInOut,
        child: textWidget,
      );
    }

    // Make the text tappable to toggle fade
    textWidget = GestureDetector(onTap: onTap, child: textWidget);

    final columnChildren = <Widget>[
      textWidget,
      const SizedBox(height: 12),
      Text(label),
      if (showImageControls) ...[
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Show Frame'),
          value: showFrame,
          onChanged: onToggleFrame,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: showFrame ? Border.all(width: 3) : null,
            ),
            child: Image.network(
              'https://picsum.photos/seed/flutter/300/180',
              width: 300,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    ];

    // If we ARE fading the whole section (screen 2), wrap the entire column
    Widget content = fadeTextAndImageTogether
        ? AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            duration: duration,
            curve: Curves.easeInOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: columnChildren,
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: columnChildren,
          );

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: content,
      ),
    );
  }
}

class _ButtonLikeText extends StatelessWidget {
  const _ButtonLikeText({required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surfaceVariant;
    final border = Theme.of(context).dividerColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Text('Hello, Flutter!', style: TextStyle(fontSize: 24, color: textColor)),
    );
  }
}
