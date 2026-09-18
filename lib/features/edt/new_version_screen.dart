import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/result/result.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'edt_providers.dart';

const _dayLabels = {1: 'Lundi', 2: 'Mardi', 3: 'Mercredi', 4: 'Jeudi', 5: 'Vendredi'};

class _LocalSlot {
  _LocalSlot({
    required this.dayOfWeek,
    required this.start,
    required this.end,
    required this.subjectLabel,
    this.domainCode,
    this.groupLabel,
    this.taughtBy = 'me',
    this.isBreak = false,
  });

  int dayOfWeek;
  TimeOfDay start;
  TimeOfDay end;
  String subjectLabel;
  String? domainCode;
  String? groupLabel;
  String taughtBy;
  bool isBreak;

  Map<String, dynamic> toJson() => {
        'day_of_week': dayOfWeek,
        'start_time': '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}:00',
        'end_time': '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}:00',
        'subject_label': subjectLabel,
        'domain_code': isBreak ? null : domainCode,
        'group_label': groupLabel,
        'taught_by': taughtBy,
        'is_break': isBreak,
      };
}

/// Duplique la version en vigueur, laisse Sandra la modifier localement (rien
/// n'est écrit tant qu'elle n'a pas confirmé), puis crée la nouvelle version
/// en un seul appel — `create_schedule_version` s'occupe du contrôle de
/// chevauchement et de la réconciliation des séances déjà prévues (§3.5).
class NewVersionScreen extends ConsumerStatefulWidget {
  const NewVersionScreen({super.key});

  @override
  ConsumerState<NewVersionScreen> createState() => _NewVersionScreenState();
}

class _NewVersionScreenState extends ConsumerState<NewVersionScreen> {
  DateTime? _validFrom;
  final _labelController = TextEditingController();
  List<_LocalSlot>? _slots;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _initFromCurrent(List<dynamic> currentSlots) {
    if (_slots != null) return;
    _slots = currentSlots.map((s) {
      return _LocalSlot(
        dayOfWeek: s.dayOfWeek as int,
        start: _parseTime(s.startTime as String),
        end: _parseTime(s.endTime as String),
        subjectLabel: s.subjectLabel as String,
        domainCode: s.domainCode as String?,
        groupLabel: s.groupLabel as String?,
        taughtBy: s.taughtBy as String,
        isBreak: s.isBreak as bool,
      );
    }).toList();
  }

  static TimeOfDay _parseTime(String hhmmss) {
    final parts = hhmmss.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _validFrom = picked);
  }

  Future<void> _addOrEditSlot({required int day, _LocalSlot? existing}) async {
    final result = await showDialog<_LocalSlot>(
      context: context,
      builder: (context) => _LocalSlotDialog(day: day, initial: existing),
    );
    if (result == null) return;
    setState(() {
      if (existing != null) {
        final i = _slots!.indexOf(existing);
        _slots![i] = result;
      } else {
        _slots!.add(result);
      }
    });
  }

  Future<void> _confirm() async {
    if (_validFrom == null) {
      setState(() => _error = 'Choisissez la date d\'entrée en vigueur.');
      return;
    }
    if (_labelController.text.trim().isEmpty) {
      setState(() => _error = 'Donnez un nom à cette version (ex. « EDT à partir de janvier »).');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final classId = await ref.read(currentClassIdProvider.future);
      await ref.read(edtRepositoryProvider).createVersion(
            classId: classId,
            validFrom: _validFrom!,
            label: _labelController.text.trim(),
            slots: _slots!.map((s) => s.toJson()).toList(),
          );
      ref.invalidate(currentVersionProvider);
      ref.invalidate(currentSlotsProvider);
      ref.invalidate(entriesToRelocateProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nouvelle version de l\'emploi du temps créée.')),
      );
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Échec : $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotsAsync = ref.watch(currentSlotsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle version de l\'EDT')),
      body: slotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (currentSlots) {
          _initFromCurrent(currentSlots);
          final slots = _slots!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _labelController,
                      decoration: const InputDecoration(labelText: 'Nom de cette version'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        _validFrom == null
                            ? 'Choisir la date d\'entrée en vigueur'
                            : 'En vigueur à partir du ${DateFormat('dd/MM/yyyy').format(_validFrom!)}',
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [1, 2, 3, 4, 5].expand((day) {
                    final daySlots = slots.where((s) => s.dayOfWeek == day).toList()
                      ..sort((a, b) => (a.start.hour * 60 + a.start.minute)
                          .compareTo(b.start.hour * 60 + b.start.minute));
                    return [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(_dayLabels[day]!, style: Theme.of(context).textTheme.titleSmall),
                      ),
                      ...daySlots.map((s) => Card(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: ListTile(
                              dense: true,
                              onTap: () => _addOrEditSlot(day: day, existing: s),
                              leading: Container(
                                width: 4,
                                color: s.isBreak
                                    ? AppColors.masteryNonVu
                                    : subjectColorFor(s.subjectLabel).color,
                              ),
                              title: Text(s.subjectLabel),
                              subtitle: Text(
                                '${s.start.format(context)}–${s.end.format(context)}'
                                '${s.groupLabel != null ? ' · Groupe ${s.groupLabel}' : ''}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => setState(() => slots.remove(s)),
                              ),
                            ),
                          )),
                      OutlinedButton.icon(
                        onPressed: () => _addOrEditSlot(day: day),
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter un créneau'),
                      ),
                      const SizedBox(height: 16),
                    ];
                  }).toList(),
                ),
              ),
              // Pas de SafeArea seule : cet écran est empilé dans le
              // Navigator de l'onglet Journal/EDT, donc affiché derrière la
              // barre de navigation flottante de l'app — SafeArea ne protège
              // que des marges système, pas de cette barre (voir
              // AppSpacing.bottomNavClearance).
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, AppSpacing.bottomNavClearance),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _confirm,
                      child: _saving
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Créer cette version'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LocalSlotDialog extends StatefulWidget {
  const _LocalSlotDialog({required this.day, this.initial});

  final int day;
  final _LocalSlot? initial;

  @override
  State<_LocalSlotDialog> createState() => _LocalSlotDialogState();
}

class _LocalSlotDialogState extends State<_LocalSlotDialog> {
  late final TextEditingController _subjectController;
  late TimeOfDay _start;
  late TimeOfDay _end;
  String? _groupLabel;
  String _taughtBy = 'me';
  bool _isBreak = false;

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    _subjectController = TextEditingController(text: s?.subjectLabel ?? '');
    _start = s?.start ?? const TimeOfDay(hour: 8, minute: 30);
    _end = s?.end ?? const TimeOfDay(hour: 9, minute: 0);
    _groupLabel = s?.groupLabel;
    _taughtBy = s?.taughtBy ?? 'me';
    _isBreak = s?.isBreak ?? false;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Ajouter un créneau' : 'Modifier le créneau'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Matière'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showTimePicker(context: context, initialTime: _start);
                      if (picked != null) setState(() => _start = picked);
                    },
                    child: Text(_start.format(context)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showTimePicker(context: context, initialTime: _end);
                      if (picked != null) setState(() => _end = picked);
                    },
                    child: Text(_end.format(context)),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pause'),
              value: _isBreak,
              onChanged: (v) => setState(() => _isBreak = v),
            ),
            if (!_isBreak)
              SegmentedButton<String?>(
                segments: const [
                  ButtonSegment(value: null, label: Text('Classe')),
                  ButtonSegment(value: 'A', label: Text('A')),
                  ButtonSegment(value: 'B', label: Text('B')),
                ],
                selected: {_groupLabel},
                onSelectionChanged: (s) => setState(() => _groupLabel = s.first),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: () {
            if (_subjectController.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              _LocalSlot(
                dayOfWeek: widget.day,
                start: _start,
                end: _end,
                subjectLabel: _subjectController.text.trim(),
                domainCode: widget.initial?.domainCode,
                groupLabel: _groupLabel,
                taughtBy: _taughtBy,
                isBreak: _isBreak,
              ),
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
