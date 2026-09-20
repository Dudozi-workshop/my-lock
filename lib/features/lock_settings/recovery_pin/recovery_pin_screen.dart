import 'package:flutter/material.dart';

import '../../../app/theme.dart';

class RecoveryPinScreen extends StatefulWidget {
  const RecoveryPinScreen({super.key});

  @override
  State<RecoveryPinScreen> createState() => _RecoveryPinScreenState();
}

class _RecoveryPinScreenState extends State<RecoveryPinScreen> {
  String _first = '';
  String _input = '';
  bool _confirming = false;
  bool _mismatch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          '보조 PIN',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            children: [
              Text(
                _confirming ? '같은 PIN을 다시 입력하세요.' : '4자리 PIN을 설정하세요.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                _mismatch
                    ? 'PIN이 일치하지 않습니다. 다시 입력하세요.'
                    : '그래픽 비밀번호 대신 MY LOCK을 열 때 사용할 수 있습니다.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _mismatch
                          ? const Color(0xFFD94262)
                          : secondaryInk,
                    ),
              ),
              const SizedBox(height: 28),
              _PinDots(length: _input.length),
              const Spacer(),
              _NumberPad(
                onDigit: _addDigit,
                onBackspace: _removeLast,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addDigit(int digit) {
    if (_input.length >= 4) return;
    setState(() {
      _mismatch = false;
      _input += digit.toString();
    });

    if (_input.length == 4) {
      Future<void>.delayed(const Duration(milliseconds: 140), _submit);
    }
  }

  void _removeLast() {
    if (_input.isEmpty) return;
    setState(() {
      _mismatch = false;
      _input = _input.substring(0, _input.length - 1);
    });
  }

  void _submit() {
    if (_input.length != 4) return;

    if (!_confirming) {
      setState(() {
        _first = _input;
        _input = '';
        _confirming = true;
      });
      return;
    }

    if (_input != _first) {
      setState(() {
        _input = '';
        _mismatch = true;
      });
      return;
    }

    Navigator.of(context).pop<String>(_input);
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({required this.length});

  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(width: 18),
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < length ? brandPurple : Colors.transparent,
              border: Border.all(
                color: i < length
                    ? brandPurple
                    : const Color(0xFFCBC7D3),
                width: 1.8,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({
    required this.onDigit,
    required this.onBackspace,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const rows = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
    ];

    return Column(
      children: [
        for (final row in rows) ...[
          Row(
            children: [
              for (var i = 0; i < row.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: _NumberButton(
                    label: row[i].toString(),
                    onTap: () => onDigit(row[i]),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            const Expanded(child: SizedBox(height: 64)),
            const SizedBox(width: 12),
            Expanded(
              child: _NumberButton(
                label: '0',
                onTap: () => onDigit(0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 64,
                child: IconButton(
                  onPressed: onBackspace,
                  icon: const Icon(Icons.backspace_outlined),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NumberButton extends StatelessWidget {
  const _NumberButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8E5ED)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: ink,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
