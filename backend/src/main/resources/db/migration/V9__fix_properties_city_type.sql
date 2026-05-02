-- Fix legacy schema drift where properties.city accidentally became BYTEA
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'properties'
          AND column_name = 'city'
          AND data_type = 'bytea'
    ) THEN
        ALTER TABLE properties
            ALTER COLUMN city TYPE VARCHAR(100)
            USING CASE
                WHEN city IS NULL THEN NULL
                ELSE convert_from(city, 'UTF8')
            END;
    END IF;
END $$;
