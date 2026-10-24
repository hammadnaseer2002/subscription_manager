import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/drive_service.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../domain/models/subscription.dart' as model;
import '../../core/notifications/reminder_sync.dart';
import '../../domain/models/payment.dart';
import 'privacy_policy_screen.dart';
import 'terms_and_conditions_screen.dart';
import '../../data/local/deleted_ids_store.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final DriveService _driveService = DriveService();
  String? _userEmail;
  String? _userPhotoUrl; // Added to store the profile picture URL
  bool _isLoading = false;

  /// Snackbar dikhao: purane saaf karo taake queue na bane.
  void _toast(String message, {int seconds = 2}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: seconds),
        ),
      );
  }

  @override
  void initState() {
    super.initState();
    _checkSignIn();
  }

  Future<void> _checkSignIn() async {
    final user = await _driveService.signInSilently();
    if (user != null) {
      setState(() {
        _userEmail = user.email;
        _userPhotoUrl = user.photoUrl; // Capture photo URL
      });
    }
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _driveService.signIn();
      if (user != null) {
        setState(() {
          _userEmail = user.email;
          _userPhotoUrl = user.photoUrl; // Capture photo URL
        });
      }
      // Agar user ne sign-in cancel kiya to kuch mat dikhao
    } catch (e) {
      _toast('Sign in error: $e', seconds: 4);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await _driveService.signOut();
    setState(() {
      _userEmail = null;
      _userPhotoUrl = null; // Clear photo URL on sign out
    });
  }

  Future<void> _backup() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final subscriptions = await repo.getAllSubscriptions();

      // Agar koi (delete na hui) subscription nahi hai to khali backup upload
      // mat karo, warna Drive ka purana backup overwrite ho jata hai.
      final hasData = subscriptions.any(
            (s) => s.status != model.SubscriptionStatus.archived,
      );
      if (!hasData) {
        _toast(
          'No subscriptions to backup',
          seconds: 4,
        );
        return;
      }

      // Drive par jo backup pehle se hai usse MERGE karo (overwrite nahi):
      //  - jo subscription dono mein hai (same id) uska data update hoga
      //    (jo zyada naya ho wo rakha jata hai, barabar ho to phone wala)
      //  - jo sirf Drive wali file mein hai wo bachi rahegi
      //  - jo sirf phone mein hai wo add ho jayegi
      // Merge raw JSON par hota hai, taake purani file ka koi record
      // (chahe parh na sakein) kabhi kho na jaye.
      final merged = <String, Map<String, dynamic>>{};
      final mergedPayments = <String, Map<String, dynamic>>{};

      // Hamesha ke liye delete ki hui ids (phone par + Drive file mein)
      final deletedStore = DeletedIdsStore();
      final deletedIds = await deletedStore.load();

      final existingJson = await _driveService.downloadBackup();
      if (existingJson != null) {
        try {
          final existing = jsonDecode(existingJson) as Map<String, dynamic>;
          final fileDeleted = existing['deletedIds'];
          if (fileDeleted is List) {
            deletedIds.addAll(fileDeleted.map((e) => '$e'));
          }
          final List<dynamic> oldList = existing['subscriptions'] ?? [];
          for (final j in oldList) {
            final m = Map<String, dynamic>.from(j as Map);
            final id = m['id'];
            if (id is String) merged[id] = m;
          }
          final List<dynamic> oldPayments = existing['payments'] ?? [];
          for (final j in oldPayments) {
            final m = Map<String, dynamic>.from(j as Map);
            final id = m['id'];
            if (id is String) mergedPayments[id] = m;
          }
        } catch (_) {
          // Purani file parh na sake to sirf phone ka data upload hoga
        }
      }
      for (final sub in subscriptions) {
        final old = merged[sub.id];
        final oldUpdated =
        old == null ? null : DateTime.tryParse('${old['updatedAt']}');
        if (oldUpdated == null || !sub.updatedAt.isBefore(oldUpdated)) {
          merged[sub.id] = sub.toJson();
        }
      }

      // Payment history: phone ki saari payments Drive wali file se merge
      for (final p in await repo.getAllPayments()) {
        mergedPayments[p.id] = p.toJson();
      }

      // Permanently deleted subscriptions (aur unki payments, aur hatayi hui
      // payments) Drive file se bhi hat jayengi
      merged.removeWhere((id, _) => deletedIds.contains(id));
      mergedPayments.removeWhere(
            (id, m) =>
        deletedIds.contains(id) || deletedIds.contains(m['subscriptionId']),
      );
      await deletedStore.save(deletedIds);

      final backupData = {
        'schemaVersion': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'deletedIds': deletedIds.toList(),
        'subscriptions': merged.values.toList(),
        'payments': mergedPayments.values.toList(),
      };

      await _driveService.uploadBackup(jsonEncode(backupData));

      // Ginti mein sirf wo subscriptions jo delete (archive) nahi hui
      final activeCount =
          merged.values.where((m) => m['status'] != 'archived').length;
      _toast('Backup successful ($activeCount subscriptions)');
    } catch (e) {
      _toast('Error: $e', seconds: 4);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isLoading = true);
    try {
      final jsonStr = await _driveService.downloadBackup();
      if (jsonStr != null) {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        final List<dynamic> subsJson = data['subscriptions'] ?? [];

        // Jo subscriptions hamesha ke liye delete ho chuki hain unhein wapas na lao
        final deletedStore = DeletedIdsStore();
        final deletedIds = await deletedStore.load();
        final fileDeleted = data['deletedIds'];
        if (fileDeleted is List) {
          deletedIds.addAll(fileDeleted.map((e) => '$e'));
        }
        await deletedStore.save(deletedIds);

        final subscriptions = subsJson
            .map((json) => model.Subscription.fromJson(json))
            .where((sub) => !deletedIds.contains(sub.id))
            .toList();

        final repo = ref.read(subscriptionRepositoryProvider);
        await repo.restoreSubscriptions(subscriptions);

        // Payment history bhi wapas lao
        final List<dynamic> paymentsJson = data['payments'] ?? [];
        final payments = <Payment>[];
        for (final j in paymentsJson) {
          try {
            payments.add(Payment.fromJson(Map<String, dynamic>.from(j as Map)));
          } catch (_) {
            // Kharab record chhod do
          }
        }
        await repo.restorePayments(
          payments.where((p) => !deletedIds.contains(p.id)).toList(),
        );

        // Restore hui subscriptions ke reminders schedule karo
        await ref.read(reminderSyncProvider).syncAll();

        _toast('Restore successful');
      } else {
        _toast('No backup found');
      }
    } catch (e) {
      _toast('Error: $e', seconds: 4);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- UI HELPERS ---
  /// About card ki ek row: icon + title + subtitle, tap par naya screen khulta hai.
  Widget _buildAboutRow({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
  }) {
    return InkWell(
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => screen),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.colorScheme.secondary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12, top: 24),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // IgnorePointer prevents user from tapping buttons while loading
          IgnorePointer(
            ignoring: _isLoading,
            child: ListView(
              // Neeche floating tab bar ki jagah chhodni hai taake aakhri tile na chhupe
              padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  40 + MediaQuery.paddingOf(context).bottom
              ),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionHeader('Cloud Sync & Backup', theme),

                // --- Settings Card ---
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  color: theme.colorScheme.surfaceContainerLowest,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Account Info Header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Updated Avatar/Icon Container
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                                image: _userPhotoUrl != null
                                    ? DecorationImage(
                                  image: NetworkImage(_userPhotoUrl!),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                              child: _userPhotoUrl == null
                                  ? Icon(
                                Icons.cloud_sync_rounded,
                                color: theme.colorScheme.onPrimaryContainer,
                                size: 24,
                              )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Google Drive',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _userEmail ?? 'Not signed in',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.tonal(
                              onPressed: _isLoading ? null : (_userEmail == null ? _signIn : _signOut),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _userEmail == null ? 'Sign In' : 'Sign Out',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action Buttons (Only visible if signed in)
                      if (_userEmail != null) ...[
                        Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.3)),

                        // Backup Tile
                        InkWell(
                          onTap: _isLoading ? null : _backup,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.upload_rounded, color: theme.colorScheme.primary, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Backup to Drive',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: _isLoading ? theme.colorScheme.onSurface.withOpacity(0.5) : null,
                                        ),
                                      ),
                                      Text(
                                        'Save your subscriptions securely',
                                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20),
                              ],
                            ),
                          ),
                        ),

                        Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.3)),

                        // Restore Tile
                        InkWell(
                          onTap: _isLoading ? null : _restore,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.tertiary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.download_rounded, color: theme.colorScheme.tertiary, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Restore from Drive',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: _isLoading ? theme.colorScheme.onSurface.withOpacity(0.5) : null,
                                        ),
                                      ),
                                      Text(
                                        'Recover your previously saved data',
                                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),

                _buildSectionHeader('About', theme),
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  color: theme.colorScheme.surfaceContainerLowest,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _buildAboutRow(
                        theme: theme,
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'How your data is handled',
                        screen: const PrivacyPolicyScreen(),
                      ),
                      Divider(
                        height: 1,
                        indent: 20,
                        endIndent: 20,
                        color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                      _buildAboutRow(
                        theme: theme,
                        icon: Icons.description_outlined,
                        title: 'Terms & Conditions',
                        subtitle: 'Rules for using the app',
                        screen: const TermsAndConditionsScreen(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Linear Progress Bar at the top of the screen
          if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 4, // Sleek thickness
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}