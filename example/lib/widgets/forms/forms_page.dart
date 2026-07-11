import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../shared/doc_widgets.dart';
import 'forms_state.dart';

/// Live documentation for Monokit's form and selection components.
class FormsPage extends StatefulWidget {
  const FormsPage({super.key});

  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  final FormsState _state = FormsState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormsScope(
      state: _state,
      child: Builder(builder: _buildBody),
    );
  }

  Widget _buildBody(BuildContext context) {
    final state = FormsScope.of(context);
    final theme = MonokitTheme.of(context);
    final workspaceHasError = state.workspaceName.trim().length < 3;

    void handleOtpCompleted(String value) {
      MonoScreen.of(context).overlays.showToast(
        MonoToast(
          variant: MonoAlertVariant.success,
          message: Text('Verification code $value received.'),
        ),
      );
    }

    return DocPageContent(
      children: <Widget>[
        const DocPageTitle(
          title: 'Forms and selection controls',
          description:
              'Every control below is live and controlled by this route. '
              'The examples pair input behavior with the field, label, and '
              'supporting-text primitives that make forms readable.',
        ),
        const DocGroupTitle('Field composition'),
        DocSection(
          name:
              'MonoField · MonoFieldSet · MonoFieldGroup · MonoFieldLegend · MonoFieldSeparator',
          description:
              'Compose labelled fields into a semantic fieldset. MonoField '
              'automatically applies MonoFieldLabel, MonoFieldDescription, '
              'and MonoFieldError to its corresponding slots.',
          code: r'''MonoFieldSet(
  legend: const Text('Workspace details'),
  child: MonoFieldGroup(
    children: [
      MonoField(
        required: true,
        label: const Text('Workspace name'),
        description: const Text('Used in project URLs.'),
        error: const Text('Use at least three characters.'),
        child: MonoInput(controller: controller),
      ),
      const MonoFieldSeparator(label: Text('Optional details')),
    ],
  ),
)''',
          child: MonoFieldSet(
            legend: const Text('Workspace details'),
            child: MonoFieldGroup(
              children: <Widget>[
                MonoField(
                  required: true,
                  label: const Text('Workspace name'),
                  description: const Text(
                    'Used in project URLs and invite links.',
                  ),
                  error: workspaceHasError
                      ? const Text('Use at least three characters.')
                      : null,
                  child: MonoInput(
                    controller: state.workspaceController,
                    placeholder: 'acme-studio',
                    onChanged: (value) => state.setWorkspaceName(value),
                  ),
                ),
                const MonoFieldSeparator(
                  label: Text('Optional project details'),
                ),
                const MonoFieldLabel(
                  required: true,
                  child: Text('Field slot anatomy'),
                ),
                const MonoFieldDescription(
                  child: Text(
                    'Descriptions provide calm context before users act.',
                  ),
                ),
                const MonoFieldError(
                  child: Text(
                    'Errors are live regions and use the destructive token.',
                  ),
                ),
              ],
            ),
          ),
        ),
        DocSection(
          name: 'MonoInput · MonoTextarea',
          description:
              'EditableText-based controls use externally owned controllers '
              'here, so their values remain stable across live documentation '
              'rebuilds. The second field uses responsive label placement.',
          code: r'''MonoField(
  layout: MonoFieldLayout.responsive,
  label: const Text('Project brief'),
  child: MonoTextarea(controller: briefController),
)''',
          child: MonoFieldGroup(
            children: <Widget>[
              MonoField(
                label: const Text('Public workspace URL'),
                description: Text(
                  'Current value: ${state.publicUrl.isEmpty ? '—' : state.publicUrl}',
                ),
                child: MonoInput(
                  controller: state.urlController,
                  prefix: const MonoIcon(MonoIcons.arrowRight),
                  suffix: const MonoBadge(
                    variant: MonoBadgeVariant.secondary,
                    size: MonoBadgeSize.sm,
                    child: Text('.mono'),
                  ),
                  onChanged: (value) => state.setPublicUrl(value),
                ),
              ),
              MonoField(
                layout: MonoFieldLayout.responsive,
                label: const Text('Project brief'),
                description: Text('${state.brief.length} characters'),
                child: MonoTextarea(
                  controller: state.briefController,
                  placeholder: 'Describe the project…',
                  onChanged: (value) => state.setBrief(value),
                ),
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonoInputOtp',
          description:
              'A controlled, keyboard-friendly OTP control handles paste, '
              'backspace, focus movement, and completion without Material '
              'text fields.',
          code: r'''MonoInputOtp(
  length: 6,
  value: otp,
  controlled: true,
  onChanged: (value) => setState(() => otp = value),
  onCompleted: verify,
)''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MonoInputOtp(
                length: 6,
                value: state.otp,
                controlled: true,
                onChanged: (value) => state.setOtp(value),
                onCompleted: handleOtpCompleted,
              ),
              SizedBox(height: theme.spacing.md),
              MonoProgress(value: state.otp.length / 6),
              SizedBox(height: theme.spacing.xs),
              Text(
                state.otp.isEmpty
                    ? 'Enter or paste a six-digit code.'
                    : '${state.otp.length} of 6 digits entered.',
                style: theme.typography.labelMedium.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        const DocGroupTitle('Boolean and exclusive choices'),
        DocSection(
          name: 'MonoCheckbox · MonoSwitch',
          description:
              'Checkboxes support normal and indeterminate states; switches '
              'provide a compact binary preference with the same focus and '
              'keyboard behavior.',
          code: r'''MonoCheckbox(
  value: reviewState,
  tristate: true,
  onChanged: (value) => setState(() => reviewState = value),
)

MonoSwitch(
  value: compactNavigation,
  onChanged: (value) => setState(() => compactNavigation = value),
)''',
          child: MonoFieldGroup(
            children: <Widget>[
              MonoCheckbox(
                value: state.sendUpdates,
                onChanged: (value) => state.setSendUpdates(value ?? false),
                label: const Text('Send monthly product updates'),
                description: const Text(
                  'Release notes and design-system news.',
                ),
              ),
              MonoCheckbox(
                value: state.reviewState,
                tristate: true,
                onChanged: (value) => state.setReviewState(value),
                label: const Text('Review completion'),
                description: Text(switch (state.reviewState) {
                  true => 'Complete',
                  false => 'Not started',
                  null => 'Partially complete',
                }),
              ),
              MonoSwitch(
                value: state.compactNavigation,
                onChanged: (value) => state.setCompactNavigation(value),
                label: const Text('Use compact navigation'),
                description: const Text(
                  'Demonstrates a controlled binary preference.',
                ),
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonoRadioGroup · MonoRadioOption · MonoRadio',
          description:
              'Use MonoRadioGroup.options for data-driven sets, or place '
              'standalone MonoRadio widgets beside a shared groupValue when '
              'the layout needs custom composition.',
          code: r'''MonoRadioGroup<String>(
  value: plan,
  onChanged: (value) => setState(() => plan = value!),
  options: const [
    MonoRadioOption(value: 'starter', label: Text('Starter')),
    MonoRadioOption(value: 'team', label: Text('Team')),
  ],
)''',
          child: MonoFieldGroup(
            children: <Widget>[
              MonoRadioGroup<String>(
                value: state.plan,
                onChanged: (value) {
                  if (value != null) {
                    state.setPlan(value);
                  }
                },
                options: const <MonoRadioOption<String>>[
                  MonoRadioOption<String>(
                    value: 'starter',
                    label: Text('Starter'),
                    description: Text('For a personal prototype.'),
                  ),
                  MonoRadioOption<String>(
                    value: 'team',
                    label: Text('Team'),
                    description: Text('For an active product group.'),
                  ),
                  MonoRadioOption<String>(
                    value: 'enterprise',
                    label: Text('Enterprise'),
                    description: Text('For governed organization workspaces.'),
                  ),
                ],
              ),
              const MonoFieldSeparator(label: Text('Standalone radios')),
              MonoRadio<String>(
                value: 'daily',
                groupValue: state.digest,
                onChanged: state.selectDigest,
                label: const Text('Daily digest'),
              ),
              MonoRadio<String>(
                value: 'weekly',
                groupValue: state.digest,
                onChanged: state.selectDigest,
                label: const Text('Weekly digest'),
              ),
              MonoRadio<String>(
                value: 'never',
                groupValue: state.digest,
                onChanged: state.selectDigest,
                label: const Text('No digest'),
              ),
            ],
          ),
        ),
        const DocGroupTitle('Anchored choices'),
        DocSection(
          name: 'MonoSelect · MonoSelectOption',
          description:
              'A compact controlled select with unique option values. It '
              'opens an anchored overlay and supports keyboard navigation.',
          code: r'''MonoSelect<String>(
  value: region,
  onChanged: (value) => setState(() => region = value ?? 'eu'),
  options: const [
    MonoSelectOption(value: 'eu', label: Text('Europe')),
    MonoSelectOption(value: 'us', label: Text('United States')),
  ],
)''',
          child: MonoField(
            label: const Text('Primary region'),
            description: const Text(
              'The selected value is controlled by the documentation screen.',
            ),
            child: MonoSelect<String>(
              value: state.region,
              onChanged: (value) => state.setRegion(value ?? 'eu'),
              options: const <MonoSelectOption<String>>[
                MonoSelectOption<String>(
                  value: 'eu',
                  label: Text('Europe'),
                  description: Text('Frankfurt'),
                ),
                MonoSelectOption<String>(
                  value: 'us',
                  label: Text('United States'),
                  description: Text('Virginia'),
                ),
                MonoSelectOption<String>(
                  value: 'apac',
                  label: Text('Asia Pacific'),
                  description: Text('Singapore'),
                ),
              ],
            ),
          ),
        ),
        DocSection(
          name: 'MonoCombobox · MonoComboboxOption',
          description:
              'A searchable, controlled alternative to select. Type in the '
              'overlay to filter the uniquely identified options.',
          code: r'''MonoCombobox<String>(
  value: framework,
  onChanged: (value) => setState(() => framework = value ?? 'flutter'),
  options: const [
    MonoComboboxOption(value: 'flutter', label: Text('Flutter')),
    MonoComboboxOption(value: 'react', label: Text('React')),
  ],
)''',
          child: MonoField(
            label: const Text('Implementation target'),
            description: const Text(
              'Search for a framework, then select it with pointer or keyboard input.',
            ),
            child: MonoCombobox<String>(
              value: state.framework,
              onChanged: (value) => state.setFramework(value ?? 'flutter'),
              options: const <MonoComboboxOption<String>>[
                MonoComboboxOption<String>(
                  value: 'flutter',
                  label: Text('Flutter'),
                  description: Text('Widgets-first mobile and web UI.'),
                  searchText: 'flutter dart mobile web',
                ),
                MonoComboboxOption<String>(
                  value: 'react',
                  label: Text('React'),
                  description: Text('Component-based web UI.'),
                  searchText: 'react javascript web',
                ),
                MonoComboboxOption<String>(
                  value: 'swiftui',
                  label: Text('SwiftUI'),
                  description: Text('Declarative Apple-platform UI.'),
                  searchText: 'swiftui ios macos apple',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
