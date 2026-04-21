import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../services/firebase/auth_service.dart';
import '../services/affirmation_service.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _affirmationsEnabled = true;
  TimeOfDay _affirmationTime = TimeOfDay(
    hour: AppConstants.defaultAffirmationHour,
    minute: AppConstants.defaultAffirmationMinute,
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final userData = await AuthService.instance.getUserData();
    if (userData != null) {
      final affirmationTime = userData['affirmationTime'] as Map<String, dynamic>?;
      setState(() {
        _affirmationsEnabled = userData['affirmationsEnabled'] ?? true;
        _affirmationTime = TimeOfDay(
          hour: affirmationTime?['hour'] ?? AppConstants.defaultAffirmationHour,
          minute: affirmationTime?['minute'] ?? AppConstants.defaultAffirmationMinute,
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAffirmationSettings() async {
    await AuthService.instance.updateAffirmationSettings(
      enabled: _affirmationsEnabled,
      hour: _affirmationTime.hour,
      minute: _affirmationTime.minute,
    );

    if (_affirmationsEnabled) {
      await AffirmationService.instance.scheduleDailyAffirmation(
        hour: _affirmationTime.hour,
        minute: _affirmationTime.minute,
      );
    } else {
      await AffirmationService.instance.cancelAffirmations();
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _affirmationTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() => _affirmationTime = time);
      await _updateAffirmationSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Affirmation time updated to ${time.format(context)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _sendTestNotification() async {
    await AffirmationService.instance.sendTestAffirmation();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test affirmation sent!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background(context),
        appBar: AppBar(
          title: Text('Settings'),
          backgroundColor: Colors.transparent,
        ),
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Daily Affirmations',
            icon: Icons.notifications_active,
            children: [
              SwitchListTile(
                title: Text('Enable Daily Affirmations'),
                subtitle: Text('Receive positive affirmations every day'),
                value: _affirmationsEnabled,
                activeColor: AppTheme.primary,
                onChanged: (value) async {
                  setState(() => _affirmationsEnabled = value);
                  await _updateAffirmationSettings();
                },
              ),
              if (_affirmationsEnabled) ...[
                ListTile(
                  leading: Icon(Icons.access_time, color: AppTheme.primary),
                  title: Text('Notification Time'),
                  subtitle: Text(_affirmationTime.format(context)),
                  trailing: Icon(Icons.chevron_right),
                  onTap: _selectTime,
                ),
                ListTile(
                  leading: Icon(Icons.send, color: AppTheme.primary),
                  title: Text('Send Test Notification'),
                  subtitle: Text('Test your affirmation notification'),
                  onTap: _sendTestNotification,
                ),
              ],
            ],
          ),
          SizedBox(height: 16),
          _buildSection(
            title: 'Account',
            icon: Icons.person,
            children: [
              ListTile(
                leading: Icon(Icons.email, color: AppTheme.primary),
                title: Text('Email'),
                subtitle: Text(AuthService.instance.currentUser?.email ?? 'Not available'),
              ),
              ListTile(
                leading: Icon(Icons.person, color: AppTheme.primary),
                title: Text('Name'),
                subtitle: Text(AuthService.instance.currentUser?.displayName ?? 'Not available'),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildSection(
            title: 'About',
            icon: Icons.info,
            children: [
              ListTile(
                leading: Icon(Icons.info_outline, color: AppTheme.primary),
                title: Text('Version'),
                subtitle: Text(AppConstants.version),
              ),
              ListTile(
                leading: Icon(Icons.privacy_tip, color: AppTheme.primary),
                title: Text('Privacy Policy'),
                subtitle: Text('Your data stays on your device'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Privacy Policy'),
                      content: Text(
                        'Mental Wellness respects your privacy. All behavioral data is stored locally on your device. Only authentication data is stored in Firebase for account management.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}
