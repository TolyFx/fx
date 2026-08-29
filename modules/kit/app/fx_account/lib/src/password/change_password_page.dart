import 'package:flutter/material.dart';

import '../../l10n/fx_account_localizations.dart';

/// 外部提交当前密码和新密码。
typedef ChangePasswordSubmitted = Future<void> Function(
    String oldPassword, String newPassword);

/// 只负责表单交互的移动端修改密码页。
class ChangePasswordPage extends StatefulWidget {
  /// 由宿主负责的密码修改提交行为。
  final ChangePasswordSubmitted onSubmit;

  /// 打开找回密码流程；未提供时不展示入口。
  final VoidCallback? onForgotPassword;

  /// 新密码允许提交的最短长度。
  final int minimumPasswordLength;

  const ChangePasswordPage({
    super.key,
    required this.onSubmit,
    this.onForgotPassword,
    this.minimumPasswordLength = 6,
  });

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  /// 当前密码输入控制器。
  final TextEditingController _oldController = TextEditingController();

  /// 新密码输入控制器。
  final TextEditingController _newController = TextEditingController();

  /// 修改请求是否正在提交。
  bool _loading = false;

  bool get _canSubmit {
    return _oldController.text.trim().isNotEmpty &&
        _newController.text.trim().length >= widget.minimumPasswordLength &&
        !_loading;
  }

  @override
  void initState() {
    super.initState();
    _oldController.addListener(_refreshButtonState);
    _newController.addListener(_refreshButtonState);
  }

  @override
  void dispose() {
    _oldController.removeListener(_refreshButtonState);
    _newController.removeListener(_refreshButtonState);
    _oldController.dispose();
    _newController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FxAccountLocalizations l10n = FxAccountLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
            splashFactory: NoSplash.splashFactory,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            l10n.changePasswordTitle,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: Colors.black,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.changePasswordDescription,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              _buildInput(_oldController, l10n.changePasswordOldHint),
              const SizedBox(height: 16),
              _buildInput(_newController, l10n.changePasswordNewHint),
              const SizedBox(height: 48),
              _buildActionButton(l10n.confirm),
            ],
          ),
        ),
        bottomNavigationBar: widget.onForgotPassword == null
            ? null
            : SafeArea(
                minimum: const EdgeInsets.only(bottom: 12),
                child: Center(
                  heightFactor: 1,
                  child: TextButton(
                    onPressed: widget.onForgotPassword,
                    child: Text(
                      l10n.forgotPasswordAction,
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label) {
    const Color primary = Color(0xFF3B82F6);
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: _canSubmit
          ? ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(label, style: const TextStyle(fontSize: 16)),
            )
          : OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: Text(
                label,
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
            ),
    );
  }

  void _refreshButtonState() => setState(() {});

  /// 将表单值交给宿主，页面自身只维护提交中的按钮状态。
  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await widget.onSubmit(
        _oldController.text.trim(),
        _newController.text.trim(),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
