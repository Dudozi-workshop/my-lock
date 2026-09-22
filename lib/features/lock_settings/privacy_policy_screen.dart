import 'package:flutter/material.dart';

import '../../app/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          '개인정보처리방침',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: const [
          Text(
            '시행일: 2026년 9월 22일',
            style: TextStyle(color: secondaryInk, fontSize: 12),
          ),
          SizedBox(height: 18),
          _PolicyTitle('1. 수집·저장하는 정보'),
          _PolicyText(
            'MyLock은 회원가입, 로그인, 광고, 분석 SDK 또는 클라우드 동기화를 제공하지 않습니다. 잠금 기능을 위해 보호 앱 식별자, 잠금 설정, 잠금 패턴 검증값, 보조 PIN 검증값, 재부팅 복구 상태값이 기기에만 저장될 수 있습니다.',
          ),
          _PolicyTitle('2. 기기 권한 및 사용 목적'),
          _PolicyText(
            '앱 사용 정보 접근은 보호 앱이 현재 화면에 열렸는지 기기 안에서 확인하기 위해 사용합니다. 다른 앱 위에 표시는 보호 앱 위에 MyLock 잠금 화면을 표시하기 위해 사용합니다. 알림과 포그라운드 서비스는 보호 기능을 유지하기 위해 사용하며, 부팅 완료 권한은 재부팅 후 보호 기능을 복구하기 위해 사용합니다.',
          ),
          _PolicyTitle('3. 외부 전송 및 공유'),
          _PolicyText(
            '위 정보는 외부 서버로 전송하거나 제3자와 공유하지 않습니다. 다른 앱의 화면 내용, 메시지, 입력 내용도 읽거나 저장하지 않습니다. 정보를 판매하거나 광고·분석 목적으로 사용하지 않습니다.',
          ),
          _PolicyTitle('4. 보관 및 삭제'),
          _PolicyText(
            '정보는 Android 앱 내부 저장공간에 보관됩니다. 앱 설정 초기화 또는 Android 설정의 앱 데이터 삭제로 저장된 정보를 삭제할 수 있으며, 앱을 삭제하면 앱 내부 정보도 함께 삭제됩니다. 별도 계정을 제공하지 않으므로 계정 삭제 절차는 필요하지 않습니다.',
          ),
          _PolicyTitle('5. 보호 및 문의'),
          _PolicyText(
            '저장 정보는 Android 앱 샌드박스와 운영체제 접근 제어로 보호됩니다. 문의는 MyLock 공식 저장소의 공개 문의 창구를 이용해 주세요.',
          ),
          SizedBox(height: 8),
          SelectableText(
            'https://github.com/Dudozi-workshop/my-lock/issues',
            style: TextStyle(color: brandPurple, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PolicyTitle extends StatelessWidget {
  const _PolicyTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 22, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: ink,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PolicyText extends StatelessWidget {
  const _PolicyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: secondaryInk,
        fontSize: 13,
        height: 1.55,
      ),
    );
  }
}
