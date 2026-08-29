// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fx_account_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FxAccountLocalizationsEn extends FxAccountLocalizations {
  FxAccountLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get changePasswordDescription =>
      'Enter your current password and a new password';

  @override
  String get changePasswordOldHint => 'Enter current password';

  @override
  String get changePasswordNewHint =>
      'Enter new password (at least 6 characters)';

  @override
  String get confirm => 'Confirm';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteNoticeTitle => 'Before You Delete';

  @override
  String get deleteProfileWarning =>
      'Your account information and profile will be permanently deleted';

  @override
  String get deleteCloudWarning =>
      'Cloud canvases, assets, and sync data will no longer be accessible';

  @override
  String get deleteLoginWarning =>
      'Your session ends immediately and the account cannot be restored';

  @override
  String get deleteLocalFileNotice =>
      'Local files on this device will not be deleted automatically';

  @override
  String get verifyIdentityTitle => 'Verify Your Identity';

  @override
  String get deletePasswordHelp =>
      'Enter your account password to confirm this is you';

  @override
  String get currentPasswordHint => 'Current password';

  @override
  String get passwordEmpty => 'Password cannot be empty';

  @override
  String get deleteRiskAccepted =>
      'I understand and accept the consequences of deleting my account';

  @override
  String get deleteAcceptRiskFirst =>
      'Please acknowledge the account deletion risks first';

  @override
  String get deleteConfirm => 'Delete Account';

  @override
  String get deleteIrreversible => 'Account deletion cannot be undone';

  @override
  String get deleteFinalTitle => 'Final Confirmation';

  @override
  String get deleteFinalContent =>
      'Permanently delete this account? This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordDescription =>
      'Verify the email linked to your account, then create a new password';

  @override
  String get recoveryEmailHint => 'Enter your account email';

  @override
  String get recoveryCodeHint => 'Enter verification code';

  @override
  String get recoveryNewPasswordHint => 'Enter a new password (6+ characters)';

  @override
  String get recoveryConfirmPasswordHint => 'Enter the new password again';

  @override
  String get requestCode => 'Get Code';

  @override
  String get sendingCode => 'Sending';

  @override
  String get codeSent => 'Verification code sent';

  @override
  String get invalidRecoveryEmail => 'Enter a valid email address';

  @override
  String get passwordsDoNotMatch => 'The passwords do not match';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get forgotPasswordAction => 'Forgot your password? Recover it now';

  @override
  String get bindEmailTitle => 'Bind Email';

  @override
  String get changeEmailTitle => 'Change Email';

  @override
  String get bindEmailDescription =>
      'Bind an email for login and password recovery';

  @override
  String currentEmail(String email) {
    return 'Current email: $email';
  }

  @override
  String get bindEmailHint => 'Enter the email to bind';

  @override
  String get confirmBinding => 'Bind Email';

  @override
  String get emailBoundSuccess => 'Email bound successfully';

  @override
  String get emailAlreadyBound =>
      'This email is already bound to another account';

  @override
  String get bindPhoneTitle => 'Bind Phone';

  @override
  String get changePhoneTitle => 'Change Phone';

  @override
  String get bindPhoneDescription =>
      'Bind a phone number for login and security verification';

  @override
  String currentPhone(String phone) {
    return 'Current phone: $phone';
  }

  @override
  String get bindPhoneHint => 'Enter the phone number to bind';

  @override
  String get confirmPhoneBinding => 'Bind Phone';

  @override
  String get phoneBoundSuccess => 'Phone number bound successfully';

  @override
  String get phoneAlreadyBound =>
      'This phone number is already bound to another account';

  @override
  String get invalidPhone => 'Enter a valid phone number';

  @override
  String get passwordResetSuccess =>
      'Password reset. Sign in with your new password';
}
