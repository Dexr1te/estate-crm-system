package com.crm.realestate.specification;

import com.crm.realestate.exception.BusinessException;
import org.springframework.http.HttpStatus;

/**
 * The rectangle a map is showing, in degrees. South to north, west to east; a west edge east of
 * the east edge means the rectangle crosses the antimeridian.
 */
public record MapBounds(double minLat, double maxLat, double minLng, double maxLng) {

    public static final String INVALID = "INVALID_BOUNDS";

    /**
     * The rectangle from query parameters: null when none were sent, and a 400 when only some
     * were, or any is out of range, or its south edge is north of its north edge.
     */
    public static MapBounds of(Double minLat, Double maxLat, Double minLng, Double maxLng) {
        int given = count(minLat) + count(maxLat) + count(minLng) + count(maxLng);
        if (given == 0) {
            return null;
        }
        if (given < 4) {
            throw invalid("A map rectangle needs all four of minLat, maxLat, minLng and maxLng");
        }
        if (!inRange(minLat, 90) || !inRange(maxLat, 90)) {
            throw invalid("Latitude must be between -90 and 90");
        }
        if (!inRange(minLng, 180) || !inRange(maxLng, 180)) {
            throw invalid("Longitude must be between -180 and 180");
        }
        if (minLat > maxLat) {
            throw invalid("minLat must not be greater than maxLat");
        }
        return new MapBounds(minLat, maxLat, minLng, maxLng);
    }

    private static int count(Double value) {
        return value == null ? 0 : 1;
    }

    private static boolean inRange(double value, double limit) {
        return !Double.isNaN(value) && value >= -limit && value <= limit;
    }

    private static BusinessException invalid(String message) {
        return new BusinessException(HttpStatus.BAD_REQUEST, INVALID, message);
    }
}
