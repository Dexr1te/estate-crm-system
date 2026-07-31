/// The single place the brand typeface is named.
///
/// The design handoff calls for Sora, but Sora has no Cyrillic — with ru/kk as
/// primary UI languages that would push most of the app onto the platform
/// fallback font. [sans] is Commissioner, the closest low-contrast geometric
/// sans that covers Latin, Russian **and** Kazakh (Ә Ғ Қ Ң Ө Ұ Ү Һ І), plus
/// the ₽ and ₸ symbols.
///
/// Swapping the typeface = change this constant and the `fonts:` block in
/// pubspec.yaml. Nothing else references a family name.
class AppFonts {
  const AppFonts._();

  static const String sans = 'Commissioner';
}
