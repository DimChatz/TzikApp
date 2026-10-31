import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/proposal_sender.dart';
import '../widgets/gradient_background.dart';
import '../widgets/same_size_text.dart';

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
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!_sender.isConfigured) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.sendingNotSetUp)));
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
      messenger.showSnackBar(SnackBar(content: Text(l10n.proposalSent)));
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
                ? l10n.sendingRejected(e.statusCode)
                : l10n.sendingOffline,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return GradientScaffold(
      appBar: AppBar(title: Text(l10n.proposeQuestion)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SameSizeText(
                (l10n) => l10n.proposeIntro,
                style: theme.textTheme.bodyLarge,
                alignment: AlignmentDirectional.topStart,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _question,
                enabled: !_sending,
                minLines: 3,
                maxLines: 8,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.yourQuestion,
                  hintText: l10n.questionHint,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => (value ?? '').trim().length < 10
                    ? l10n.questionTooShort
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                enabled: !_sending,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.yourName,
                  border: const OutlineInputBorder(),
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
                label: SameSizeText(
                  (l10n) => _sending ? l10n.sending : l10n.send,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
