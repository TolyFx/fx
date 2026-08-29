import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'fx_account_localizations_en.dart';
import 'fx_account_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FxAccountLocalizations
/// returned by `FxAccountLocalizations.of(context)`.
///
/// Applications need to include `FxAccountLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/fx_account_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FxAccountLocalizations.localizationsDelegates,
///   supportedLocales: FxAccountLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the FxAccountLocalizations.supportedLocales
/// property.
abstract class FxAccountLocalizations {
  FxAccountLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FxAccountLocalizations? of(BuildContext context) {
    return Localizations.of<FxAccountLocalizations>(
        context, FxAccountLocalizations);
  }

  static const LocalizationsDelegate<FxAccountLocalizations> delegate =
      _FxAccountLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password and a new password'**
  String get changePasswordDescription;

  /// No description provided for @changePasswordOldHint.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get changePasswordOldHint;

  /// No description provided for @changePasswordNewHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password (at least 6 characters)'**
  String get changePasswordNewHint;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Before You Delete'**
  String get deleteNoticeTitle;

  /// No description provided for @deleteProfileWarning.
  ///
  /// In en, this message translates to:
  /// **'Your account information and profile will be permanently deleted'**
  String get deleteProfileWarning;

  /// No description provided for @deleteCloudWarning.
  ///
  /// In en, this message translates to:
  /// **'Cloud canvases, assets, and sync data will no longer be accessible'**
  String get deleteCloudWarning;

  /// No description provided for @deleteLoginWarning.
  ///
  /// In en, this message translates to:
  /// **'Your session ends immediately and the account cannot be restored'**
  String get deleteLoginWarning;

  /// No description provided for @deleteLocalFileNotice.
  ///
  /// In en, this message translates to:
  /// **'Local files on this device will not be deleted automatically'**
  String get deleteLocalFileNotice;

  /// No description provided for @verifyIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Identity'**
  String get verifyIdentityTitle;

  /// No description provided for @deletePasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter your account password to confirm this is you'**
  String get deletePasswordHelp;

  /// No description provided for @currentPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordHint;

  /// No description provided for @passwordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get passwordEmpty;

  /// No description provided for @deleteRiskAccepted.
  ///
  /// In en, this message translates to:
  /// **'I understand and accept the consequences of deleting my account'**
  String get deleteRiskAccepted;

  /// No description provided for @deleteAcceptRiskFirst.
  ///
  /// In en, this message translates to:
  /// **'Please acknowledge the account deletion risks first'**
  String get deleteAcceptRiskFirst;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteConfirm;

  /// No description provided for @deleteIrreversible.
  ///
  /// In en, this message translates to:
  /// **'Account deletion cannot be undone'**
  String get deleteIrreversible;

  /// No description provided for @deleteFinalTitle.
  ///
  /// In en, this message translates to:
  /// **'Final Confirmation'**
  String get deleteFinalTitle;

  /// No description provided for @deleteFinalContent.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete this account? This action cannot be undone.'**
  String get deleteFinalContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Verify the email linked to your account, then create a new password'**
  String get forgotPasswordDescription;

  /// No description provided for @recoveryEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your account email'**
  String get recoveryEmailHint;

  /// No description provided for @recoveryCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get recoveryCodeHint;

  /// No description provided for @recoveryNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password (6+ characters)'**
  String get recoveryNewPasswordHint;

  /// No description provided for @recoveryConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the new password again'**
  String get recoveryConfirmPasswordHint;

  /// No description provided for @requestCode.
  ///
  /// In en, this message translates to:
  /// **'Get Code'**
  String get requestCode;

  /// No description provided for @sendingCode.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get sendingCode;

  /// No description provided for @codeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent'**
  String get codeSent;

  /// No description provided for @invalidRecoveryEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidRecoveryEmail;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @forgotPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password? Recover it now'**
  String get forgotPasswordAction;

  /// No description provided for @bindEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Bind Email'**
  String get bindEmailTitle;

  /// No description provided for @changeEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmailTitle;

  /// No description provided for @bindEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'Bind an email for login and password recovery'**
  String get bindEmailDescription;

  /// No description provided for @currentEmail.
  ///
  /// In en, this message translates to:
  /// **'Current email: {email}'**
  String currentEmail(String email);

  /// No description provided for @bindEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the email to bind'**
  String get bindEmailHint;

  /// No description provided for @confirmBinding.
  ///
  /// In en, this message translates to:
  /// **'Bind Email'**
  String get confirmBinding;

  /// No description provided for @emailBoundSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email bound successfully'**
  String get emailBoundSuccess;

  /// No description provided for @emailAlreadyBound.
  ///
  /// In en, this message translates to:
  /// **'This email is already bound to another account'**
  String get emailAlreadyBound;

  /// No description provided for @bindPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Bind Phone'**
  String get bindPhoneTitle;

  /// No description provided for @changePhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Phone'**
  String get changePhoneTitle;

  /// No description provided for @bindPhoneDescription.
  ///
  /// In en, this message translates to:
  /// **'Bind a phone number for login and security verification'**
  String get bindPhoneDescription;

  /// No description provided for @currentPhone.
  ///
  /// In en, this message translates to:
  /// **'Current phone: {phone}'**
  String currentPhone(String phone);

  /// No description provided for @bindPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number to bind'**
  String get bindPhoneHint;

  /// No description provided for @confirmPhoneBinding.
  ///
  /// In en, this message translates to:
  /// **'Bind Phone'**
  String get confirmPhoneBinding;

  /// No description provided for @phoneBoundSuccess.
  ///
  /// In en, this message translates to:
  /// **'Phone number bound successfully'**
  String get phoneBoundSuccess;

  /// No description provided for @phoneAlreadyBound.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already bound to another account'**
  String get phoneAlreadyBound;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get invalidPhone;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset. Sign in with your new password'**
  String get passwordResetSuccess;
}

class _FxAccountLocalizationsDelegate
    extends LocalizationsDelegate<FxAccountLocalizations> {
  const _FxAccountLocalizationsDelegate();

  @override
  Future<FxAccountLocalizations> load(Locale locale) {
    return SynchronousFuture<FxAccountLocalizations>(
        lookupFxAccountLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_FxAccountLocalizationsDelegate old) => false;
}

FxAccountLocalizations lookupFxAccountLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return FxAccountLocalizationsEn();
    case 'zh':
      return FxAccountLocalizationsZh();
  }

  throw FlutterError(
      'FxAccountLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
