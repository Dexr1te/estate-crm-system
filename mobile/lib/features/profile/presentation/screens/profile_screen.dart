import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/locale/bloc/locale_bloc.dart';
import 'package:real_estate_crm/core/network/api_client.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/theme/bloc/theme_bloc.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_event.dart';
import 'package:real_estate_crm/features/auth/presentation/bloc/auth_state.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _endonyms = {'en': 'English', 'ru': 'Русский', 'kk': 'Қазақша'};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (ctx, state) {
        final l10n = AppLocalizations.of(ctx);
        final user = state is AuthAuthenticated ? state.user : null;
        if (user == null) return const SizedBox.shrink();

        return DetailScaffold(
          title: l10n.profileTitle,
          children: [
            _Identity(user: user),
            SettingsGroup(rows: [
              SettingsRow(label: l10n.profileName, value: user.fullName),
              SettingsRow(label: l10n.profileEmail, value: user.email),
              SettingsRow(
                label: l10n.profileAgentId,
                trailing: _IdChip(
                  id: user.userId,
                  onCopied: () {
                    Clipboard.setData(ClipboardData(text: '${user.userId}'));
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                          content: Text(l10n.profileAgentIdCopied),
                          duration: const Duration(seconds: 1)));
                  },
                ),
              ),
            ]),
            _GroupLabel(l10n.profileSettings),
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (themeCtx, themeState) =>
                  BlocBuilder<LocaleBloc, LocaleState>(
                builder: (localeCtx, localeState) => SettingsGroup(rows: [
                  SettingsRow(
                    label: l10n.profileDarkMode,
                    subLabel: l10n.profileFollowSystem,
                    trailing: AppSwitch(
                      value: themeState.isDark,
                      onChanged: (_) =>
                          themeCtx.read<ThemeBloc>().add(ThemeToggleEvent()),
                    ),
                  ),
                  SettingsRow(
                    label: l10n.profileLanguage,
                    value: _languageLabel(l10n, localeState.locale),
                    showChevron: true,
                    onTap: () =>
                        _showLanguagePicker(localeCtx, localeState.locale),
                  ),
                ]),
              ),
            ),
            _GroupLabel(l10n.profileApp),
            AppCard(
              child: Row(
                children: [
                  const BrandMark(size: 40, radius: 12),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.profileEstateCrm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ctx.tokens.textPrimary),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${l10n.profileVersion} ${Injector.appVersion}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: 11.5,
                              color: ctx.tokens.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _GroupLabel(l10n.profileLegal),
            SettingsGroup(rows: [
              SettingsRow(
                label: l10n.profilePrivacyPolicy,
                showChevron: true,
                onTap: () => _openPage(context, '/privacy'),
              ),
              SettingsRow(
                label: l10n.profileSupport,
                showChevron: true,
                onTap: () => _openPage(context, '/support'),
              ),
            ]),
            AppDangerButton(
              label: l10n.profileSignOut,
              onPressed: () => _confirmLogout(context),
            ),
            _DeleteAccountButton(user: user),
          ],
        );
      },
    );
  }

  String _languageLabel(AppLocalizations l10n, Locale? locale) => locale == null
      ? l10n.profileSystemDefault
      : _endonyms[locale.languageCode] ?? locale.languageCode;

  void _showLanguagePicker(BuildContext context, Locale? current) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<LocaleBloc>();
    showAppBottomSheet(
      context,
      title: l10n.profileLanguage,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LanguageOption(
            label: l10n.profileSystemDefault,
            selected: current == null,
            onTap: () {
              bloc.add(LocaleChangedEvent(null));
              Navigator.pop(ctx);
            },
          ),
          for (final locale in LocaleBloc.supported) ...[
            const SizedBox(height: 8),
            _LanguageOption(
              label: _endonyms[locale.languageCode] ?? locale.languageCode,
              selected: current?.languageCode == locale.languageCode,
              onTap: () {
                bloc.add(LocaleChangedEvent(locale));
                Navigator.pop(ctx);
              },
            ),
          ],
        ],
      ),
    );
  }

  /// Opens a page the backend serves — the privacy policy and the support page
  /// live next to the API so there is exactly one host to keep alive.
  Future<void> _openPage(BuildContext context, String path) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final opened = await launchUrl(
      Uri.parse('$apiOrigin$path'),
      mode: LaunchMode.externalApplication,
    ).catchError((_) => false);

    if (!opened) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.profileLinkFailed)));
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<AuthBloc>();
    final ok = await showConfirmDialog(
      context,
      title: l10n.profileSignOut,
      content: l10n.profileSignOutConfirm,
      confirmLabel: l10n.profileSignOut,
      icon: Icons.logout_rounded,
    );
    if (ok) bloc.add(AuthLogoutEvent());
  }
}

/// Closing your own account, which App Store Review Guideline 5.1.1(v) requires
/// an app holding an account to offer without going through anyone else.
///
/// The records are the agency's, not the leaver's, so this asks who takes them
/// over before it asks whether you are sure — the same handover an admin does.
/// The backend refuses without a successor when there is anything to move, and
/// refuses outright for the primary admin; both come back as a message rather
/// than as a dead end.
class _DeleteAccountButton extends StatefulWidget {
  final AuthResponse user;
  const _DeleteAccountButton({required this.user});

  @override
  State<_DeleteAccountButton> createState() => _DeleteAccountButtonState();
}

class _DeleteAccountButtonState extends State<_DeleteAccountButton> {
  bool _busy = false;

  Future<void> _start() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final auth = context.read<AuthBloc>();

    final successor = await _pickSuccessor(l10n, messenger);
    if (successor == null || !mounted) return;

    final confirmed = await showConfirmDialog(
      context,
      title: l10n.profileDeleteAccount,
      content: l10n.profileDeleteAccountConfirm(successor.title),
      confirmLabel: l10n.profileDeleteAccount,
      icon: Icons.person_remove_outlined,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    try {
      await Injector.authRepository.deleteAccount(replacementId: successor.id);
      // The session is already cleared; this is what moves the app off the
      // screen belonging to an account that no longer exists.
      auth.add(AuthLogoutEvent());
    } catch (err) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(apiFailureLabel(l10n, ApiFailure.from(err))),
          backgroundColor: context.tokens.dangerSolid,
        ));
    }
  }

  Future<PickerItem?> _pickSuccessor(
      AppLocalizations l10n, ScaffoldMessengerState messenger) async {
    List<AgentOption> agents;
    try {
      agents = await Injector.agentsRepository.getAgentOptions();
    } catch (err) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(apiFailureLabel(l10n, ApiFailure.from(err)))));
      return null;
    }
    if (!mounted) return null;

    return showEntityPicker(
      context,
      title: l10n.profileDeleteHandoverTitle,
      searchHint: l10n.profileDeleteHandoverSearch,
      emptyLabel: l10n.profileDeleteHandoverEmpty,
      items: [
        for (final a in agents)
          if (a.id != widget.user.userId)
            PickerItem(id: a.id, title: a.fullName, subtitle: a.email),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // Outlined rather than solid: the design system keeps solid red for the
    // confirm button of the dialog this opens.
    return AppGhostButton(
      label: AppLocalizations.of(context).profileDeleteAccount,
      onPressed: _busy ? null : _start,
      borderColor: t.dangerBorder,
      labelColor: t.dangerText,
    );
  }
}

class _Identity extends StatelessWidget {
  final AuthResponse user;
  const _Identity({required this.user});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        const SizedBox(height: 6),
        UserAvatar(name: user.fullName, size: 76),
        const SizedBox(height: 11),
        Text(
          user.fullName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: t.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 12.5,
              color: t.textSecondary),
        ),
        const SizedBox(height: 11),
        BrandChip(label: roleLabel(l10n, user.role).toUpperCase()),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 2),
        child: EyebrowLabel(text, color: context.tokens.textSecondary),
      );
}

class _IdChip extends StatelessWidget {
  final int id;
  final VoidCallback onCopied;
  const _IdChip({required this.id, required this.onCopied});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: onCopied,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: t.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$id',
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: t.textPrimary),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LanguageOption(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AppCard(
      nested: true,
      radius: AppMetrics.radiusSm,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: t.textPrimary),
            ),
          ),
          if (selected) Icon(Icons.check_rounded, size: 18, color: t.accent),
        ],
      ),
    );
  }
}
