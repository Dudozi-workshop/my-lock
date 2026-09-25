import 'package:flutter/material.dart';

typedef StyleLabBodyBuilder = Widget Function(
  BuildContext context,
  StyleLabTheme theme,
);

class StyleLabDomain {
  const StyleLabDomain({
    required this.id,
    required this.label,
    required this.builder,
  });

  final String id;
  final String label;
  final StyleLabBodyBuilder builder;
}

class StyleLabTheme {
  const StyleLabTheme({
    required this.background,
    required this.card,
    required this.foreground,
    required this.muted,
    required this.dark,
  });

  final Color background;
  final Color card;
  final Color foreground;
  final Color muted;
  final bool dark;
}

class StyleLabShell extends StatefulWidget {
  const StyleLabShell({
    super.key,
    required this.domains,
    required this.initialStyleId,
    required this.onStyleChanged,
    this.labMarker = 'STYLE LAB',
  });

  final List<StyleLabDomain> domains;
  final String initialStyleId;
  final ValueChanged<String> onStyleChanged;
  final String labMarker;

  @override
  State<StyleLabShell> createState() => _StyleLabShellState();
}

class _StyleLabShellState extends State<StyleLabShell> {
  late String selectedStyleId;
  bool dark = false;

  @override
  void initState() {
    super.initState();
    selectedStyleId = _resolveStyleId(widget.initialStyleId);
  }

  @override
  void didUpdateWidget(covariant StyleLabShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final resolved = _resolveStyleId(widget.initialStyleId);
    if (resolved != selectedStyleId &&
        widget.initialStyleId != oldWidget.initialStyleId) {
      selectedStyleId = resolved;
    }
  }

  String _resolveStyleId(String requested) {
    if (widget.domains.any((domain) => domain.id == requested)) {
      return requested;
    }
    return widget.domains.first.id;
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.domains.isNotEmpty);
    final theme = StyleLabTheme(
      background: dark ? const Color(0xFF101218) : const Color(0xFFF6F5FA),
      card: dark ? const Color(0xFF1A1D26) : Colors.white,
      foreground: dark ? Colors.white : const Color(0xFF171923),
      muted: dark ? const Color(0xFFAEB4C3) : const Color(0xFF6D7382),
      dark: dark,
    );
    final selected = widget.domains.firstWhere(
      (domain) => domain.id == selectedStyleId,
    );

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: theme.background,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MY LOCK · Style Lab',
                                  style: TextStyle(
                                    color: theme.foreground,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.labMarker,
                                  style: TextStyle(
                                    color: theme.muted,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: dark,
                            onChanged: (value) => setState(() => dark = value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStyleId,
                        decoration: const InputDecoration(
                          labelText: 'Style',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          for (final domain in widget.domains)
                            DropdownMenuItem(
                              value: domain.id,
                              child: Text(domain.label),
                            ),
                        ],
                        onChanged: (next) {
                          if (next == null || next == selectedStyleId) return;
                          setState(() => selectedStyleId = next);
                          widget.onStyleChanged(next);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
              color: dark ? Colors.white12 : const Color(0xFFE8E5EF),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: selected.builder(context, theme),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
