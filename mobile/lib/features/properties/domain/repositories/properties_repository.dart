import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';
import 'package:real_estate_crm/features/properties/domain/map_area.dart';

abstract class PropertiesRepository {
  Future<PagedResponse<PropertyResponse>> getProperties({
    PropertyStatus? status,
    PropertyType? type,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? search,
    int page,
    int size,
  });

  /// The listings with a pin inside [area] that the other filters let
  /// through: what the map draws. At most [size]; the rest wait for a zoom.
  Future<PagedResponse<PropertyResponse>> getPropertiesInArea(
    MapArea area, {
    PropertyStatus? status,
    PropertyType? type,
    String? search,
    int size,
  });

  /// The listings the map cannot show because nobody dropped a pin yet, under
  /// the same filters. Its `totalElements` is the map's "no location" count.
  Future<PagedResponse<PropertyResponse>> getPropertiesWithoutLocation({
    PropertyStatus? status,
    PropertyType? type,
    String? search,
    int page,
    int size,
  });

  Future<List<PropertyResponse>> getAllProperties();

  /// The agency's listings still on the market whose seller agreement ends
  /// within two weeks or has ended, soonest first.
  Future<List<PropertyResponse>> getMandatesEnding();

  Future<PropertyResponse> getProperty(int id);

  Future<PropertyResponse> createProperty(Map<String, dynamic> data);

  Future<PropertyResponse> updateProperty(int id, Map<String, dynamic> data);

  Future<PropertyResponse> updatePropertyStatus(int id, PropertyStatus status);

  Future<void> deleteProperty(int id);

  Future<List<ClientMatch>> getInterested(int id);

  Future<List<MeetingResponse>> getViewings(int id);

  Future<List<PropertyPriceChange>> getPriceHistory(int id);

  /// How this listing's price per m² compares with the agency's own book.
  Future<PriceInsight> getPriceInsightFor(int id);

  /// The same for figures typed into the form, before the listing is saved.
  Future<PriceInsight> getPriceInsight({
    required String city,
    required PropertyType type,
    int? rooms,
    double? areaSqm,
    int? excludeId,
  });

  Future<PropertyShareLink> getShareLink(int id);

  /// The listing's working link, made on the server if it has none yet.
  Future<PropertyShareLink> createShareLink(int id);

  Future<void> revokeShareLink(int id);

  Future<List<PropertyPhoto>> getPhotos(int id);

  Future<PropertyPhoto> addPhoto(int id, String path, String name);

  Future<List<int>> getPhotoBytes(int id, int photoId);

  Future<List<PropertyPhoto>> reorderPhotos(int id, List<int> photoIds);

  Future<List<int>> getCoverBytes(int id);

  Future<void> deletePhoto(int id, int photoId);
}
