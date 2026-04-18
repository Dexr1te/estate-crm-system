import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:real_estate_crm/core/services/api_service.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';
import 'package:real_estate_crm/features/widgets/shared_widgets.dart';
import 'meetings_bloc.dart';

class MeetingFormScreen extends StatefulWidget {
  final int? meetingId;
  const MeetingFormScreen({super.key, this.meetingId});
  bool get isEditing => meetingId != null;
  @override
  State<MeetingFormScreen> createState() => _MeetingFormScreenState();
}

class _MeetingFormScreenState extends State<MeetingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _agentIdCtrl = TextEditingController();
  final _clientIdCtrl = TextEditingController();
  final _dealIdCtrl = TextEditingController();
  DateTime? _scheduledAt;
  bool _loading = false, _initLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _load();
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl,
      _descCtrl,
      _locationCtrl,
      _agentIdCtrl,
      _clientIdCtrl,
      _dealIdCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _initLoading = true);
    try {
      final m = await ApiService().getMeeting(widget.meetingId!);
      _titleCtrl.text = m.title;
      _descCtrl.text = m.description ?? '';
      _locationCtrl.text = m.location ?? '';
      _agentIdCtrl.text = m.agentId.toString();
      _clientIdCtrl.text = m.clientId.toString();
      _dealIdCtrl.text = m.dealId?.toString() ?? '';
      setState(() {
        _scheduledAt = m.scheduledAt;
        _initLoading = false;
      });
    } catch (_) {
      setState(() => _initLoading = false);
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
        context: context,
        initialDate:
            _scheduledAt ?? DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date == null || !mounted) return;
    final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledAt ?? DateTime.now()));
    if (time == null) return;
    setState(() => _scheduledAt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_scheduledAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date and time')));
      return;
    }
    setState(() => _loading = true);
    final data = {
      'title': _titleCtrl.text.trim(),
      'scheduledAt': _scheduledAt!.toIso8601String(),
      'agentId': int.parse(_agentIdCtrl.text.trim()),
      'clientId': int.parse(_clientIdCtrl.text.trim()),
      if (_descCtrl.text.trim().isNotEmpty)
        'description': _descCtrl.text.trim(),
      if (_locationCtrl.text.trim().isNotEmpty)
        'location': _locationCtrl.text.trim(),
      if (_dealIdCtrl.text.trim().isNotEmpty)
        'dealId': int.parse(_dealIdCtrl.text.trim()),
    };
    if (widget.isEditing) {
      context
          .read<MeetingsBloc>()
          .add(MeetingsUpdateEvent(widget.meetingId!, data));
    } else {
      context.read<MeetingsBloc>().add(MeetingsCreateEvent(data));
    }
    context.go('/meetings');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Meeting' : 'Schedule Meeting')),
      body: _initLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _f(_titleCtrl, 'Title *', Icons.title, req: true),
                        const SizedBox(height: 12),
                        _f(_clientIdCtrl, 'Client ID *', Icons.person_outline,
                            req: true, num: true),
                        const SizedBox(height: 12),
                        _f(_agentIdCtrl, 'Agent ID *',
                            Icons.support_agent_outlined,
                            req: true, num: true),
                        const SizedBox(height: 12),
                        _f(_dealIdCtrl, 'Deal ID (optional)',
                            Icons.handshake_outlined,
                            num: true),
                        const SizedBox(height: 12),
                        _f(_locationCtrl, 'Location',
                            Icons.location_on_outlined),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _pickDateTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE8ECF4))),
                            child: Row(children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 20, color: AppColors.textSecondary),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(
                                      _scheduledAt != null
                                          ? DateFormat('MMM d, yyyy • h:mm a')
                                              .format(_scheduledAt!)
                                          : 'Select date & time *',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: _scheduledAt != null
                                              ? AppColors.textPrimary
                                              : AppColors.textHint))),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.textHint, size: 20),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                            controller: _descCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                                labelText: 'Description',
                                prefixIcon:
                                    Icon(Icons.notes_outlined, size: 20))),
                        const SizedBox(height: 32),
                        ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : Text(widget.isEditing
                                    ? 'Update Meeting'
                                    : 'Schedule Meeting')),
                        const SizedBox(height: 12),
                        OutlinedButton(
                            onPressed: () => context.pop(),
                            style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52)),
                            child: const Text('Cancel')),
                      ]))),
    );
  }

  Widget _f(TextEditingController c, String label, IconData icon,
          {bool req = false, bool num = false}) =>
      TextFormField(
        controller: c,
        keyboardType: num ? TextInputType.number : TextInputType.text,
        decoration:
            InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20)),
        validator: req
            ? (v) => v == null || v.isEmpty ? '$label is required' : null
            : null,
      );
}
