import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/app_bottom_sheet.dart';
import 'package:real_estate_crm/core/widgets/app_card.dart';
import 'package:real_estate_crm/core/widgets/app_field.dart';
import 'package:real_estate_crm/core/widgets/empty_state.dart';

/// One selectable row in an [showEntityPicker] sheet.
class PickerItem {
  final int id;
  final String title;
  final String? subtitle;
  const PickerItem({required this.id, required this.title, this.subtitle});
}

/// A searchable bottom sheet for choosing a client, agent or property.
///
/// Shared by the deal and meeting forms, which previously carried a copy each.
Future<PickerItem?> showEntityPicker(
  BuildContext context, {
  required String title,
  required List<PickerItem> items,
  required String searchHint,
  required String emptyLabel,
  int? selectedId,
}) =>
    showAppBottomSheet<PickerItem>(
      context,
      title: title,
      builder: (_) => _PickerBody(
        items: items,
        selectedId: selectedId,
        searchHint: searchHint,
        emptyLabel: emptyLabel,
      ),
    );

class _PickerBody extends StatefulWidget {
  final List<PickerItem> items;
  final int? selectedId;
  final String searchHint;
  final String emptyLabel;

  const _PickerBody({
    required this.items,
    required this.selectedId,
    required this.searchHint,
    required this.emptyLabel,
  });

  @override
  State<_PickerBody> createState() => _PickerBodyState();
}

class _PickerBodyState extends State<_PickerBody> {
  final _searchCtrl = TextEditingController();
  late List<PickerItem> _filtered = widget.items;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.items
          : widget.items
              .where((i) =>
                  i.title.toLowerCase().contains(q) ||
                  (i.subtitle?.toLowerCase().contains(q) ?? false) ||
                  '${i.id}'.contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextField(
          controller: _searchCtrl,
          skin: FieldSkin.card,
          hint: widget.searchHint,
          icon: Icons.search_rounded,
        ),
        const SizedBox(height: 12),
        if (_filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: EmptyState(
                icon: Icons.search_off_rounded, title: widget.emptyLabel),
          )
        else
          // Bounded so the sheet stays inside its 90%-height cap and the list
          // scrolls internally rather than overflowing.
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.5),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final item = _filtered[i];
                final selected = item.id == widget.selectedId;
                return AppCard(
                  nested: true,
                  radius: AppMetrics.radiusSm,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 13, vertical: 12),
                  onTap: () => Navigator.pop(context, item),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: AppFonts.sans,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: t.textPrimary),
                            ),
                            if (item.subtitle != null &&
                                item.subtitle!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                item.subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: AppFonts.sans,
                                    fontSize: 11.5,
                                    color: t.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (selected) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.check_rounded, size: 18, color: t.accent),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
