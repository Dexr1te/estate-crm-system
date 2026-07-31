import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_tokens.dart';
import 'package:real_estate_crm/core/widgets/app_card.dart';
import 'package:real_estate_crm/core/widgets/app_text.dart';

enum FieldSkin { page, card }

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final FieldSkin skin;
  final int maxLines;
  final int? minLines;
  final bool enabled;
  final TextInputAction? textInputAction;
  final bool autofocus;

  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.icon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.validator,
    this.onSubmitted,
    this.onChanged,
    this.skin = FieldSkin.card,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.textInputAction,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final onPage = skin == FieldSkin.page;

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
          borderSide: onPage || color == t.primary || color == t.dangerText
              ? BorderSide(color: color, width: width)
              : BorderSide.none,
        );

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      enabled: enabled,
      autofocus: autofocus,
      textInputAction: textInputAction,
      style: TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 13.5,
        color: t.textPrimary,
      ),
      cursorColor: t.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            fontFamily: AppFonts.sans, fontSize: 13.5, color: t.textHint),
        filled: true,
        fillColor: onPage ? t.surface : t.surfaceVariant,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        prefixIcon: icon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 14, right: 11),
                child: Icon(icon, size: 18, color: t.textHint),
              ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix,
        border: border(t.border),
        enabledBorder: border(t.border),
        focusedBorder: border(t.primary, 1.5),
        errorBorder: border(t.dangerText),
        focusedErrorBorder: border(t.dangerText, 1.5),
        errorStyle: TextStyle(
            fontFamily: AppFonts.sans, fontSize: 11, color: t.dangerText),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const FieldLabel(this.text, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        required ? '$text *' : text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: t.textSecondary),
      ),
    );
  }
}

class LabelledField extends StatelessWidget {
  final String label;
  final bool required;
  final Widget child;
  const LabelledField({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [FieldLabel(label, required: required), child],
      );
}

class PickerField extends StatelessWidget {
  final String? value;
  final String placeholder;
  final VoidCallback onTap;
  final IconData trailingIcon;

  const PickerField({
    super.key,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.trailingIcon = Icons.keyboard_arrow_down_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final hasValue = value != null && value!.isNotEmpty;

    return Material(
      color: t.surfaceVariant,
      borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasValue ? value! : placeholder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 13,
                    fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                    color: hasValue ? t.textPrimary : t.textHint,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(trailingIcon, size: 18, color: t.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class FormSectionCard extends StatelessWidget {
  final String? eyebrow;
  final List<Widget> children;
  final double gap;

  const FormSectionCard({
    super.key,
    this.eyebrow,
    required this.children,
    this.gap = 9,
  });

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (eyebrow != null) ...[
              EyebrowLabel(eyebrow!),
              const SizedBox(height: 12),
            ],
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: gap),
              children[i],
            ],
          ],
        ),
      );
}
