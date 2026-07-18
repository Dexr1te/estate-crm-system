import 'package:real_estate_crm/core/models/models.dart';

/// Contract for property data access.
abstract class PropertiesRepository {
  Future<List<PropertyResponse>> getProperties({
    PropertyStatus? status,
    PropertyType? type,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? search,
  });

  Future<PropertyResponse> getProperty(int id);

  Future<PropertyResponse> createProperty(Map<String, dynamic> data);

  Future<PropertyResponse> updateProperty(int id, Map<String, dynamic> data);

  Future<PropertyResponse> updatePropertyStatus(int id, PropertyStatus status);

  Future<void> deleteProperty(int id);
}
