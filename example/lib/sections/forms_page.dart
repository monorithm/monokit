import 'package:monokit/monokit.dart';

import '../kit/component_section.dart';
import '../kit/page_hero.dart';

class FormsPage extends StatefulWidget {
  const FormsPage({super.key});

  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _bio = TextEditingController();
  String? _plan = 'starter';
  String? _delivery = 'pickup';
  bool _notify = true;
  bool? _agree = false;
  bool _invalidName = false;

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        PageHero(
          eyebrow: 'Forms',
          title: 'Inputs & selection',
          tagline:
              'EditableText-based fields with selection handles and a copy/paste '
              'toolbar, plus checkboxes, radios, switches, selects, and OTP — '
              'validated live.',
          child: const _FormsHero(),
        ),
        const SectionDivider(),
        const StageBlock(
          title: 'A form that reflows',
          description:
              'One column on compact; two columns once there is room. The fields '
              'never overflow — labels wrap and inputs stretch.',
          stageHeight: 360,
          child: _ResponsiveForm(),
        ),
        const SectionDivider(),
        ComponentSection(
          title: 'Field, input & validation',
          widgetName: 'MonoField',
          description:
              'Label, description, and a live-region error. Press '
              'Continue with an empty name to see the invalid state.',
          code:
              "MonoField(\n  label: const Text('Display name'),\n  error: invalid ? const Text('Required') : null,\n  child: MonoInput(controller: name, invalid: invalid),\n)",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MonoField(
                label: const Text('Display name'),
                description: const Text('Shown on your posts.'),
                required: true,
                error: _invalidName ? const Text('Please enter a name.') : null,
                child: MonoInput(
                  controller: _name,
                  placeholder: 'e.g. Ama',
                  invalid: _invalidName,
                ),
              ),
              SizedBox(height: theme.spacing.md),
              MonoButton(
                onPressed: () =>
                    setState(() => _invalidName = _name.text.trim().isEmpty),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Textarea',
          widgetName: 'MonoTextarea',
          child: MonoField(
            label: const Text('About this item'),
            child: MonoTextarea(
              controller: _bio,
              placeholder: 'Condition, pickup area, anything useful…',
              minLines: 3,
              maxLines: 6,
              maxLength: 180,
              showCounter: true,
            ),
          ),
        ),
        ComponentSection(
          title: 'Checkbox & switch',
          widgetName: 'MonoCheckbox',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MonoCheckbox(
                value: _agree,
                onChanged: (v) => setState(() => _agree = v),
                label: const Text('I agree to the community guidelines'),
              ),
              SizedBox(height: theme.spacing.md),
              MonoSwitch(
                value: _notify,
                onChanged: (v) => setState(() => _notify = v),
                label: const Text('Notify me about strong matches'),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Radio group',
          widgetName: 'MonoRadioGroup',
          child: MonoRadioGroup<String>(
            value: _delivery,
            onChanged: (v) => setState(() => _delivery = v),
            options: const <MonoRadioOption<String>>[
              MonoRadioOption(value: 'pickup', label: Text('Pickup — free')),
              MonoRadioOption(
                value: 'delivery',
                label: Text('Delivery within Accra — GH₵ 20'),
              ),
              MonoRadioOption(value: 'meet', label: Text('Meet at a landmark')),
            ],
          ),
        ),
        ComponentSection(
          title: 'Select',
          widgetName: 'MonoSelect',
          code:
              "MonoSelect<String>(\n  value: plan,\n  onChanged: (v) => setPlan(v),\n  options: const [MonoSelectOption(value: 'starter', label: 'Starter')],\n)",
          child: SizedBox(
            width: 280,
            child: MonoSelect<String>(
              value: _plan,
              onChanged: (v) => setState(() => _plan = v),
              placeholder: 'Choose a plan',
              options: const <MonoSelectOption<String>>[
                MonoSelectOption(value: 'starter', label: Text('Starter')),
                MonoSelectOption(value: 'seller', label: Text('Seller')),
                MonoSelectOption(value: 'business', label: Text('Business')),
              ],
            ),
          ),
        ),
        ComponentSection(
          title: 'Combobox',
          widgetName: 'MonoCombobox',
          description: 'Searchable select — filters as you type.',
          child: SizedBox(
            width: 280,
            child: MonoCombobox<String>(
              defaultValue: 'accra',
              onChanged: (_) {},
              placeholder: 'Pick a city',
              searchPlaceholder: 'Search cities…',
              options: <MonoComboboxOption<String>>[
                MonoComboboxOption<String>.text(value: 'accra', label: 'Accra'),
                MonoComboboxOption<String>.text(
                  value: 'kumasi',
                  label: 'Kumasi',
                ),
                MonoComboboxOption<String>.text(
                  value: 'tamale',
                  label: 'Tamale',
                ),
                MonoComboboxOption<String>.text(
                  value: 'takoradi',
                  label: 'Takoradi',
                ),
              ],
            ),
          ),
        ),
        ComponentSection(
          title: 'One-time code',
          widgetName: 'MonoInputOtp',
          description: 'Tabular digits — 0/O and 1/l never blur.',
          child: MonoInputOtp(length: 6, onCompleted: (_) {}),
        ),
      ],
    );
  }
}

/// A composed, uncontrolled profile form for the hero.
class _FormsHero extends StatelessWidget {
  const _FormsHero();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Complete your profile', style: theme.typography.titleMedium),
        SizedBox(height: theme.spacing.lg),
        MonoField(
          label: const Text('Display name'),
          description: const Text('Shown on your posts.'),
          child: const MonoInput(placeholder: 'e.g. Ama'),
        ),
        SizedBox(height: theme.spacing.md),
        MonoField(
          label: const Text('Phone'),
          child: const MonoInput(placeholder: '024 000 0000'),
        ),
        SizedBox(height: theme.spacing.md),
        const MonoCheckbox(
          value: true,
          onChanged: null,
          label: Text('Notify me about strong matches'),
        ),
        SizedBox(height: theme.spacing.lg),
        MonoButton(onPressed: () {}, child: const Text('Save profile')),
      ],
    );
  }
}

/// A listing form that lays fields in one or two columns by width.
class _ResponsiveForm extends StatelessWidget {
  const _ResponsiveForm();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoCol = constraints.maxWidth >= theme.breakpoints.medium;
        final title = MonoField(
          label: const Text('Title'),
          child: const MonoInput(placeholder: 'Linen lounge chair'),
        );
        final price = MonoField(
          label: const Text('Price (GH₵)'),
          child: const MonoInput(placeholder: '4,800'),
        );
        final city = MonoField(
          label: const Text('City'),
          child: const MonoInput(placeholder: 'Accra'),
        );
        final condition = MonoField(
          label: const Text('Condition'),
          child: const MonoInput(placeholder: 'Like new'),
        );
        return SingleChildScrollView(
          padding: EdgeInsets.all(theme.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              title,
              SizedBox(height: theme.spacing.md),
              if (twoCol)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: price),
                    SizedBox(width: theme.spacing.lg),
                    Expanded(child: city),
                  ],
                )
              else ...<Widget>[price, SizedBox(height: theme.spacing.md), city],
              SizedBox(height: theme.spacing.md),
              condition,
              SizedBox(height: theme.spacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: IntrinsicWidth(
                  child: MonoButton(
                    onPressed: () {},
                    leading: const MonoIcon(MonoIcons.check, size: 16),
                    child: const Text('Publish listing'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
