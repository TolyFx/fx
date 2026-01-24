import 'upload_task.dart';
import 'toastable.dart';
import 'login_flow.dart';

class FxAbility {
  FxAbility._();
  static final FxAbility _instance = FxAbility._();
  factory FxAbility() => _instance;

  UploadTask? _uploadTask;
  Toastable? _toast;
  LoginFlow? _loginFlow;

  void registerUploadTask(UploadTask task) {
    _uploadTask = task;
  }

  void registerToast(Toastable toast) {
    _toast = toast;
  }

  void registerLoginFlow(LoginFlow loginFlow) {
    _loginFlow = loginFlow;
  }

  UploadTask get uploadTask {
    assert(_uploadTask != null, 'UploadTask not registered, Please call registerUploadTask first.');
    return _uploadTask!;
  }

  Toastable get toast {
    assert(_toast != null, 'Toast not registered, Please call registerToast first.');
    return _toast!;
  }

  LoginFlow get loginFlow {
    assert(_loginFlow != null, 'LoginFlow not registered, Please call registerLoginFlow first.');
    return _loginFlow!;
  }
}
