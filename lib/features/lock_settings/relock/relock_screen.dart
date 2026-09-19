import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../lock_engine/relock_policy.dart';

class RelockScreen extends StatefulWidget {
  const RelockScreen({super.key, required this.selectedPolicy, required this.onChanged});
  final RelockPolicy selectedPolicy;
  final ValueChanged<RelockPolicy> onChanged;
  @override
  State<RelockScreen> createState() => _RelockScreenState();
}

class _RelockScreenState extends State<RelockScreen> {
  late RelockPolicy _selectedPolicy;
  @override
  void initState() { super.initState(); _selectedPolicy = widget.selectedPolicy; }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text('다시 잠그기', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text('잠금 해제 후 앱을 벗어났을 때 언제 다시 잠글지 설정합니다.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 18),
            for (final policy in RelockPolicy.values) ...[
              _PolicyTile(policy: policy, selected: _selectedPolicy == policy, onTap: () => _select(policy)),
              const SizedBox(height: 9),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF0EDFF), borderRadius: BorderRadius.circular(18)),
              child: const Text(
                '화면 꺼짐 기준은 실제 기기에서 Android/iOS의 화면 상태 이벤트와 연결되어 동작합니다.',
                style: TextStyle(color: Color(0xFF665C8F), fontSize: 12, height: 1.45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _select(RelockPolicy policy) {
    if (_selectedPolicy == policy) return;
    setState(() => _selectedPolicy = policy);
    widget.onChanged(policy);
  }
}

class _PolicyTile extends StatelessWidget {
  const _PolicyTile({required this.policy, required this.selected, required this.onTap});
  final RelockPolicy policy;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? brandLavender : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? brandPurple : const Color(0xFFE8E5ED), width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? brandPurple : Colors.transparent,
                  border: Border.all(color: selected ? brandPurple : const Color(0xFFC9C6D0), width: 1.5),
                ),
                child: selected ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(policy.label, style: TextStyle(color: selected ? brandPurple : ink, fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(_description(policy), style: const TextStyle(color: secondaryInk, fontSize: 12, height: 1.35)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _description(RelockPolicy policy) {
    switch (policy) {
      case RelockPolicy.immediate: return '보호 앱을 벗어나는 즉시 다시 잠급니다.';
      case RelockPolicy.after30Seconds: return '30초 안에 다시 열면 잠금 화면을 건너뜁니다.';
      case RelockPolicy.after1Minute: return '1분 안에 다시 열면 잠금 화면을 건너뜁니다.';
      case RelockPolicy.screenOff: return '화면을 끄기 전까지 잠금 해제 상태를 유지합니다.';
    }
  }
}
