import 'package:monokit/monokit.dart';

import 'scenario_kit.dart';

enum _PostState { draft, publishing, posted }

class CreatorStudioScenario extends StatefulWidget {
  const CreatorStudioScenario({super.key});

  @override
  State<CreatorStudioScenario> createState() => _CreatorStudioScenarioState();
}

class _CreatorStudioScenarioState extends State<CreatorStudioScenario> {
  _PostState _state = _PostState.draft;

  void _publish() {
    setState(() => _state = _PostState.publishing);
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    // Advance the fake lifecycle on rebuild when publishing.
    if (_state == _PostState.publishing) {
      Future<void>.delayed(const Duration(milliseconds: 1200), () {
        if (mounted && _state == _PostState.publishing) {
          setState(() => _state = _PostState.posted);
        }
      });
    }
    return ScenarioShell(
      title: 'New post',
      actions: <Widget>[
        if (_state == _PostState.posted)
          const MonoBadge(
            variant: MonoBadgeVariant.success,
            child: Text('Posted'),
          )
        else if (_state == _PostState.publishing)
          const MonoBadge(
            variant: MonoBadgeVariant.info,
            child: Text('Publishing'),
          )
        else
          const MonoBadge(
            variant: MonoBadgeVariant.warning,
            child: Text('Draft'),
          ),
      ],
      body: ListView(
        padding: EdgeInsets.all(theme.spacing.lg),
        children: <Widget>[
          Row(
            children: <Widget>[
              const MonoAvatar.initials('YB'),
              SizedBox(width: theme.spacing.sm),
              Text('Yaa Boateng', style: theme.typography.labelLarge),
            ],
          ),
          SizedBox(height: theme.spacing.md),
          const MonoTextarea(
            placeholder:
                'What are you selling? e.g. Clean iPhone 13, 128GB, GH₵ 4800, meet at Nima…',
            minLines: 4,
            maxLines: 8,
          ),
          SizedBox(height: theme.spacing.md),
          const ScenarioLabel('Extracted facts'),
          Wrap(
            spacing: theme.spacing.sm,
            runSpacing: theme.spacing.sm,
            children: const <Widget>[
              MonoBadge(variant: MonoBadgeVariant.secondary, child: Text('iPhone 13')),
              MonoBadge(variant: MonoBadgeVariant.secondary, child: Text('128GB')),
              MonoBadge(variant: MonoBadgeVariant.secondary, child: Text('GH₵ 4,800')),
              MonoBadge(variant: MonoBadgeVariant.secondary, child: Text('Nima')),
            ],
          ),
          SizedBox(height: theme.spacing.lg),
          MonoAlert(
            variant: _state == _PostState.posted
                ? MonoAlertVariant.success
                : MonoAlertVariant.info,
            title: Text(
              _state == _PostState.posted
                  ? 'Posted to people near Nima'
                  : 'Reaches people near Nima first',
            ),
            description: const Text(
              'No followers needed — Monokit routes your post to relevant nearby '
              'people.',
            ),
          ),
          SizedBox(height: theme.spacing.md),
          Row(
            children: <Widget>[
              MonoButton(
                variant: MonoButtonVariant.ghost,
                onPressed: () {},
                leading: const MonoIcon(MonoIcons.image, size: 16),
                child: const Text('Add photos'),
              ),
            ],
          ),
        ],
      ),
      bottom: MonoButton(
        onPressed: _state == _PostState.draft ? _publish : null,
        isLoading: _state == _PostState.publishing,
        leading: _state == _PostState.posted
            ? const MonoIcon(MonoIcons.check, size: 16)
            : const MonoIcon(MonoIcons.send, size: 16),
        child: Text(
          switch (_state) {
            _PostState.draft => 'Publish',
            _PostState.publishing => 'Publishing…',
            _PostState.posted => 'Posted',
          },
        ),
      ),
    );
  }
}
