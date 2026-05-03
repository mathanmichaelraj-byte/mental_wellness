import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/journal_entry.dart';
import '../../services/local/database_service.dart';
import '../../utils/app_theme.dart';

/// Full-featured permanent daily journal.
///
/// Entries are stored forever in SQLite (unlike [EmotionalReleaseScreen]
/// which auto-deletes after a chosen window).  Users can write, edit, and
/// delete entries; each entry carries an optional mood tag.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with TickerProviderStateMixin {
  List<JournalEntry> _entries = [];
  bool _loading = true;

  late AnimationController _fadeCtrl;

  // Mood tag options for the entry editor
  static const List<Map<String, dynamic>> _moodTags = [
    {'label': 'Happy',     'icon': Icons.sentiment_very_satisfied, 'color': Color(0xFFCE93D8)},
    {'label': 'Calm',      'icon': Icons.spa,                      'color': Color(0xFFA5D6A7)},
    {'label': 'Grateful',  'icon': Icons.favorite,                 'color': Color(0xFFFF8A80)},
    {'label': 'Neutral',   'icon': Icons.sentiment_neutral,        'color': Color(0xFF80DEEA)},
    {'label': 'Anxious',   'icon': Icons.bolt,                     'color': Color(0xFFFFCC80)},
    {'label': 'Tired',     'icon': Icons.battery_2_bar,            'color': Color(0xFFB0BEC5)},
    {'label': 'Sad',       'icon': Icons.sentiment_dissatisfied,   'color': Color(0xFF90CAF9)},
    {'label': 'Angry',     'icon': Icons.local_fire_department,    'color': Color(0xFFEF9A9A)},
    {'label': 'Energised', 'icon': Icons.flash_on,                 'color': Color(0xFFFFF176)},
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _loadEntries();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final entries = await DatabaseService.instance.getAllJournalEntries();
    if (mounted) setState(() { _entries = entries; _loading = false; });
  }

  // ── Editor sheet ───────────────────────────────────────────────────────────

  Future<void> _openEditor({JournalEntry? existing}) async {
    final titleCtrl =
        TextEditingController(text: existing?.title ?? '');
    final contentCtrl =
        TextEditingController(text: existing?.content ?? '');
    String? selectedMood = existing?.mood;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => DraggableScrollableSheet(
          initialChildSize: 0.92,
          maxChildSize: 0.97,
          minChildSize: 0.6,
          builder: (_, scrollCtrl) => Container(
            decoration: BoxDecoration(
              color: AppTheme.background(context),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          existing == null ? 'New Entry' : 'Edit Entry',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final title = titleCtrl.text.trim();
                          final content = contentCtrl.text.trim();
                          if (title.isEmpty && content.isEmpty) return;
                          final now = DateTime.now();
                          if (existing == null) {
                            await DatabaseService.instance.insertJournalEntry(
                              JournalEntry(
                                title: title.isEmpty ? 'Untitled' : title,
                                content: content,
                                mood: selectedMood,
                                createdAt: now,
                                updatedAt: now,
                              ),
                            );
                          } else {
                            await DatabaseService.instance.updateJournalEntry(
                              existing.copyWith(
                                title: title.isEmpty ? 'Untitled' : title,
                                content: content,
                                mood: selectedMood,
                                updatedAt: now,
                              ),
                            );
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                          _loadEntries();
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                    children: [
                      // Date label
                      Text(
                        DateFormat('EEEE, MMMM d yyyy')
                            .format(existing?.createdAt ?? DateTime.now()),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title field
                      TextField(
                        controller: titleCtrl,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          hintText: 'Title (optional)',
                          hintStyle: TextStyle(
                              color: AppTheme.textSecondary(context),
                              fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                      Divider(
                          color:
                              AppTheme.textSecondary(context).withValues(alpha: 0.2)),
                      const SizedBox(height: 12),

                      // Content field
                      TextField(
                        controller: contentCtrl,
                        minLines: 8,
                        maxLines: null,
                        style: const TextStyle(fontSize: 15, height: 1.7),
                        decoration: InputDecoration(
                          hintText:
                              'Write freely — this is your space...',
                          hintStyle: TextStyle(
                              color: AppTheme.textSecondary(context)),
                          border: InputBorder.none,
                          filled: false,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Mood tag picker
                      Text('How are you feeling?',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary(context))),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _moodTags.map((m) {
                          final selected = selectedMood == m['label'];
                          return GestureDetector(
                            onTap: () => setSheet(() {
                              selectedMood =
                                  selected ? null : m['label'] as String;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? (m['color'] as Color)
                                        .withValues(alpha: 0.25)
                                    : AppTheme.surface(context),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? m['color'] as Color
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(m['icon'] as IconData,
                                      size: 16,
                                      color: selected
                                          ? m['color'] as Color
                                          : AppTheme.textSecondary(context)),
                                  const SizedBox(width: 6),
                                  Text(
                                    m['label'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: selected
                                          ? m['color'] as Color
                                          : AppTheme.textSecondary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> _confirmDelete(JournalEntry entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Entry?'),
        content: const Text(
          'This entry will be permanently deleted and cannot be recovered.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseService.instance.deleteJournalEntry(entry.id!);
      _loadEntries();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        title: const Text('My Journal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_entries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_entries.length} entries',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('New Entry',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _buildEmpty()
              : FadeTransition(
                  opacity: _fadeCtrl,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    itemCount: _entries.length,
                    itemBuilder: (_, i) => _buildCard(_entries[i]),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: AppTheme.gradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.book_outlined, size: 52, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text('Your journal is empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to write your first entry.',
            style: TextStyle(
                fontSize: 14, color: AppTheme.textSecondary(context)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(JournalEntry entry) {
    final moodMeta = _moodTags.firstWhere(
      (m) => m['label'] == entry.mood,
      orElse: () => <String, dynamic>{},
    );
    final hasMood = moodMeta.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: hasMood
            ? Border.all(
                color: (moodMeta['color'] as Color).withValues(alpha: 0.35),
                width: 1.5)
            : null,
      ),
      child: InkWell(
        onTap: () => _openEditor(existing: entry),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date + mood tag row
              Row(
                children: [
                  Text(
                    DateFormat('EEE, MMM d').format(entry.createdAt),
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary(context),
                        fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  if (hasMood)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (moodMeta['color'] as Color)
                            .withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(moodMeta['icon'] as IconData,
                              size: 13,
                              color: moodMeta['color'] as Color),
                          const SizedBox(width: 4),
                          Text(
                            entry.mood!,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: moodMeta['color'] as Color),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => _confirmDelete(entry),
                    color: Colors.red.withValues(alpha: 0.7),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Title
              Text(
                entry.title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (entry.content.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  entry.content,
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppTheme.textSecondary(context)),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                DateFormat('hh:mm a').format(entry.createdAt),
                style: TextStyle(
                    fontSize: 11,
                    color:
                        AppTheme.textSecondary(context).withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
