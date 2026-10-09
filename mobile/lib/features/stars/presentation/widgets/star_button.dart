import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/models/star_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/stars/presentation/bloc/stars_bloc.dart';
import 'package:real_estate_crm/features/stars/presentation/widgets/star_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// A star glyph the size of a header icon: filled in the gold accent when
/// starred, an outline in the header's grey when not.
class StarButton extends StatelessWidget {
  final bool starred;
  final VoidCallback onPressed;

  const StarButton({super.key, required this.starred, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final label = starred ? l10n.starsUnstar : l10n.starsStar;
    final tile = SizedBox(
      width: AppMetrics.minHitTarget,
      height: AppMetrics.minHitTarget,
      child: Center(
        child: Icon(
          starred ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 21,
          color: starred ? t.accent : t.textSecondary,
        ),
      ),
    );

    return MergeSemantics(
      child: Semantics(
        button: true,
        toggled: starred,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppMetrics.minHitTarget / 2),
            onTap: onPressed,
            child: Tooltip(message: label, child: tile),
          ),
        ),
      ),
    );
  }
}

/// The star in a client's, a listing's or a deal's header. It flips the
/// moment it is tapped and flips back, with a message, if the server says no.
///
/// It reads the app-wide [StarsBloc] and draws nothing where none is
/// provided.
class StarToggle extends StatefulWidget {
  final StarType type;
  final int id;

  /// What the Starred list shows for it until the server answers.
  final String title;
  final String? subtitle;

  const StarToggle({
    super.key,
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
  });

  @override
  State<StarToggle> createState() => _StarToggleState();
}

class _StarToggleState extends State<StarToggle> {
  StarsBloc? _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = context.read<StarsBloc?>();
    if (!identical(bloc, _bloc)) {
      _bloc = bloc;
      bloc?.ensureLoaded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = _bloc;
    if (bloc == null) return const SizedBox.shrink();
    final key = StarKey(widget.type, widget.id);

    return BlocConsumer<StarsBloc, StarsState>(
      bloc: bloc,
      listenWhen: (prev, curr) =>
          isNewStarFailure(prev, curr) && curr.writeFailure!.key == key,
      listener: (context, state) =>
          showStarFailure(context, state.writeFailure!),
      buildWhen: (prev, curr) => prev.isStarred(key) != curr.isStarred(key),
      builder: (context, state) => StarButton(
        key: const ValueKey('star-toggle'),
        starred: state.isStarred(key),
        onPressed: () => bloc.add(StarsToggleEvent(key,
            title: widget.title, subtitle: widget.subtitle)),
      ),
    );
  }
}
