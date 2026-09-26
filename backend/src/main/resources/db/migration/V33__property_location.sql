-- V33__property_location.sql
--
-- Where a listing stands. Agents think in neighbourhoods and buyers ask what is
-- near the park; an address in free text answers neither, so a listing can now
-- carry a point the app puts on a map.
--
-- Both nullable: every listing entered before this has no point, and the app
-- has no geocoder, so a point exists only where an agent dropped a pin. The two
-- are set together or not at all; the check says so in the database as well as
-- in the API.
--
-- DOUBLE PRECISION matches the entity's Double, as area_sqm does. Six decimal
-- places are ten centimetres; a double carries far more than a pin needs.

ALTER TABLE properties ADD COLUMN latitude  DOUBLE PRECISION;
ALTER TABLE properties ADD COLUMN longitude DOUBLE PRECISION;

ALTER TABLE properties ADD CONSTRAINT chk_properties_location CHECK (
    (latitude IS NULL AND longitude IS NULL)
    OR (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
);

-- The map asks for the listings inside the visible rectangle.
CREATE INDEX idx_properties_location ON properties(latitude, longitude);
