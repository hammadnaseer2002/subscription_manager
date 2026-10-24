import 'package:flutter/material.dart';

/// In-app Privacy Policy screen (offline kaam karti hai, koi link nahi chahiye).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // TODO: apna asli email likho
  static const String _contactEmail = 'hammadnaseer2002@gmail.com';
  static const String _lastUpdated = 'October 24, 2026';

  static const List<_Section> _sections = [
    _Section('1. Introduction', [
      'Subscription Manager ("the App") helps you keep track of your recurring '
          'subscriptions and sends you reminders before they renew. This policy '
          'explains what information the App handles, how it is stored, and what '
          'choices you have.',
      'In short: your data stays on your device. It only leaves your device if '
          'you choose to back it up to your own Google Drive.',
    ]),
    _Section('2. Information the App handles', [
      'Subscription details you enter: for example the service name, price, '
          'currency, billing cycle, billing dates, reminder preferences and the '
          'payments you record with "Mark as paid". You provide this information '
          'yourself, and it is used only to show your subscriptions and schedule '
          'your reminders.',
      'Google account information (only if you use Backup): if you choose to '
          'sign in with Google to back up or restore your data, the App receives '
          'your Google account name, email address and profile picture through '
          'Google Sign-In. This is used only to identify the signed-in account, '
          'show it in Settings, and access your backup in Google Drive.',
      'What the App does not collect: your location, contacts, photos, files, '
          'advertising identifiers or payment card details. The App does not '
          'include analytics, advertising or crash-reporting services. It has no '
          'user accounts of its own and does not send your data to any server '
          'operated by us.',
    ]),
    _Section('3. How your data is stored', [
      'On your device: your subscriptions and payment history are stored in a '
          'local database inside the App\'s private storage on your phone. We '
          'cannot access this data.',
      'Google Drive backup (optional): when you tap Backup, a backup file '
          'containing your subscription records and payment history is saved to '
          'the hidden app data folder of your own Google Drive. This folder is '
          'private to the App: the file does not appear in your normal Drive '
          'files, other apps cannot read it, and we cannot access it. Each new '
          'backup is merged with the existing backup file so that records are '
          'not lost. When you tap Restore, the file is downloaded back to your '
          'device.',
    ]),
    _Section('4. Permissions the App uses', [
      '• Internet and network state: only to sign in with Google and to back up '
          'or restore your data.',
      '• Notifications: to show your renewal reminders.',
      '• Exact alarms: to deliver reminders at the time you expect. You can '
          'deny this in your phone settings, in which case reminders may arrive '
          'a little late.',
      '• Run at startup: to restore your scheduled reminders after your phone '
          'restarts.',
      '• Vibrate: so reminders can alert you.',
      'Reminders are scheduled locally on your device. No data is sent anywhere '
          'to create them.',
    ]),
    _Section('5. Sharing of information', [
      'We do not sell, rent, trade or share your personal information with '
          'anyone. If you use Backup, your backup file is stored with Google and '
          'is subject to Google\'s own privacy policy: '
          'https://policies.google.com/privacy',
    ]),
    _Section('6. Google API Services disclosure', [
      'The App requests only the Google Drive app data scope '
          '(https://www.googleapis.com/auth/drive.appdata) together with basic '
          'account information. Drive access is used solely to store and '
          'retrieve your backup file in the App\'s private folder.',
      'The App\'s use and transfer of information received from Google APIs '
          'adheres to the Google API Services User Data Policy, including the '
          'Limited Use requirements.',
    ]),
    _Section('7. Data retention and deletion', [
      'On your device: when you delete a subscription it moves to "Recently '
          'deleted", where you can restore it or delete it permanently. '
          'Deleting permanently removes the subscription and its payment '
          'history from your device. Uninstalling the App or clearing its '
          'storage removes all data stored on your device.',
      'In Google Drive: a subscription you delete permanently is also removed '
          'from your Drive backup the next time you back up. Subscriptions that '
          'are only in "Recently deleted" may remain in your backup file as '
          'deleted records. To remove your backup completely, open Google '
          'Drive, go to Settings, then Manage apps, find Subscription Manager '
          'and choose to delete its hidden app data. You can also revoke the '
          'App\'s access at any time from your Google Account under Security, '
          'Third-party access.',
    ]),
    _Section('8. Security', [
      'Your data on the device is protected by Android\'s app sandbox. Backup '
          'and restore use Google\'s APIs over encrypted connections, and your '
          'backup is protected by the security of your Google account. No '
          'method of storage or transmission is completely secure, so we '
          'cannot guarantee absolute security.',
    ]),
    _Section('9. Children\'s privacy', [
      'The App is not directed at children under 13, and we do not knowingly '
          'collect personal information from children.',
    ]),
    _Section('10. Changes to this policy', [
      'We may update this policy from time to time. When we do, we will change '
          'the date at the top of this page. Continued use of the App after a '
          'change means you accept the updated policy.',
    ]),
    _Section('11. Contact us', [
      'If you have any questions about this policy, contact at: '
          '$_contactEmail',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          32 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Text(
            'Privacy Policy for Subscription Manager',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Last updated: $_lastUpdated  ·  Developer: Infinity Stack',
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