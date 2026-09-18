import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result/result.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/schedule_slot.dart';
import 'edt_providers.dart';

const _dayLabels = {1: 'Lundi', 2: 'Mardi', 3: 'Mercredi', 4: 'Jeudi', 5: 'Vendredi'};

/// Ouvre l'éditeur pour un créneau existant, ou un nouveau créneau si [slot]
/// est nul. Retourne `true` si une modification a été enregistrée.
Future<bool?> showSlotEditorSheet(
  BuildContext context, {
  required String versionId,
  required int dayOfWeek,
  ScheduleSlot? slot,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _SlotEditorSheet(
      versionId: versionId,
      dayOfWeek: dayOfWeek,
      slot: slot,
    ),
  );
}

class _SlotEditorSheet extends ConsumerStatefulWidget {
  const _SlotEditorSheet({required this.versionId, required this.dayOfWeek, this.slot});

  final String versionId;
  final int dayOfWeek;
  final ScheduleSlot? slot;

  @override
  ConsumerState<_SlotEditorSheet> createState() => _SlotEditorSheetState();
}

class _SlotEditorSheetState extends ConsumerState<_SlotEditorSheet> {
  late final TextEditingController _subjectController;
  String? _domainCode;
  String? _groupLabel;
  String _taughtBy = 'me';
  bool _isBreak = false;
  late TimeOfDay _start;
  late TimeOfDay _end;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = widget.slot;
    _subjectController = TextEditingController(text: s?.subjectLabel ?? '');
    _domainCode = s?.domainCode;
    _groupLabel = s?.groupLabel;
    _taughtBy = s?.taughtBy ?? 'me';
    _isBreak = s?.isBreak ?? false;
    _start = s != null ? _parseTime(s.startTime) : const TimeOfDay(hour: 8, minute: 30);
    _end = s != null ? _parseTime(s.endTime) : const TimeOfDay(hour: 9, minute: 0);
  }

  static TimeOfDay _parseTime(String hhmmss) {
    final parts = hhmmss.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked == null) return;
    setState(() => isStart ? _start = picked : _end = picked);
  }

  Future<void> _save() async {
    if (_subjectController.text.trim().isEmpty) {
      setState(() => _error = 'La matière est requise.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(edtRepositoryProvider).saveSlot(
            slotId: widget.slot?.id,
            versionId: widget.versionId,
            dayOfWeek: widget.dayOfWeek,
            startTime: _formatTime(_start),
            endTime: _formatTime(_end),
            subjectLabel: _subjectController.text.trim(),
            domainCode: _isBreak ? null : _domainCode,
            groupLabel: _groupLabel,
            taughtBy: _taughtBy,
            isBreak: _isBreak,
          );
      if (!mounted) return;
      ref.invalidate(currentSlotsProvider);
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Échec de l\'enregistrement : $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final slot = widget.slot;
    if (slot == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce créneau ?'),
        content: Text('${slot.subjectLabel} — ${_dayLabels[widget.dayOfWeek]}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _saving = true);
    try {
      await ref.read(edtRepositoryProvider).deleteSlot(slot.id);
      if (!mounted) return;
      ref.invalidate(currentSlotsProvider);
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      setState(() {
        _error = e.message;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final domainCodes = ref.watch(knownDomainCodesProvider).value ?? const <String>[];

    return Padding(
      // Voir AppSpacing.bottomNavClearance : feuille modale ouverte depuis un
      // onglet, donc affichée derrière la barre de navigation flottante.
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.bottomNavClearance,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.slot == null ? 'Nouveau créneau — ${_dayLabels[widget.dayOfWeek]}' : 'Modifier le créneau',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Matière'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(isStart: true),
                    child: Text('Début : ${_start.format(context)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(isStart: false),
                    child: Text('Fin : ${_end.format(context)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pause (récréation, déjeuner…)'),
              value: _isBreak,
              onChanged: (v) => setState(() => _isBreak = v),
            ),
            if (!_isBreak) ...[
              const SizedBox(height: 4),
              DropdownButtonFormField<String?>(
                initialValue: _domainCode,
                decoration: const InputDecoration(labelText: 'Domaine du référentiel'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Aucun (pas de génération)')),
                  ...domainCodes.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: (v) => setState(() => _domainCode = v),
              ),
              const SizedBox(height: 12),
              Text('Groupe', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              SegmentedButton<String?>(
                segments: const [
                  ButtonSegment(value: null, label: Text('Classe entière')),
                  ButtonSegment(value: 'A', label: Text('Groupe A')),
                  ButtonSegment(value: 'B', label: Text('Groupe B')),
                ],
                selected: {_groupLabel},
                onSelectionChanged: (s) => setState(() => _groupLabel = s.first),
              ),
              const SizedBox(height: 12),
              Text('Enseigné par', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'me', label: Text('Moi')),
                  ButtonSegment(value: 'specialist', label: Text('Spécialiste')),
                ],
                selected: {_taughtBy},
                onSelectionChanged: (s) => setState(() => _taughtBy = s.first),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                if (widget.slot != null)
                  TextButton(
                    onPressed: _saving ? null : _delete,
                    style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                    child: const Text('Supprimer'),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Enregistrer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
