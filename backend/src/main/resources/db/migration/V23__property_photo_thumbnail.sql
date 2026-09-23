-- V23__property_photo_thumbnail.sql
--
-- A second, smaller copy of each photograph, so a list of listings can show
-- what each one looks like without pulling the full-size image per row. Twenty
-- listings at two megabytes each is not a list, it is a download.
--
-- Null when the copy could not be made: the store keeps the format the phone
-- sent, and not every format can be decoded here. A listing without a thumbnail
-- falls back to its full-size photograph, which is slower but correct.

ALTER TABLE property_photos
    ADD COLUMN thumbnail_key VARCHAR(500);
