import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/design_system.dart';
import '../../data/content/content_pack_provider.dart';
import '../../data/local/database_provider.dart';
import 'today_controller.dart';
import 'widgets/daily_action_card.dart';
import 'widgets/daily_reflection_card.dart';
import 'widgets/reading_references_card.dart';
import 'widgets/reflection_note_card.dart';
import 'widgets/swipeable_liturgical_context_card.dart';
import 'widgets/today_error_widget.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  static const _initialCardPage = 10000;

  late Future<TodayViewData> _todayFuture;
  late final PageController _cardPageController;
  final _noteController = TextEditingController();
  final Map<String, Future<TodayViewData>> _previewFutures = {};
  int _cardPage = _initialCardPage;
  String? _cardDateKey;
  String _savedNoteText = '';
  bool _isCompleting = false;
  bool _isSavingNote = false;
  bool _isNoteDirty = false;
  bool _isSyncingNoteText = false;

  @override
  void initState() {
    super.initState();
    _cardPageController = PageController(initialPage: _initialCardPage);
    _noteController.addListener(_handleNoteChanged);
    _todayFuture = _loadToday();
  }

  @override
  void dispose() {
    _cardPageController.dispose();
    _noteController.removeListener(_handleNoteChanged);
    _noteController.dispose();
    super.dispose();
  }

  Future<TodayViewData> _loadToday() async {
    try {
      await ref.read(seedContentBootstrapProvider.future);
      final data = await TodayController(
        db: ref.read(databaseProvider),
        settings: ref.read(userSettingsRepositoryProvider),
        engine: ref.read(dailyActionEngineProvider),
      ).load();

      _syncSavedNote(data.log?.note ?? '');
      return data;
    } catch (error, stackTrace) {
      debugPrint('Today load failed: $error\n$stackTrace');
      rethrow;
    }
  }

  Future<TodayViewData> _loadPreviewDate(String dateKey) async {
    await ref.read(seedContentBootstrapProvider.future);
    return _controller.load(date: dateKey);
  }

  Future<void> _completeAction(TodayViewData data) async {
    if (_isCompleting) {
      return;
    }
    setState(() => _isCompleting = true);
    try {
      await _controller.completeAction(data, note: _noteController.text);
      if (mounted) {
        _markCurrentNoteSaved();
        final future = _loadToday();
        setState(() {
          _todayFuture = future;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  Future<void> _saveNote(TodayViewData data) async {
    if (_isSavingNote) {
      return;
    }
    setState(() => _isSavingNote = true);
    try {
      await _controller.saveNote(data, _noteController.text);
      if (mounted) {
        _markCurrentNoteSaved();
        final future = _loadToday();
        setState(() {
          _todayFuture = future;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingNote = false);
      }
    }
  }

  TodayController get _controller {
    return TodayController(
      db: ref.read(databaseProvider),
      settings: ref.read(userSettingsRepositoryProvider),
      engine: ref.read(dailyActionEngineProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Sống Đạo'),
        actions: [
          IconButton(
            tooltip: 'Cài đặt',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: FutureBuilder<TodayViewData>(
        future: _todayFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return TodayErrorWidget(onRetry: _refresh);
          }

          final data = snapshot.data!;
          _cardDateKey ??= data.date;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.screenPadding,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SwipeableLiturgicalContextCard(
                          todayData: data,
                          cardPageController: _cardPageController,
                          cardDateKey: _cardDateKey ?? data.date,
                          previewForDate: _previewForDate,
                          onPageChanged: _changeCardPage,
                          onPrevious: () => _animateCardToPage(_cardPage - 1),
                          onNext: () => _animateCardToPage(_cardPage + 1),
                          onToday: _animateCardToToday,
                        ),
                        const SizedBox(height: AppSpacing.x4),
                        DailyActionCard(
                          data: data,
                          isCompleting: _isCompleting,
                          onComplete: () => _completeAction(data),
                        ),
                        if (data.log?.status == 'completed') ...[
                          const SizedBox(height: AppSpacing.x4),
                          ReflectionNoteCard(
                            controller: _noteController,
                            isSaving: _isSavingNote,
                            isDirty: _isNoteDirty,
                            hasSavedNote: _savedNoteText.trim().isNotEmpty,
                            onSave: () => _saveNote(data),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.x4),
                        Wrap(
                          spacing: AppSpacing.x4,
                          runSpacing: AppSpacing.x4,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ReadingReferencesCard(
                                readings: data.readings,
                              ),
                            ),
                            if (data.reflection != null)
                              SizedBox(
                                width: double.infinity,
                                child: DailyReflectionCard(
                                  reflection: data.reflection!,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(seedContentBootstrapProvider);
    _previewFutures.clear();
    final future = _loadToday();
    setState(() {
      _todayFuture = future;
    });
    await _todayFuture;
  }

  Future<TodayViewData> _previewForDate(String dateKey) {
    return _previewFutures.putIfAbsent(
      dateKey,
      () => _loadPreviewDate(dateKey),
    );
  }

  void _changeCardPage(int page, TodayViewData todayData) {
    setState(() {
      _cardPage = page;
      _cardDateKey = _dateKeyForCardPage(page, todayData.date);
    });
  }

  Future<void> _animateCardToPage(int page) {
    return _cardPageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _animateCardToToday() {
    return _animateCardToPage(_initialCardPage);
  }

  void _handleNoteChanged() {
    if (_isSyncingNoteText) {
      return;
    }
    final isDirty = _noteController.text.trim() != _savedNoteText.trim();
    if (isDirty == _isNoteDirty || !mounted) {
      return;
    }
    setState(() => _isNoteDirty = isDirty);
  }

  void _syncSavedNote(String note) {
    _isSyncingNoteText = true;
    _savedNoteText = note;
    _noteController.text = note;
    _isNoteDirty = false;
    _isSyncingNoteText = false;
  }

  void _markCurrentNoteSaved() {
    _savedNoteText = _noteController.text.trim();
    _isNoteDirty = false;
  }

  String _dateKeyForCardPage(int page, String todayDateKey) {
    final today = DateTime.parse(todayDateKey);
    final previewDate = today.add(Duration(days: page - _initialCardPage));
    return DateFormat('yyyy-MM-dd').format(previewDate);
  }
}
