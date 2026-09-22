-- V19__buyer_requirements.sql
--
-- What a buyer is looking for, so it lives on the client instead of in an
-- agent's head. Until now a client row held a name, a phone and free-text
-- notes, which meant the wish list was retyped into the listing filters on
-- every visit and could not be matched against anything.
--
-- Every column is nullable: a requirement nobody stated is not a requirement,
-- and a seller has none of these at all.

ALTER TABLE clients
    ADD COLUMN wanted_type    VARCHAR(30),
    ADD COLUMN wanted_city    VARCHAR(120),
    ADD COLUMN budget_min     NUMERIC(15, 2),
    ADD COLUMN budget_max     NUMERIC(15, 2),
    ADD COLUMN min_rooms      INTEGER,
    ADD COLUMN min_area_sqm   DOUBLE PRECISION;

-- Matching reads listings by city and by price, on top of the team scoping that
-- every query here carries.
CREATE INDEX idx_properties_city_price ON properties(city, price);
