import 'package:flutter/material.dart';

import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

enum ReportUiState { idle, loading, success, empty, error }

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();

  String _category = 'Appointment Issue';
  String _priority = 'Normal';
  ReportUiState _uiState = ReportUiState.idle;
  bool _simulateFailure = false;
  final List<String> _submittedReports = [];

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_uiState == ReportUiState.loading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _uiState = ReportUiState.loading);

    try {
      // Simulated asynchronous request; no backend or database is connected.
      await Future<void>.delayed(const Duration(seconds: 2));

      if (_simulateFailure) {
        throw Exception('Simulated submission failure');
      }
      if (!mounted) return;

      setState(() {
        _submittedReports.add(_titleController.text.trim());
        _uiState = ReportUiState.success;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _uiState = ReportUiState.error);
    }
  }

  void _startNewReport() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _titleController.clear();
    _detailsController.clear();
    setState(() {
      _category = 'Appointment Issue';
      _priority = 'Normal';
      _simulateFailure = false;
      _uiState = ReportUiState.idle;
    });
  }

  void _showEmptyState() {
    setState(() => _uiState = _submittedReports.isEmpty
        ? ReportUiState.empty
        : ReportUiState.idle);
  }

  Widget _buildStateMessage({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required Widget action,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: color),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            action,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (_uiState) {
      case ReportUiState.loading:
        content = _buildStateMessage(
          icon: Icons.hourglass_top,
          color: Colors.blue,
          title: 'Submitting report...',
          message: 'Please wait while the simulated request is processing.',
          action: const CircularProgressIndicator(),
        );
        break;
      case ReportUiState.success:
        content = _buildStateMessage(
          icon: Icons.check_circle_outline,
          color: Colors.green,
          title: 'Report submitted successfully',
          message: 'Your report was accepted by this demo. It was not saved '
              'to a database.',
          action: AppButton(
            label: 'Submit Another Report',
            icon: Icons.add,
            onPressed: _startNewReport,
          ),
        );
        break;
      case ReportUiState.empty:
        content = _buildStateMessage(
          icon: Icons.inbox_outlined,
          color: Colors.blueGrey,
          title: 'No reports available',
          message: 'There are no report records to display yet.',
          action: AppButton(
            label: 'Create a Report',
            icon: Icons.add,
            onPressed: _startNewReport,
          ),
        );
        break;
      case ReportUiState.error:
        content = _buildStateMessage(
          icon: Icons.error_outline,
          color: Colors.red,
          title: 'Could not submit report',
          message: 'A simulated error occurred. Check the form and try again. '
              'Use Retry to run the request again.',
          action: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: 'Retry',
                icon: Icons.refresh,
                onPressed: () {
                  setState(() => _simulateFailure = false);
                  _submitReport();
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _uiState = ReportUiState.idle),
                child: const Text('Return to Form'),
              ),
            ],
          ),
        );
        break;
      case ReportUiState.idle:
        content = _buildForm();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Form'),
        actions: [
          TextButton.icon(
            onPressed: _uiState == ReportUiState.loading ? null : _showEmptyState,
            icon: const Icon(Icons.inbox_outlined),
            label: const Text('View Reports'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.assignment_outlined, size: 56, color: Colors.teal),
              const SizedBox(height: 12),
              Text(
                'Submit a Report',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Report an issue or share feedback about the SimpleCare '
                'appointment system.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _nameController,
                label: 'Your Name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _titleController,
                label: 'Report Title',
                hintText: 'Briefly describe the issue',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a report title.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Report Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'Appointment Issue', child: Text('Appointment Issue')),
                  DropdownMenuItem(value: 'Technical Problem', child: Text('Technical Problem')),
                  DropdownMenuItem(value: 'Incorrect Information', child: Text('Incorrect Information')),
                  DropdownMenuItem(value: 'Feedback or Suggestion', child: Text('Feedback or Suggestion')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'Low', child: Text('Low')),
                  DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'High', child: Text('High')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value);
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _detailsController,
                label: 'Report Details',
                hintText: 'Describe the issue or feedback...',
                prefixIcon: Icons.description_outlined,
                minLines: 4,
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe your report.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Simulate submission error'),
                subtitle: const Text('Turn this on to demonstrate the Error state.'),
                value: _simulateFailure,
                onChanged: (value) => setState(() => _simulateFailure = value),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Submit Report',
                icon: Icons.send,
                onPressed: _submitReport,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
