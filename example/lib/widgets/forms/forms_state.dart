import 'package:flutter/widgets.dart';

/// Demo state for the forms section.
class FormsState extends ChangeNotifier {
  FormsState() {
    workspaceController = TextEditingController(text: workspaceName);
    urlController = TextEditingController(text: publicUrl);
    briefController = TextEditingController(text: brief);
  }

  late final TextEditingController workspaceController;
  late final TextEditingController urlController;
  late final TextEditingController briefController;

  String workspaceName = 'aurora-studio';
  String publicUrl = 'aurora.monokit';
  String brief = 'Ship a focused, widgets-first workspace for the beta.';
  String otp = '';
  bool sendUpdates = true;
  bool? reviewState;
  bool compactNavigation = false;
  String plan = 'team';
  String digest = 'weekly';
  String region = 'eu';
  String framework = 'flutter';

  void setWorkspaceName(String value) {
    workspaceName = value;
    notifyListeners();
  }

  void setPublicUrl(String value) {
    publicUrl = value;
    notifyListeners();
  }

  void setBrief(String value) {
    brief = value;
    notifyListeners();
  }

  void setOtp(String value) {
    otp = value;
    notifyListeners();
  }

  void setSendUpdates(bool value) {
    sendUpdates = value;
    notifyListeners();
  }

  void setReviewState(bool? value) {
    reviewState = value;
    notifyListeners();
  }

  void setCompactNavigation(bool value) {
    compactNavigation = value;
    notifyListeners();
  }

  void setPlan(String value) {
    plan = value;
    notifyListeners();
  }

  void selectDigest(String? value) {
    if (value != null) {
      digest = value;
      notifyListeners();
    }
  }

  void setRegion(String value) {
    region = value;
    notifyListeners();
  }

  void setFramework(String value) {
    framework = value;
    notifyListeners();
  }

  @override
  void dispose() {
    workspaceController.dispose();
    urlController.dispose();
    briefController.dispose();
    super.dispose();
  }
}

class FormsScope extends InheritedNotifier<FormsState> {
  const FormsScope({super.key, required FormsState state, required super.child})
    : super(notifier: state);

  static FormsState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FormsScope>();
    assert(scope != null, 'No FormsScope found in context.');
    return scope!.notifier!;
  }
}
