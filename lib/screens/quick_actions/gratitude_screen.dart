import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../models/gratitude_entry.dart';
import '../../services/gratitude_service.dart';
import '../../services/behavior_tracker.dart';
import '../../utils/app_theme.dart';

class GratitudeScreen extends StatefulWidget {
  const GratitudeScreen({super.key});

  @override
  State<GratitudeScreen> createState() => _GratitudeScreenState();
}

class _GratitudeScreenState extends State<GratitudeScreen> with TickerProviderStateMixin {
  List<GratitudeEntry> _entries = [];
  String _selectedCategory = 'all';
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: AppConstants.fadeAnimationMs),
      vsync: this,
    )..forward();
    _slideController = AnimationController(
      duration: Duration(milliseconds: AppConstants.slideAnimationMs),
      vsync: this,
    )..forward();
    _loadEntries();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final entries = _selectedCategory == 'all'
        ? await GratitudeService.instance.getEntries()
        : await GratitudeService.instance.getEntriesByCategory(_selectedCategory);
    setState(() => _entries = entries);
  }

  void _showAddDialog() {
    BehaviorTracker.instance.trackInteraction();
    final contentController = TextEditingController();
    String selectedCategory = AppConstants.gratitudeCategories[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.favorite, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Text('Add Gratitude', style: TextStyle(fontSize: 20)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: contentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'What are you grateful for today?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
                ),
              ),
              SizedBox(height: 16),
              Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AppConstants.gratitudeCategories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setDialogState(() => selectedCategory = cat);
                    },
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.trim().isNotEmpty) {
                  await GratitudeService.instance.addEntry(
                    contentController.text.trim(),
                    selectedCategory,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    _loadEntries();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        title: Text('Gratitude Journal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppTheme.primary,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Add Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: SlideTransition(
          position: Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero)
              .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut)),
          child: Column(
            children: [
              _buildHeader(),
              _buildCategoryFilter(),
              Expanded(child: _buildEntriesList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Practice Gratitude',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            'Reflect on the positive moments in your life',
            style: TextStyle(color: AppTheme.textSecondary(context), fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['all', ...AppConstants.gratitudeCategories];
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
                _loadEntries();
              },
              selectedColor: AppTheme.primary,
              backgroundColor: AppTheme.surface(context),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEntriesList() {
    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.gradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite_border, size: 48, color: Colors.white),
            ),
            SizedBox(height: 24),
            Text(
              'No gratitude entries yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Start your gratitude journey today',
              style: TextStyle(color: AppTheme.textSecondary(context)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * AppConstants.staggerDelayMs)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildEntryCard(entry),
        );
      },
    );
  }

  Widget _buildEntryCard(GratitudeEntry entry) {
    final categoryIcon = _getCategoryIcon(entry.category ?? 'other');
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(categoryIcon, color: Colors.white, size: 16),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    (entry.category ?? 'other').toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 20),
                  onPressed: () async {
                    await GratitudeService.instance.deleteEntry(entry.id!);
                    _loadEntries();
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              entry.content,
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            SizedBox(height: 12),
            Text(
              _formatDate(entry.createdAt),
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'people': return Icons.people;
      case 'moments': return Icons.star;
      case 'self': return Icons.self_improvement;
      case 'nature': return Icons.nature;
      default: return Icons.favorite;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
