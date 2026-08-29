import 'package:flutter/material.dart';

import '../../l10n/fx_account_localizations.dart';

/// 外部提交账户注销密码。
typedef AccountDeletionSubmitted = Future<void> Function(String password);

/// 外部展示页面产生的非字段提示。
typedef AccountPageMessageRequested = void Function(String message);

/// 只负责风险确认和密码采集的账户注销页面。
class DeleteAccountPage extends StatefulWidget {
  /// 由宿主负责的账户注销提交行为。
  final AccountDeletionSubmitted onSubmit;

  /// 页面非字段提示交给宿主展示。
  final AccountPageMessageRequested? onMessage;

  const DeleteAccountPage({
    super.key,
    required this.onSubmit,
    this.onMessage,
  });

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  /// 用于验证当前用户身份的账号密码。
  final TextEditingController _passwordController = TextEditingController();

  /// 用户是否已主动确认不可恢复风险。
  bool _riskAccepted = false;

  /// 注销请求是否正在提交。
  bool _submitting = false;

  /// 密码输入框当前展示的错误。
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FxAccountLocalizations l10n = FxAccountLocalizations.of(context)!;
    final Color background = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : const Color(0xFFF5F6F8);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(l10n.deleteAccountTitle),
        backgroundColor: background,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: <Widget>[
            _buildWarningCard(context, l10n),
            const SizedBox(height: 12),
            _buildVerificationCard(context, l10n),
            const SizedBox(height: 20),
            _buildSubmitButton(l10n.deleteConfirm),
            const SizedBox(height: 10),
            Text(
              l10n.deleteIrreversible,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建注销后果说明卡片。
  Widget _buildWarningCard(
    BuildContext context,
    FxAccountLocalizations l10n,
  ) {
    return _AccountDeleteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEEE9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFE5484D),
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.deleteNoticeTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWarningItem(l10n.deleteProfileWarning),
          _buildWarningItem(l10n.deleteCloudWarning),
          _buildWarningItem(l10n.deleteLoginWarning),
          _buildWarningItem(l10n.deleteLocalFileNotice),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: SizedBox.square(
              dimension: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF98A0AE),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建密码验证和风险确认区域。
  Widget _buildVerificationCard(
    BuildContext context,
    FxAccountLocalizations l10n,
  ) {
    return _AccountDeleteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.verifyIdentityTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            l10n.deletePasswordHelp,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onChanged: _handlePasswordChanged,
            onSubmitted: (_) => _requestFinalConfirmation(),
            decoration: InputDecoration(
              hintText: l10n.currentPasswordHint,
              errorText: _errorText,
              filled: true,
              fillColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.46),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
            ),
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            value: _riskAccepted,
            onChanged: _submitting ? null : _handleRiskChanged,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            title: Text(
              l10n.deleteRiskAccepted,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(String label) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: _submitting ? null : _requestFinalConfirmation,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFE5484D),
          disabledBackgroundColor: const Color(0xFFE5484D).withValues(
            alpha: 0.45,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _submitting
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }

  void _handlePasswordChanged(String value) {
    if (_errorText != null) setState(() => _errorText = null);
  }

  void _handleRiskChanged(bool? accepted) {
    setState(() => _riskAccepted = accepted ?? false);
  }

  /// 校验当前输入后展示最后一次不可逆操作确认。
  Future<void> _requestFinalConfirmation() async {
    final FxAccountLocalizations l10n = FxAccountLocalizations.of(context)!;
    if (_passwordController.text.isEmpty) {
      setState(() => _errorText = l10n.passwordEmpty);
      return;
    }
    if (!_riskAccepted) {
      _showMessage(l10n.deleteAcceptRiskFirst);
      return;
    }
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: Text(l10n.deleteFinalTitle),
            content: Text(l10n.deleteFinalContent),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  l10n.deleteConfirm,
                  style: const TextStyle(color: Color(0xFFE5484D)),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed && mounted) await _submit();
  }

  void _showMessage(String message) {
    final AccountPageMessageRequested? onMessage = widget.onMessage;
    if (onMessage != null) {
      onMessage(message);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// 将密码交给宿主，页面自身只维护提交中的按钮状态。
  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      await widget.onSubmit(_passwordController.text);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _AccountDeleteCard extends StatelessWidget {
  /// 卡片承载的注销说明或验证内容。
  final Widget child;

  const _AccountDeleteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}
