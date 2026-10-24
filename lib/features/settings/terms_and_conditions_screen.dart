import 'package:flutter/material.dart';

/// In-app Terms and Conditions screen (offline kaam karti hai, koi link nahi chahiye).
class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  // TODO: apna asli email likho (Privacy Policy screen wala hi rakha hai)
  static const String _contactEmail = 'hammadnaseer2002@gmail.com';
  static const String _lastUpdated = 'October 24, 2026';

  static const List<_Section> _sections = [
    _Section('1. Acceptance of these terms', [
      'By downloading, installing or using Subscription Manager ("the '
          'App"), you agree to these Terms and Conditions. If you do not '
          'agree, please do not use the App. Our Privacy Policy explains '
          'how your data is handled and forms part of these terms.',
    ]),
    _Section('2. What the App does', [
      'The App helps you keep a list of your recurring subscriptions, '
          'see when they renew, review your spending, and receive reminders '
          'before a renewal.',
      'The App is a tracking tool only. It does not make payments, it '
          'does not connect to your bank or cards, and it does not cancel '
          'or change any subscription with a service provider. The "Mark as '
          'paid" button only records, inside the App, that you have already '
          'paid.',
    ]),
    _Section('3. Who can use the App', [
      'You must be at least 13 years old, or the minimum age required '
          'in your country to use an app like this. You are responsible for '
          'the device and the Google account you use with the App.',
    ]),
    _Section('4. Your information and your responsibility', [
      'Everything you see in the App is information you entered '
          'yourself, such as names, prices, currencies and dates. You are '
          'responsible for keeping it correct and up to date. The App\'s '
          'totals, charts and countdowns are only as accurate as the '
          'information you provide, and they are not financial advice.',
    ]),
    _Section('5. Reminders and notifications', [
      'Reminders are scheduled on your phone and are provided on a '
          'best-effort basis. They can be late, or not appear at all, for '
          'reasons outside our control. Examples are battery saver or '
          'app-sleeping settings, a denied notification or exact-alarm '
          'permission, Do Not Disturb, a phone that is switched off, or '
          'restrictions added by your phone\'s maker or by Android.',
      'Please do not rely only on the App to avoid charges. We are not '
          'responsible for a missed reminder, a renewal you did not expect, '
          'or any fee or penalty that results.',
    ]),
    _Section('6. Backup and restore', [
      'Backup to Google Drive is optional and uses your own Google '
          'account. Each backup is saved in a private, hidden folder of '
          'your Drive and is merged with any backup that already exists '
          'there.',
      'You are responsible for taking backups regularly. If you '
          'uninstall the App, clear its storage or lose your phone without '
          'a backup, your data cannot be recovered. Subscriptions you '
          'delete permanently cannot be restored.',
    ]),
    _Section('7. Third-party services, names and logos', [
      'Sign-in and backup use Google services and are subject to '
          'Google\'s own terms and privacy policy. We are not responsible '
          'for Google\'s services or for any change or outage in them.',
      'Service names and logos shown in the App belong to their '
          'respective owners. They are shown only to help you recognise the '
          'services you track. The App is not affiliated with, endorsed by '
          'or sponsored by any of those companies.',
    ]),
    _Section('8. Acceptable use', [
      'You agree not to misuse the App. In particular, you will not '
          'copy, sell or redistribute the App, try to break or bypass its '
          'protections, reverse engineer it except where the law allows, or '
          'use it in a way that breaks the law.',
    ]),
    _Section('9. Ownership', [
      'The App, including its design, code and content created by us, '
          'We give you a personal, '
          'non-exclusive, non-transferable licence to use the App on your '
          'own devices, according to these terms. Your own data remains '
          'yours.',
    ]),
    _Section('10. No warranty', [
      'The App is provided "as is" and "as available". We do not '
          'promise that it will be error-free, uninterrupted or suitable '
          'for your particular needs, or that your data will never be lost.',
    ]),
    _Section('11. Limitation of liability', [
      'To the fullest extent allowed by law, we will not be liable for  '
          'liable for any indirect, incidental or consequential loss, '
          'including loss of data, missed payments, late fees or loss of '
          'profit, arising from your use of, or inability to use, the App. '
          'Nothing in these terms limits any right you have under the law '
          'that cannot be limited.',
    ]),
    _Section('12. Ending your use', [
      'You can stop using the App at any time by uninstalling it. We '
          'may change, suspend or stop the App, or any part of it, at any '
          'time. Sections that by their nature should continue to apply, '
          'such as ownership, no warranty and limitation of liability, '
          'continue after you stop using the App.',
    ]),
    _Section('13. Changes to these terms', [
      'We may update these terms from time to time. When we do, we will '
          'change the effective date at the top of this page. If you keep '
          'using the App after a change, you accept the updated terms.',
    ]),
    _Section('14. Governing law', [
      'These terms are governed by the laws of Pakistan, and any '
          'dispute will be handled by the courts of Pakistan, unless the '
          'law of your place of residence requires otherwise.',
    ]),
    _Section('15. Contact us', [
      'If you have any questions about these terms, contact at: $_contactEmail',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          32 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Text(
            'Terms and Conditions for Subscription Manager',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '''
Effective date: $_lastUpdated ''',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          for (final section in _sections) ...[
            const SizedBox(height: 24),
            Text(
              section.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
            for (final paragraph in section.paragraphs) ...[
              const SizedBox(height: 8),
              Text(
                paragraph,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _Section {
  final String title;
  final List<String> paragraphs;

  const _Section(this.title, this.paragraphs);
}