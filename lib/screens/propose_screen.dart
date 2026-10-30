import 'package:flutter/material.dart';

import '../services/proposal_sender.dart';
import '../widgets/gradient_background.dart';

class ProposeScreen extends StatefulWidget {
  const ProposeScreen({super.key, this.sender});

  /// Defaults to sending through Formspree; tests pass their own.
  final ProposalSender? sender;

  @override
  State<ProposeScreen> createState() => _ProposeScreenState();
}

class _ProposeScreenState extends State<ProposeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _question = TextEditingController();
  final _name = TextEditingController();
  late final _sender = widget.sender ?? ProposalSender();
  bool _sending = false;

  @override
  void dispose() {
    _question.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    if (!_sender.isConfigured) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            "Sending isn't set up yet: put your Formspree form ID in "
            'config.json and rebuild the app.',
          ),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    try {
      await _sender.send(
        question: _question.text.trim(),
        name: _name.text.trim(),
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Thanks! Your question was sent.')),
      );
      Navigator.of(context).pop();
    } on Exception catch (e) {
      debugPrint('Sending proposal failed: $e');
      if (!mounted) return;
      setState(() => _sending = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            // Formspree answering with an error isn't a connection problem.
            e is ProposalException
                ? "Couldn't send your question (error ${e.statusCode}). "
                      'Please try again later.'
                : "Couldn't send your question. Check your internet "
                      'connection and try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientScaffold(
      appBar: AppBar(title: const Text('Propose a question')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Got a great question or dilemma? Send it over and it might '
                'make it into the app.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _question,
                enabled: !_sending,
                minLines: 3,
                maxLines: 8,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Your question',
                  hintText: 'Would you rather...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value ?? '').trim().length < 10
                    ? 'Please write at least 10 characters.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                enabled: !_sending,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Your name (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _sending ? null : _send,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: _sending
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_sending ? 'Sending...' : 'Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
