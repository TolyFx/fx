import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/fx_account_localizations.dart';

/// 外部发送绑定邮箱验证码。
typedef BindEmailCodeRequested = Future<String?> Function(String email);

/// 外部校验邮箱是否可用于绑定。
typedef BindEmailValidated = Future<bool> Function(String email);

/// 外部提交邮箱绑定。
typedef BindEmailSubmitted = Future<void> Function(String email, String code);

/// 外部展示邮箱绑定流程提示。
typedef BindEmailMessageRequested = void Function(String message);

/// 通过邮箱验证码绑定或更换邮箱的通用页面。
class BindEmailPage extends StatefulWidget {
  /// 当前已绑定邮箱，仅用于页面说明。
  final String? currentEmail;

  /// 由宿主负责的验证码发送行为。
  final BindEmailCodeRequested onRequestCode;

  /// 由宿主负责的邮箱可用性校验。
  final BindEmailValidated? onValidateEmail;

  /// 由宿主负责的邮箱绑定行为。
  final BindEmailSubmitted onSubmit;

  /// 宿主可选的轻提示行为。
  final BindEmailMessageRequested? onMessage;

  /// 验证码重发倒计时秒数。
  final int resendCountdownSeconds;

  const BindEmailPage({
    super.key,
    this.currentEmail,
    required this.onRequestCode,
    this.onValidateEmail,
    required this.onSubmit,
    this.onMessage,
    this.resendCountdownSeconds = 60,
  });

  @override
  State<BindEmailPage> createState() => _BindEmailPageState();
}

class _BindEmailPageState extends State<BindEmailPage> {
  /// 邮箱输入控制器。
  final TextEditingController _emailController = TextEditingController();

  /// 验证码输入控制器。
  final TextEditingController _codeController = TextEditingController();

  /// 倒计时计时器。
  Timer? _timer;

  /// 验证码重发剩余秒数。
  int _countdown = 0;

  /// 是否正在请求验证码。
  bool _requesting = false;

  /// 是否正在提交邮箱绑定。
  bool _submitting = false;

  bool get _canSubmit {
    return _emailController.text.trim().contains('@') &&
        _codeController.text.trim().isNotEmpty &&
        !_submitting;
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_refresh);
    _codeController.addListener(_refresh);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FxAccountLocalizations l10n = FxAccountLocalizations.of(context)!;
    final String? currentEmail = widget.currentEmail;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          currentEmail == null ? l10n.bindEmailTitle : l10n.changeEmailTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentEmail == null
                  ? l10n.bindEmailDescription
                  : l10n.currentEmail(currentEmail),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildInput(
              controller: _emailController,
              hint: l10n.bindEmailHint,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildInput(
              controller: _codeController,
              hint: l10n.recoveryCodeHint,
              keyboardType: TextInputType.number,
              suffix: _buildCodeButton(l10n),
            ),
            const SizedBox(height: 48),
            SizedBox(
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
                    : Text(l10n.confirmBinding),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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

  Widget _buildCodeButton(FxAccountLocalizations l10n) {
    final bool enabled = _countdown == 0 && !_requesting;
    final String label = _requesting
        ? l10n.sendingCode
        : _countdown > 0
            ? '${_countdown}s'
            : l10n.requestCode;
    return TextButton(
      onPressed: enabled ? _requestCode : null,
      child: Text(label),
    );
  }

  void _refresh() => setState(() {});

  /// 请求绑定邮箱专用验证码并启动重发倒计时。
  Future<void> _requestCode() async {
    final FxAccountLocalizations l10n = FxAccountLocalizations.of(context)!;
    final String email = _emailController.text.trim();
    if (!email.contains('@')) {
      widget.onMessage?.call(l10n.invalidRecoveryEmail);
      return;
    }
    setState(() => _requesting = true);
    try {
      final bool available = await widget.onValidateEmail?.call(email) ?? true;
      if (!available || !mounted) return;
      final String? code = await widget.onRequestCode(email);
      if (!mounted) return;
      if (code != null && code.isNotEmpty) _codeController.text = code;
      widget.onMessage?.call(l10n.codeSent);
      _startCountdown();
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = widget.resendCountdownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted || _countdown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _countdown = 0);
        return;
      }
      setState(() => _countdown -= 1);
    });
  }

  /// 将邮箱和验证码交由宿主提交。
  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(
        _emailController.text.trim(),
        _codeController.text.trim(),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
