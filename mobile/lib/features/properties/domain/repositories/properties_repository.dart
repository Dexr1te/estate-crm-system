import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/models/paged_response.dart';

/// Contract for property data access.
abstract class PropertiesRepository {
  /// A single page of properties (backend paginates when filters/paging sent).
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

  /// Full unpaged list, for pickers.
  Future<List<PropertyResponse>> getAllProperties();

  Future<PropertyResponse> getProperty(int id);

  Future<PropertyResponse> createProperty(Map<String, dynamic> data);

  Future<PropertyResponse> updateProperty(int id, Map<String, dynamic> data);

  Future<PropertyResponse> updatePropertyStatus(int id, PropertyStatus status);

  Future<void> deleteProperty(int id);
}
