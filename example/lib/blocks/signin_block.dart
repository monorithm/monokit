import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../kit/phase_ticker.dart';

/// Production-style block: phone + OTP sign-in. One phone number, then one code.
class SignInBlock extends StatefulWidget {
  const SignInBlock({super.key});

  @override
  State<SignInBlock> createState() => _SignInBlockState();
}

enum _Step { phone, otp }

class _SignInBlockState extends State<SignInBlock> {
  final PhaseTicker _phase = PhaseTicker();
  final TextEditingController _phone = TextEditingController();
  _Step _step = _Step.phone;

  @override
  void initState() {
    super.initState();
    _phase.addListener(_onPhase);
  }

  void _onPhase() {
    if (_phase.phase.isTerminalSuccess && _step == _Step.phone) {
      setState(() => _step = _Step.otp);
    }
  }

  @override
  void dispose() {
    _phase.removeListener(_onPhase);
    _phase.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoScreen(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(theme.spacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: MonoAvatar.initials('M'),
                ),
                SizedBox(height: theme.spacing.lg),
                Text('Welcome to Monorithm',
                    style: theme.typography.headlineMedium),
                SizedBox(height: theme.spacing.xs),
                Text(
                  'Post what you have or need. We route it to the right people '
                  'nearby.',
                  style: theme.typography.bodyMedium.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                SizedBox(height: theme.spacing.xxl),
                if (_step == _Step.phone) ...<Widget>[
                  MonoField(
                    label: const Text('Phone number'),
                    description: const Text('Ghana numbers only for now.'),
                    child: MonoInput(
                      controller: _phone,
                      placeholder: '024 000 0000',
                      keyboardType: TextInputType.phone,
                      autofillHints: const <String>[
                        AutofillHints.telephoneNumber,
                      ],
                    ),
                  ),
                  SizedBox(height: theme.spacing.lg),
                  ListenableBuilder(
                    listenable: _phase,
                    builder: (context, _) => MonoButton(
                      size: MonoButtonSize.lg,
                      isLoading: _phase.phase.isPending,
                      onPressed: _phase.phase.isPending ? null : _phase.start,
                      child: const Text('Send code'),
                    ),
                  ),
                ] else ...<Widget>[
                  Text(
                    'Enter the 6-digit code sent to '
                    '${_phone.text.isEmpty ? 'your phone' : _phone.text}',
                    style: theme.typography.bodyMedium,
                  ),
                  SizedBox(height: theme.spacing.lg),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: MonoInputOtp(length: 6, onCompleted: (_) {}),
                  ),
                  SizedBox(height: theme.spacing.md),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: MonoButton(
                      variant: MonoButtonVariant.link,
                      onPressed: () {},
                      child: const Text('Resend code'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
