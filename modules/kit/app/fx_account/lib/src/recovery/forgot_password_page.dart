import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/fx_account_localizations.dart';

/// 外部发送邮箱验证码。
typedef RecoveryCodeRequested = Future<String?> Function(String email);

/// 外部提交邮箱、验证码和新密码。
typedef PasswordRecoverySubmitted = Future<void> Function(
  String email,
  String code,
  String newPassword,
);

/// 外部展示找回密码流程的结果提示。
typedef PasswordRecoveryMessageRequested = void Function(String message);

/// 通过邮箱验证码找回密码的通用页面。
class ForgotPasswordPage extends StatefulWidget {
  /// 由宿主负责的验证码发送行为。
  final RecoveryCodeRequested onRequestCode;

  /// 由宿主负责的密码重置行为。
  final PasswordRecoverySubmitted onSubmit;

  /// 宿主可选的轻提示展示行为。
  final PasswordRecoveryMessageRequested? onMessage;

  /// 新密码允许提交的最短长度。
  final int minimumPasswordLength;

  /// 验证码重发倒计时秒数。
  final int resendCountdownSeconds;

  const ForgotPasswordPage({
    super.key,
    required this.onRequestCode,
    required this.onSubmit,
    this.onMessage,
    this.minimumPasswordLength = 6,
    this.resendCountdownSeconds = 60,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  /// 邮箱输入控制器。
  final TextEditingController _emailController = TextEditingController();

  /// 验证码输入控制器。
  final TextEditingController _codeController = TextEditingController();

  /// 新密码输入控制器。
  final TextEditingController _passwordController = TextEditingController();

  /// 新密码确认输入控制器。
  final TextEditingController _confirmationController = TextEditingController();

  /// 验证码重发倒计时。
  Timer? _countdownTimer;

  /// 当前剩余倒计时秒数。
  int _countdown = 0;

  /// 是否正在发送验证码。
  bool _requestingCode = false;

  /// 是否正在提交密码重置。
  bool _submitting = false;

  bool get _canSubmit {
    final String email = _emailController.text.trim();
    final String code = _codeController.text.trim();
    final String password = _passwordController.text;
    return email.contains('@') &&
        code.isNotEmpty &&
        password.length >= widget.minimumPasswordLength &&
        password == _confirmationController.text &&
        !_submitting;
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_refresh);
    _codeController.addListener(_refresh);
    _passwordController.addListener(_refresh);
    _confirmationController.addListener(_refresh);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FxAccountLocalizations l10n = FxAccountLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.forgotPasswordTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          children: [
            Text(
              l10n.forgotPasswordDescription,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 28),
            _buildInput(
              controller: _emailController,
              hint: l10n.recoveryEmailHint,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            _buildCodeInput(l10n),
            const SizedBox(height: 14),
            _buildInput(
              controller: _passwordController,
              hint: l10n.recoveryNewPasswordHint,
              obscureText: true,
            ),
            const SizedBox(height: 14),
            _buildInput(
              controller: _confirmationController,
              hint: l10n.recoveryConfirmPasswordHint,
              obscureText: true,
            ),
            const SizedBox(height: 40),
            _buildSubmitButton(l10n.resetPassword),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCodeInput(FxAccountLocalizations l10n) {
    final bool canRequest = _countdown == 0 && !_requestingCode;
    final String label = _requestingCode
        ? l10n.sendingCode
        : _countdown > 0
            ? '${_countdown}s'
            : l10n.requestCode;
    return _buildInput(
      controller: _codeController,
      hint: l10n.recoveryCodeHint,
      keyboardType: TextInputType.number,
      suffix: TextButton(
        onPressed: canRequest ? _requestCode : null,
        child: Text(label),
      ),
    );
  }

  Widget _buildSubmitButton(String label) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _canSubmit ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[100],
          disabledForegroundColor: Colors.grey[400],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: _submitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  void _refresh() => setState(() {});

  /// 校验邮箱后调用宿主发送验证码，并启动重发倒计时。
  Future<void> _requestCode() async {
    final FxAccountLocalizations l10n = FxAccountLocalizations.of(context)!;
    final String email = _emailController.text.trim();
    if (!email.contains('@')) {
      widget.onMessage?.call(l10n.invalidRecoveryEmail);
      return;
    }
    setState(() => _requestingCode = true);
    try {
      final String? code = await widget.onRequestCode(email);
      if (!mounted) return;
      if (code != null && code.isNotEmpty) _codeController.text = code;
      widget.onMessage?.call(l10n.codeSent);
      _startCountdown();
    } finally {
      if (mounted) setState(() => _requestingCode = false);
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _countdown = widget.resendCountdownSeconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted || _countdown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _countdown = 0);
        return;
      }
      setState(() => _countdown -= 1);
    });
  }

  /// 完成本地一致性检查后，把找回密码提交交给宿主。
  Future<void> _submit() async {
    final FxAccountLocalizations l10n = FxAccountLocalizations.of(context)!;
    if (_passwordController.text != _confirmationController.text) {
      widget.onMessage?.call(l10n.passwordsDoNotMatch);
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(
        _emailController.text.trim(),
        _codeController.text.trim(),
        _passwordController.text,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
