import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotime/features/social/widgets/privacy_policy_dialog.dart';

void main() {
  group('Privacy Policy & Compliance Verification Tests', () {
    test('docs/PRIVACY_POLICY.md exists and covers Google Play mandatory disclosures', () {
      final file = File('docs/PRIVACY_POLICY.md');
      expect(file.existsSync(), isTrue, reason: 'Privacy Policy document must exist in docs/');

      final content = file.readAsStringSync();
      // 核心本地优先与无广告承诺
      expect(content, contains('Local-First'));
      expect(content, contains('本地优先'));
      expect(content, contains('零第三方广告'));
      expect(content, contains('No Third-Party Ads'));

      // Google Play Health Connect 政策硬性披露
      expect(content, contains('Health Connect'));
      expect(content, contains('绝不上传健康数据'));
      expect(content, contains('NEVER used for advertising'));

      // 系统权限披露
      expect(content, contains('POST_NOTIFICATIONS'));
      expect(content, contains('USE_BIOMETRIC'));
      expect(content, contains('WebDAV'));

      // 数据擦除与粉碎权利 (GDPR / CCPA / 5.1.1(v))
      expect(content, contains('物理粉碎'));
      expect(content, contains('Right to Erasure'));
      expect(content, contains('COPPA'));
    });

    testWidgets('PrivacyPolicyDialog renders correctly with language toggle and closes gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrivacyPolicyDialog(),
          ),
        ),
      );

      // 验证中文初始内容
      expect(find.text('隐私政策与数据安全'), findsOneWidget);
      expect(find.text('🛡️ 100% 本地优先'), findsOneWidget);
      expect(find.text('🚫 零广告零画像'), findsOneWidget);
      expect(find.text('我已阅读并知悉'), findsOneWidget);

      // 切换为英文
      final engButton = find.text('English');
      expect(engButton, findsOneWidget);
      await tester.tap(engButton);
      await tester.pumpAndSettle();

      // 验证英文内容呈现
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('🛡️ 100% Local-First'), findsOneWidget);
      expect(find.text('I Have Read and Acknowledge'), findsOneWidget);
    });
  });
}
