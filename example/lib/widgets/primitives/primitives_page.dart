import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../shared/doc_widgets.dart';
import 'primitives_state.dart';

/// Documents non-Material interaction primitives and public programmatic APIs.
class PrimitivesPage extends StatefulWidget {
  const PrimitivesPage({super.key});

  @override
  State<PrimitivesPage> createState() => _PrimitivesPageState();
}

class _PrimitivesPageState extends State<PrimitivesPage> {
  final PrimitivesState _state = PrimitivesState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimitivesScope(
      state: _state,
      child: Builder(builder: _buildBody),
    );
  }

  Widget _buildBody(BuildContext context) {
    final demoState = PrimitivesScope.of(
      context,
    ); // rebuilds this subtree when state notifies
    final theme = MonokitTheme.of(context);
    final stateText = MonoStateProperty<String>(
      (states) => states.isEmpty
          ? 'No manual state'
          : states.map((state) => state.name).join(', '),
    ).resolve(demoState.states.states);
    final buttonStyle = const MonoButtonStyleResolver().resolve(
      theme: theme,
      variant: MonoButtonVariant.primary,
      size: MonoButtonSize.md,
      states: demoState.states.states,
    );

    return DocPageContent(
      children: <Widget>[
        const DocPageTitle(
          title: 'Interaction primitives',
          description:
              'These low-level APIs make component styling, focus treatment, state resolution, and screen-owned overlays consistent without Material dependencies.',
        ),
        DocSection(
          name: 'MonoState · MonoStatesController · MonoStateProperty',
          description:
              'Components resolve visual output from a set of semantic states. Toggle the controller below to inspect a state snapshot and resulting button resolver values.',
          code:
              'final states = MonoStatesController();\n'
              'states.update(MonoState.selected, true);\n'
              'final value = MonoStateProperty<String>(...).resolve(states.states);',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: theme.spacing.sm,
                runSpacing: theme.spacing.sm,
                children: <Widget>[
                  for (final state in <MonoState>[
                    MonoState.hovered,
                    MonoState.focused,
                    MonoState.pressed,
                    MonoState.selected,
                    MonoState.invalid,
                    MonoState.disabled,
                  ])
                    MonoButton(
                      size: MonoButtonSize.xs,
                      variant: demoState.states.contains(state)
                          ? MonoButtonVariant.primary
                          : MonoButtonVariant.outline,
                      onPressed: () => demoState.toggleState(state),
                      child: Text(state.name),
                    ),
                ],
              ),
              SizedBox(height: theme.spacing.md),
              MonoBadge(
                variant: MonoBadgeVariant.outline,
                child: Text(stateText),
              ),
              SizedBox(height: theme.spacing.sm),
              Text(
                'Resolved button opacity ${buttonStyle.opacity.toStringAsFixed(2)} · '
                'min height ${buttonStyle.minimumHeight.toStringAsFixed(0)}',
                style: theme.typography.labelMedium,
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonoPressable · MonoFocusRing',
          description:
              'MonoPressable provides pointer, keyboard, semantic, hover, and press behavior; set its expanded state when it controls disclosure. MonoFocusRing can be composed around any custom control.',
          code: '''MonoPressable(
  expanded: sidebarController.isOpen,
  onPressed: sidebarController.toggle,
  child: (context, states) => const Text('Toggle sidebar'),
)''',
          child: Wrap(
            spacing: theme.spacing.lg,
            runSpacing: theme.spacing.lg,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              MonoPressable(
                semanticLabel: 'Primitive press target',
                onPressed: () => MonoScreen.of(context).overlays.showToast(
                  const MonoToast(message: Text('MonoPressable activated.')),
                ),
                child: (context, states) => AnimatedContainer(
                  duration: theme.motion.fast,
                  padding: EdgeInsets.all(theme.spacing.md),
                  decoration: BoxDecoration(
                    color: states.contains(MonoState.pressed)
                        ? theme.colors.primary
                        : theme.colors.secondary,
                    borderRadius: BorderRadius.circular(theme.radii.md),
                  ),
                  child: Text(
                    'Pressable (${states.map((state) => state.name).join(', ')})',
                    style: theme.typography.button.copyWith(
                      color: states.contains(MonoState.pressed)
                          ? theme.colors.primaryForeground
                          : theme.colors.secondaryForeground,
                    ),
                  ),
                ),
              ),
              MonoFocusRing(
                focused: demoState.focusRing,
                child: MonoButton(
                  variant: MonoButtonVariant.outline,
                  onPressed: () => demoState.toggleFocusRing(),
                  child: Text(
                    demoState.focusRing ? 'Hide focus ring' : 'Show focus ring',
                  ),
                ),
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonoOverlayLayer · MonoOverlayController · MonoOverlayHandle',
          description:
              'MonoScreen owns the production overlay layer. This bounded example shows the same primitive API for custom local overlay compositions.',
          child: SizedBox(
            height: 128,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colors.background,
                    borderRadius: BorderRadius.circular(theme.radii.md),
                    border: Border.all(color: theme.colors.border),
                  ),
                  child: Center(
                    child: MonoButton(
                      variant: MonoButtonVariant.outline,
                      onPressed: demoState.showRawOverlay,
                      child: const Text('Show local overlay'),
                    ),
                  ),
                ),
                MonoOverlayLayer(controller: demoState.overlayController),
              ],
            ),
          ),
        ),
        DocSection(
          name: 'Style resolvers and optional Material adapter',
          description:
              'MonoButtonStyleResolver, MonoBadgeStyleResolver, and MonoBubbleStyleResolver expose resolved token styles for custom controls. The optional Material bridge is imported separately from package:monokit/material.dart.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Button foreground: ${buttonStyle.foreground.toARGB32().toRadixString(16)}',
              ),
              SizedBox(height: theme.spacing.sm),
              Text(
                'Use MonokitThemeExtension and MonokitMaterialAdapter only in hybrid applications; core widgets remain Material-free.',
                style: theme.typography.bodyMedium.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
