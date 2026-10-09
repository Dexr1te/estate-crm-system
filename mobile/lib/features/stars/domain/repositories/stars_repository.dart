import 'package:real_estate_crm/core/models/star_models.dart';

/// The signed-in person's starred records. Stars are theirs alone and follow
/// them from phone to phone.
abstract class StarsRepository {
  /// The starred records they can still see, newest first.
  Future<List<StarredItem>> getStars();

  /// Stars a record they can see; starring it again answers with the same
  /// star. A record they cannot see is not found.
  Future<StarredItem> star(StarKey key);

  /// Takes the star off; no star there is not an error.
  Future<void> unstar(StarKey key);
}
