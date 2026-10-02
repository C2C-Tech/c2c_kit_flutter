import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../constants/apps.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../api/auth_api.dart';
import '../../api/models.dart';
import '../l10n/kit_l10n.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_message.dart';

/// Opens the passkey list. Dialog on web, full screen on mobile.
///
/// Add runs the system passkey prompt. Remove only calls the cloud delete API.
Future<void> showC2cPasskeySettings(
  BuildContext context, {
  required C2cApp app,
  required String accessToken,
  Locale locale = KitL10n.defaultLocale,
  bool debugMode = false,
}) {
  final C2cPasskeySettingsView view = C2cPasskeySettingsView(
    app: app,
    accessToken: accessToken,
    locale: locale,
    debugMode: debugMode,
    isDialog: kIsWeb,
  );
  final KitL10n l10n = KitL10n(locale);

  if (kIsWeb) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext _) {
        return Dialog(
          backgroundColor: KitColors.surface,
          surfaceTintColor: KitColors.surface,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460, maxHeight: 640),
            child: Material(
              color: KitColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radius16),
              clipBehavior: Clip.antiAlias,
              child: view,
            ),
          ),
        );
      },
    );
  }

  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        backgroundColor: KitColors.background,
        appBar: CustomAppBar(title: l10n.passkeysTitle, app: app),
        body: SafeArea(child: view),
      ),
    ),
  );
}

class C2cPasskeySettingsView extends StatefulWidget {
  const C2cPasskeySettingsView({
    super.key,
    required this.app,
    required this.accessToken,
    this.locale = KitL10n.defaultLocale,
    this.debugMode = false,
    this.isDialog = false,
  });

  final C2cApp app;
  final String accessToken;
  final Locale locale;
  final bool debugMode;
  final bool isDialog;

  @override
  State<C2cPasskeySettingsView> createState() => _C2cPasskeySettingsViewState();
}

class _C2cPasskeySettingsViewState extends State<C2cPasskeySettingsView> {
  KitL10n get _l10n => KitL10n(widget.locale);

  bool _loading = true;
  bool _busy = false;
  bool _supportChecked = false;
  bool _canAdd = false;
  String? _error;
  List<C2cPasskey> _passkeys = const <C2cPasskey>[];

  @override
  void initState() {
    super.initState();
    _load();
    _loadSupport();
  }

  Future<void> _loadSupport() async {
    final bool supported = await c2cPasskeysSupported();
    if (!mounted) return;
    setState(() {
      _canAdd = supported;
      _supportChecked = true;
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final PasskeyListResult result = await C2cKitAuthApi.listPasskeys(
      app: widget.app,
      cloudAccessToken: widget.accessToken,
    );
    if (!mounted) return;
    switch (result) {
      case PasskeyListSuccess(:final passkeys):
        setState(() {
          _passkeys = passkeys;
          _loading = false;
        });
      case PasskeyListFailure(:final message):
        setState(() {
          _error = message;
          _loading = false;
        });
    }
  }

  Future<void> _add() async {
    setState(() => _busy = true);
    try {
      final PasskeyRegisterResult result = await C2cKitAuthApi.registerPasskey(
        app: widget.app,
        cloudAccessToken: widget.accessToken,
        debugMode: widget.debugMode,
      );
      if (!mounted) return;
      switch (result) {
        case PasskeyRegisterSuccess():
          showCustomMessage(context, _l10n.passkeyAdded);
          await _load();
        case PasskeyRegisterCancelled():
          break;
        case PasskeyRegisterFailure(:final message):
          showCustomMessage(context, message, isError: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDelete(C2cPasskey passkey) async {
    final KitL10n l10n = _l10n;
    final String label = _rowTitle(passkey, l10n);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.removePasskeyTitle),
          content: Text(l10n.removePasskeyBody(label)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.removePasskey),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final PasskeyDeleteResult result = await C2cKitAuthApi.deletePasskey(
        app: widget.app,
        cloudAccessToken: widget.accessToken,
        passkeyId: passkey.passkeyId,
      );
      if (!mounted) return;
      switch (result) {
        case PasskeyDeleteSuccess():
          showCustomMessage(context, l10n.passkeyRemoved);
          await _load();
        case PasskeyDeleteFailure(:final message):
          showCustomMessage(context, message, isError: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _rowTitle(C2cPasskey passkey, KitL10n l10n) {
    if (passkey.deviceLabel.trim().isNotEmpty) {
      return passkey.deviceLabel.trim();
    }
    final String platform = l10n.passkeyPlatformLabel(passkey.platform);
    if (platform.isNotEmpty) return platform;
    return l10n.passkeyFallbackName;
  }

  String _rowSubtitle(C2cPasskey passkey, KitL10n l10n) {
    final List<String> parts = <String>[];
    final String platform = l10n.passkeyPlatformLabel(passkey.platform);
    if (platform.isNotEmpty) parts.add(platform);
    if (passkey.registeredApp.isNotEmpty) {
      parts.add(
        l10n.registeredIn(C2cApp.nameForApplicationId(passkey.registeredApp)),
      );
    }
    final String created = _createdDate(passkey.createdAt);
    if (created.isNotEmpty) parts.add(l10n.addedOn(created));
    return parts.join(' · ');
  }

  String _createdDate(String createdAt) {
    if (createdAt.length >= 10 && createdAt[4] == '-' && createdAt[7] == '-') {
      return createdAt.substring(0, 10);
    }
    return createdAt;
  }

  IconData _platformIcon(String platform) {
    switch (platform) {
      case 'ios':
        return Icons.phone_iphone;
      case 'android':
        return Icons.phone_android;
      case 'web':
        return Icons.language;
      default:
        return Icons.key_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final KitL10n l10n = _l10n;
    final bool locked = _loading || _busy;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacing20),
      children: [
        if (widget.isDialog) ...[
          Text(
            l10n.passkeysTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: KitColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
        ],
        Text(
          l10n.passkeysSubtitle,
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
            color: KitColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing20),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null) ...[
          Text(
            _error!,
            style: const TextStyle(color: KitColors.error, fontSize: 14),
          ),
          const SizedBox(height: AppDimensions.spacing12),
          CustomButton(
            label: l10n.retry,
            isOutlined: true,
            onPressed: locked ? null : _load,
          ),
        ] else ...[
          if (_passkeys.isEmpty && _supportChecked)
            _PasskeySurface(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _PasskeyIconTile(icon: Icons.key_outlined),
                  const SizedBox(width: AppDimensions.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.noPasskeyOnDevice,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: KitColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacing4),
                        Text(
                          _canAdd
                              ? l10n.createPasskeyHint
                              : l10n.passkeyUnavailable,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: KitColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else if (_passkeys.isNotEmpty) ...[
            Text(
              l10n.savedPasskeys,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KitColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing12),
            ..._passkeys.map((C2cPasskey passkey) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
                child: _PasskeySurface(
                  child: Row(
                    children: [
                      _PasskeyIconTile(icon: _platformIcon(passkey.platform)),
                      const SizedBox(width: AppDimensions.spacing12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _rowTitle(passkey, l10n),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: KitColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spacing4),
                            Text(
                              _rowSubtitle(passkey, l10n),
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: KitColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.removePasskey,
                        onPressed: locked
                            ? null
                            : () => _confirmDelete(passkey),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: KitColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          if (_canAdd) ...[
            const SizedBox(height: AppDimensions.spacing8),
            CustomButton(
              label: l10n.createPasskey,
              isLoading: _busy,
              onPressed: locked ? null : _add,
            ),
          ],
        ],
      ],
    );
  }
}

class _PasskeySurface extends StatelessWidget {
  const _PasskeySurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing12,
      ),
      decoration: BoxDecoration(
        color: KitColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(color: KitColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PasskeyIconTile extends StatelessWidget {
  const _PasskeyIconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: KitColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
      ),
      child: Icon(icon, size: 22, color: KitColors.primary),
    );
  }
}
