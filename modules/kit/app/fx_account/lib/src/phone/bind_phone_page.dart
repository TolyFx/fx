import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/fx_account_localizations.dart';

/// 外部发送绑定手机号验证码。
typedef BindPhoneCodeRequested = Future<String?> Function(String phone);

/// 外部校验手机号是否可用于绑定。
typedef BindPhoneValidated = Future<bool> Function(String phone);

/// 外部提交手机号绑定。
typedef BindPhoneSubmitted = Future<void> Function(String phone, String code);

/// 外部展示手机号绑定流程提示。
typedef BindPhoneMessageRequested = void Function(String message);

/// 通过短信验证码绑定或更换手机号的通用页面。
class BindPhonePage extends StatefulWidget {
  /// 当前已绑定手机号。
  final String? currentPhone;

  /// 由宿主负责的验证码发送行为。
  final BindPhoneCodeRequested onRequestCode;

  /// 由宿主负责的手机号可用性校验。
  final BindPhoneValidated? onValidatePhone;

  /// 由宿主负责的手机号绑定行为。
  final BindPhoneSubmitted onSubmit;

  /// 宿主可选的轻提示行为。
  final BindPhoneMessageRequested? onMessage;

  /// 验证码重发倒计时秒数。
  final int resendCountdownSeconds;

  const BindPhonePage({
    super.key,
    this.currentPhone,
    required this.onRequestCode,
    this.onValidatePhone,
    required this.onSubmit,
    this.onMessage,
    this.resendCountdownSeconds = 60,
  });

  @override
  State<BindPhonePage> createState() => _BindPhonePageState();
}

class _BindPhonePageState extends State<BindPhonePage> {
  /// 手机号输入控制器。
  final TextEditingController _phoneController = TextEditingController();

  /// 验证码输入控制器。
  final TextEditingController _codeController = TextEditingController();

  /// 倒计时计时器。
  Timer? _timer;

  /// 验证码重发剩余秒数。
  int _countdown = 0;

  /// 是否正在请求验证码。
  bool _requesting = false;

  /// 是否正在提交手机号绑定。
  bool _submitting = false;

  bool get _canSubmit {
    return _isValidPhone(_phoneController.text.trim()) &&
        _codeController.text.trim().isNotEmpty &&
        !_submitting;
  }

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_refresh);
    _codeController.addListener(_refresh);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FxAccountLocalizations l10n = FxAccountLocalizations.of(context)!;
    final String? currentPhone = widget.currentPhone;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          currentPhone == null ? l10n.bindPhoneTitle : l10n.changePhoneTitle,
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
              currentPhone == null
                  ? l10n.bindPhoneDescription
                  : l10n.currentPhone(currentPhone),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildInput(
              controller: _phoneController,
              hint: l10n.bindPhoneHint,
              keyboardType: TextInputType.phone,
              maxLength: 11,
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
                    : Text(l10n.confirmPhoneBinding),
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
    int? maxLength,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
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

  Future<void> _requestCode() async {
    final FxAccountLocalizations l10n = FxAccountLocalizations.of(context)!;
    final String phone = _phoneController.text.trim();
    if (!_isValidPhone(phone)) {
      widget.onMessage?.call(l10n.invalidPhone);
      return;
    }
    setState(() => _requesting = true);
    try {
      final bool available = await widget.onValidatePhone?.call(phone) ?? true;
      if (!available || !mounted) return;
      final String? code = await widget.onRequestCode(phone);
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

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(
        _phoneController.text.trim(),
        _codeController.text.trim(),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

bool _isValidPhone(String phone) {
  return RegExp(r'^1\d{10}$').hasMatch(phone);
}
