// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fx_account_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class FxAccountLocalizationsZh extends FxAccountLocalizations {
  FxAccountLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get changePasswordTitle => '修改密码';

  @override
  String get changePasswordDescription => '请输入当前密码和新密码';

  @override
  String get changePasswordOldHint => '请输入当前密码';

  @override
  String get changePasswordNewHint => '请输入新密码（至少6位）';

  @override
  String get confirm => '确认';

  @override
  String get deleteAccountTitle => '注销账号';

  @override
  String get deleteNoticeTitle => '注销须知';

  @override
  String get deleteProfileWarning => '账号信息和个人资料将被永久删除';

  @override
  String get deleteCloudWarning => '云端画板、资产及同步数据将无法再访问';

  @override
  String get deleteLoginWarning => '当前登录状态会立即失效，注销后无法恢复账号';

  @override
  String get deleteLocalFileNotice => '设备上的本地文件不会自动删除';

  @override
  String get verifyIdentityTitle => '验证身份';

  @override
  String get deletePasswordHelp => '请输入账号密码以确认由本人执行注销';

  @override
  String get currentPasswordHint => '输入当前密码';

  @override
  String get passwordEmpty => '密码不能为空';

  @override
  String get deleteRiskAccepted => '我已了解以上内容，并确认承担注销后果';

  @override
  String get deleteAcceptRiskFirst => '请先确认已了解注销风险';

  @override
  String get deleteConfirm => '确认注销';

  @override
  String get deleteIrreversible => '账号注销后不可恢复，请谨慎操作';

  @override
  String get deleteFinalTitle => '最后确认';

  @override
  String get deleteFinalContent => '确定永久注销当前账号吗？此操作无法撤销。';

  @override
  String get cancel => '取消';

  @override
  String get forgotPasswordTitle => '找回密码';

  @override
  String get forgotPasswordDescription => '验证账号绑定的邮箱，然后设置新的登录密码';

  @override
  String get recoveryEmailHint => '请输入绑定邮箱';

  @override
  String get recoveryCodeHint => '请输入邮箱验证码';

  @override
  String get recoveryNewPasswordHint => '请输入新密码（至少6位）';

  @override
  String get recoveryConfirmPasswordHint => '再次输入新密码';

  @override
  String get requestCode => '获取验证码';

  @override
  String get sendingCode => '发送中';

  @override
  String get codeSent => '验证码已发送';

  @override
  String get invalidRecoveryEmail => '请输入正确的邮箱地址';

  @override
  String get passwordsDoNotMatch => '两次输入的密码不一致';

  @override
  String get resetPassword => '重置密码';

  @override
  String get forgotPasswordAction => '忘记密码，立即找回？';

  @override
  String get bindEmailTitle => '绑定邮箱';

  @override
  String get changeEmailTitle => '更换邮箱';

  @override
  String get bindEmailDescription => '绑定邮箱后，可用于登录和找回密码';

  @override
  String currentEmail(String email) {
    return '当前邮箱：$email';
  }

  @override
  String get bindEmailHint => '请输入要绑定的邮箱';

  @override
  String get confirmBinding => '确认绑定';

  @override
  String get emailBoundSuccess => '邮箱绑定成功';

  @override
  String get emailAlreadyBound => '该邮箱已被其他账号绑定';

  @override
  String get bindPhoneTitle => '绑定手机号';

  @override
  String get changePhoneTitle => '更换手机号';

  @override
  String get bindPhoneDescription => '绑定手机号后，可用于登录和安全验证';

  @override
  String currentPhone(String phone) {
    return '当前手机号：$phone';
  }

  @override
  String get bindPhoneHint => '请输入要绑定的手机号';

  @override
  String get confirmPhoneBinding => '确认绑定';

  @override
  String get phoneBoundSuccess => '手机号绑定成功';

  @override
  String get phoneAlreadyBound => '该手机号已被其他账号绑定';

  @override
  String get invalidPhone => '请输入正确的手机号';

  @override
  String get passwordResetSuccess => '密码重置成功，请使用新密码登录';
}
