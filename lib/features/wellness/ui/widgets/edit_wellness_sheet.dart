import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gutcheck/l10n/app_localizations.dart';
import '../../../../core/database/app_database_provider.dart';
import '../../../../core/utils/date_utils.dart';
import '../../data/models/wellness_entry.dart';
import '../../providers/wellness_providers.dart';
import 'diarrhea_toggle.dart';
import 'gi_symptom_slider.dart';

class EditWellnessSheet extends ConsumerStatefulWidget {
  final WellnessEntry entry;

  const EditWellnessSheet({super.key, required this.entry});

  @override
  ConsumerState<EditWellnessSheet> createState() => _EditWellnessSheetState();
}

class _EditWellnessSheetState extends ConsumerState<EditWellnessSheet> {
  late double _gutPeace;
  late double _heartburn;
  late double _stress;
  late bool _diarrhea;
  late DateTime _recordedAt;
  final _notesController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _gutPeace = widget.entry.gutPeaceDisplay;
    _heartburn = widget.entry.heartburnDisplay;
    _stress = widget.entry.stressDisplay;
    _diarrhea = widget.entry.diarrhea;
    _recordedAt = widget.entry.recordedAt;
    _notesController.text = widget.entry.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (_, __) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title + save
              Row(
                children: [
                  Text(
                    l10n.wellnessEditTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.save),
                  ),
                ],
              ),

              // Date + time (tap time to change time, tap date to change date)
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_rounded),
                      title: Text(GutDateUtils.formatDay(_recordedAt)),
                      onTap: _pickDate,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time_rounded),
                      title: Text(GutDateUtils.formatTime(_recordedAt)),
                      onTap: _pickTime,
                      dense: true,
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              GiSymptomSlider(
                label: l10n.wellnessGutPeace,
                minLabel: l10n.wellnessGutPeaceMin,
                maxLabel: l10n.wellnessGutPeaceMax,
                value: _gutPeace,
                inverted: true,
                onChanged: (v) => setState(() => _gutPeace = v),
              ),
              const SizedBox(height: 16),

              GiSymptomSlider(
                label: l10n.wellnessHeartburn,
                minLabel: l10n.wellnessHeartburnMin,
                maxLabel: l10n.wellnessHeartburnMax,
                value: _heartburn,
                inverted: true,
                onChanged: (v) => setState(() => _heartburn = v),
              ),
              const SizedBox(height: 16),

              GiSymptomSlider(
                label: l10n.wellnessStress,
                minLabel: l10n.wellnessStressMin,
                maxLabel: l10n.wellnessStressMax,
                value: _stress,
                inverted: true,
                onChanged: (v) => setState(() => _stress = v),
              ),
              const SizedBox(height: 16),

              // Diarrhea
              DiarrheaToggle(
                value: _diarrhea,
                label: l10n.wellnessDiarrhea,
                onChanged: (v) => setState(() => _diarrhea = v),
              ),
              const SizedBox(height: 20),

              // Notes
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.wellnessNotesLabel,
                  hintText: l10n.wellnessNotesHint,
                  prefixIcon: const Icon(Icons.note_outlined),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _recordedAt,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() {
        _recordedAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _recordedAt.hour,
          _recordedAt.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_recordedAt),
    );
    if (picked != null && mounted) {
      setState(() {
        _recordedAt = DateTime(
          _recordedAt.year,
          _recordedAt.month,
          _recordedAt.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final db = await ref.read(appDatabaseProvider.future);
      final storedGut = WellnessDraftState.toStored(_gutPeace);
      final updated = WellnessEntry()
        ..id = widget.entry.id
        ..recordedAt = _recordedAt
        ..gutPeace = storedGut
        ..heartburn = WellnessDraftState.toStored(_heartburn)
        ..stressLevel = WellnessDraftState.toStored(_stress)
        ..diarrhea = _diarrhea
        ..wellnessScore = ((20 - storedGut) / 20.0) * 100.0
        ..linkedMealIds = List.from(widget.entry.linkedMealIds)
        ..notes = _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim()
        ..isSample = widget.entry.isSample
        ..createdAt = widget.entry.createdAt;
      await db.saveWellness(updated);
      ref.invalidate(wellnessDraftProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
