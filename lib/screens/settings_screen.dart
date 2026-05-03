import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../services/cloud/auth_service.dart';
import '../services/cloud/cloud_sync_service.dart';
import '../services/notifications/affirmation_service.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── Affirmation state ──────────────────────────────────────────────────────
  bool _affirmationsEnabled = true;
  TimeOfDay _affirmationTime = TimeOfDay(
    hour: AppConstants.defaultAffirmationHour,
    minute: AppConstants.defaultAffirmationMinute,
  );

  // ── Cloud sync state ───────────────────────────────────────────────────────
  bool _cloudSyncEnabled = false;
  bool _syncInProgress = false;
  int _syncedRecordCount = 0;
  String _lastSyncLabel = 'Never synced';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<void> _loadSettings() async {
    final results = await Future.wait([
      AuthService.instance.getUserData(),
      CloudSyncService.instance.isSyncEnabled(),
      CloudSyncService.instance.fetchSyncedRecords(),
    ]);

    final userData    = results[0] as Map<String, dynamic>?;
    final syncEnabled = results[1] as bool;
    final syncRecords = results[2] as List<Map<String, dynamic>>;

    if (!mounted) return;
    setState(() {
      if (userData != null) {
        final timeMap = userData['affirmationTime'] as Map<String, dynamic>?;
        _affirmationsEnabled = userData['affirmationsEnabled'] ?? true;
        _affirmationTime = TimeOfDay(
          hour:   timeMap?['hour']   ?? AppConstants.defaultAffirmationHour,
          minute: timeMap?['minute'] ?? AppConstants.defaultAffirmationMinute,
        );
      }
      _cloudSyncEnabled  = syncEnabled;
      _syncedRecordCount = syncRecords.length;
      _lastSyncLabel     = _buildLastSyncLabel(syncRecords);
      _isLoading = false;
    });
  }

  String _buildLastSyncLabel(List<Map<String, dynamic>> records) {
    if (records.isEmpty) return 'Never synced';
    final latest = records.first['date'] as String?;
    return latest != null ? 'Last synced: $latest' : 'Never synced';
  }

  // ── Affirmation helpers ────────────────────────────────────────────────────

  Future<void> _updateAffirmationSettings() async {
    await AuthService.instance.updateAffirmationSettings(
      enabled: _affirmationsEnabled,
      hour:    _affirmationTime.hour,
      minute:  _affirmationTime.minute,
    );
    if (_affirmationsEnabled) {
      await AffirmationService.instance.scheduleDailyAffirmation(
        hour:   _affirmationTime.hour,
        minute: _affirmationTime.minute,
      );
    } else {
      await AffirmationService.instance.cancelAffirmations();
    }
  }

  Future<void> _selectTime() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final time = await showTimePicker(
      context: context,
      initialTime: _affirmationTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: isDark
              ? ColorScheme.dark(primary: AppTheme.primary)
              : ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (time != null) {
      setState(() => _affirmationTime = time);
      await _updateAffirmationSettings();
      if (mounted) _showSnackBar('Affirmation time updated to ${time.format(context)}');
    }
  }

  Future<void> _sendTestNotification() async {
    await AffirmationService.instance.sendTestAffirmation();
    if (mounted) _showSnackBar('Test affirmation sent!');
  }

  // ── Cloud sync helpers ─────────────────────────────────────────────────────

  Future<void> _toggleCloudSync(bool enabled) async {
    setState(() => _syncInProgress = true);
    try {
      await CloudSyncService.instance.setSyncEnabled(enabled);
      final records = await CloudSyncService.instance.fetchSyncedRecords();
      if (mounted) {
        setState(() {
          _cloudSyncEnabled  = enabled;
          _syncedRecordCount = records.length;
          _lastSyncLabel     = _buildLastSyncLabel(records);
          _syncInProgress    = false;
        });
        _showSnackBar(
          enabled ? 'Cloud sync enabled — mood data synced ✓' : 'Cloud sync disabled',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _syncInProgress = false);
        _showSnackBar('Sync failed: $e', isError: true);
      }
    }
  }

  Future<void> _syncNow() async {
    setState(() => _syncInProgress = true);
    try {
      await CloudSyncService.instance.syncNow();
      final records = await CloudSyncService.instance.fetchSyncedRecords();
      if (mounted) {
        setState(() {
          _syncedRecordCount = records.length;
          _lastSyncLabel     = _buildLastSyncLabel(records);
          _syncInProgress    = false;
        });
        _showSnackBar('Synced $_syncedRecordCount mood records ✓');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _syncInProgress = false);
        _showSnackBar('Sync failed: $e', isError: true);
      }
    }
  }

  Future<void> _confirmClearCloudData() async {
    final textColor = AppTheme.textPrimary(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear Cloud Data?',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
        content: Text(
          'This will permanently delete all synced mood records from the cloud. '
          'Your local data on this device will not be affected.',
          style: TextStyle(color: textColor, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _syncInProgress = true);
      try {
        await CloudSyncService.instance.clearCloudData();
        if (mounted) {
          setState(() {
            _syncedRecordCount = 0;
            _lastSyncLabel     = 'Never synced';
            _syncInProgress    = false;
          });
          _showSnackBar('Cloud mood data deleted');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _syncInProgress = false);
          _showSnackBar('Delete failed: $e', isError: true);
        }
      }
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: AppTheme.white)),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final textPrimary   = AppTheme.textPrimary(context);
    final textSecondary = AppTheme.textSecondary(context);
    final bg            = AppTheme.background(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: Text('Settings', style: TextStyle(color: textPrimary)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: textPrimary),
        ),
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Daily Affirmations ──────────────────────────────────────────
          _buildSection(
            title: 'Daily Affirmations',
            icon: Icons.notifications_active_outlined,
            iconColor: Colors.purple,
            children: [
              SwitchListTile(
                title: Text('Enable Daily Affirmations',
                    style: TextStyle(color: textPrimary, fontWeight: FontWeight.w500)),
                subtitle: Text('Receive positive affirmations every day',
                    style: TextStyle(color: textSecondary, fontSize: 13)),
                value: _affirmationsEnabled,
                activeColor: AppTheme.primary,
                onChanged: (v) async {
                  setState(() => _affirmationsEnabled = v);
                  await _updateAffirmationSettings();
                },
              ),
              if (_affirmationsEnabled) ...[
                ListTile(
                  leading: Icon(Icons.access_time, color: AppTheme.primary),
                  title: Text('Notification Time',
                      style: TextStyle(color: textPrimary, fontWeight: FontWeight.w500)),
                  subtitle: Text(_affirmationTime.format(context),
                      style: TextStyle(color: textSecondary, fontSize: 13)),
                  trailing: Icon(Icons.chevron_right, color: textSecondary),
                  onTap: _selectTime,
                ),
                ListTile(
                  leading: Icon(Icons.send_outlined, color: AppTheme.primary),
                  title: Text('Send Test Notification',
                      style: TextStyle(color: textPrimary, fontWeight: FontWeight.w500)),
                  subtitle: Text('Preview your daily affirmation',
                      style: TextStyle(color: textSecondary, fontSize: 13)),
                  trailing: Icon(Icons.chevron_right, color: textSecondary),
                  onTap: _sendTestNotification,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // ── Cloud Sync ──────────────────────────────────────────────────
          _buildSection(
            title: 'Cloud Sync',
            icon: Icons.cloud_sync_outlined,
            iconColor: Colors.blue,
            children: [
              // Privacy callout
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 18, color: AppTheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Only anonymised mood sentiment (date + positive / '
                        'neutral / negative) is uploaded. No journal text, '
                        'no personal notes — ever.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Master toggle
              SwitchListTile(
                title: Text('Sync Mood Data to Cloud',
                    style: TextStyle(
                        color: textPrimary, fontWeight: FontWeight.w500)),
                subtitle: Text(
                  _cloudSyncEnabled ? _lastSyncLabel : 'Your mood history stays local only',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
                value: _cloudSyncEnabled,
                activeColor: AppTheme.primary,
                secondary: _syncInProgress
                    ? SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.primary),
                      )
                    : null,
                onChanged: _syncInProgress ? null : _toggleCloudSync,
              ),

              // Synced records badge
              if (_cloudSyncEnabled) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_done_outlined,
                            size: 14, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          '$_syncedRecordCount mood day'
                          '${_syncedRecordCount == 1 ? '' : 's'} synced',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Sync now
                ListTile(
                  leading: Icon(Icons.sync, color: AppTheme.primary),
                  title: Text('Sync Now',
                      style: TextStyle(
                          color: textPrimary, fontWeight: FontWeight.w500)),
                  subtitle: Text('Upload latest 30 days of mood data',
                      style: TextStyle(color: textSecondary, fontSize: 13)),
                  trailing: _syncInProgress
                      ? SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppTheme.primary),
                        )
                      : Icon(Icons.chevron_right, color: textSecondary),
                  onTap: _syncInProgress ? null : _syncNow,
                ),

                // Clear cloud data
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Clear Cloud Data',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w500)),
                  subtitle: Text('Delete all synced records from the cloud',
                      style: TextStyle(color: textSecondary, fontSize: 13)),
                  onTap: _syncInProgress ? null : _confirmClearCloudData,
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // ── Account ─────────────────────────────────────────────────────
          _buildSection(
            title: 'Account',
            icon: Icons.person_outline,
            iconColor: Colors.green,
            children: [
              ListTile(
                leading: Icon(Icons.email_outlined, color: AppTheme.primary),
                title: Text('Email',
                    style: TextStyle(
                        color: textPrimary, fontWeight: FontWeight.w500)),
                subtitle: Text(
                  AuthService.instance.currentUser?.email ?? 'Not available',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
              ),
              ListTile(
                leading: Icon(Icons.badge_outlined, color: AppTheme.primary),
                title: Text('Name',
                    style: TextStyle(
                        color: textPrimary, fontWeight: FontWeight.w500)),
                subtitle: Text(
                  AuthService.instance.currentUser?.displayName ?? 'Not available',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── About ────────────────────────────────────────────────────────
          _buildSection(
            title: 'About',
            icon: Icons.info_outline,
            iconColor: Colors.orange,
            children: [
              ListTile(
                leading: Icon(Icons.tag, color: AppTheme.primary),
                title: Text('Version',
                    style: TextStyle(
                        color: textPrimary, fontWeight: FontWeight.w500)),
                subtitle: Text(AppConstants.version,
                    style: TextStyle(color: textSecondary, fontSize: 13)),
              ),
              ListTile(
                leading:
                    Icon(Icons.privacy_tip_outlined, color: AppTheme.primary),
                title: Text('Privacy Policy',
                    style: TextStyle(
                        color: textPrimary, fontWeight: FontWeight.w500)),
                subtitle: Text('What data we store and where',
                    style: TextStyle(color: textSecondary, fontSize: 13)),
                trailing: Icon(Icons.chevron_right, color: textSecondary),
                onTap: () => _showPrivacyDialog(textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Privacy dialog ─────────────────────────────────────────────────────────

  void _showPrivacyDialog(Color textColor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface(context),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Privacy Policy',
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.w700)),
        content: Text(
          'Mental Wellness stores all personal data locally on your device '
          'using SQLite — including journal entries, emotional notes, gratitude '
          'entries, and behavioural patterns.\n\n'
          'Firebase stores only your email and display name for authentication.\n\n'
          'Cloud Sync is opt-in. When enabled, only anonymised mood sentiment '
          '(date + positive / neutral / negative) is uploaded to Firestore. '
          'No personal text is ever sent to the cloud.',
          style: TextStyle(color: textColor, height: 1.6, fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  // ── Section card builder ───────────────────────────────────────────────────

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color iconColor = Colors.teal,
  }) {
    final textPrimary   = AppTheme.textPrimary(context);
    final surfaceColor  = AppTheme.surface(context);
    final dividerColor  =
        AppTheme.textSecondary(context).withValues(alpha: 0.15);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: dividerColor),
          ...children,
        ],
      ),
    );
  }
}
