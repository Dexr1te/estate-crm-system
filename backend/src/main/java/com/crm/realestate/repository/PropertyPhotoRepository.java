package com.crm.realestate.repository;

import com.crm.realestate.entity.PropertyPhoto;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PropertyPhotoRepository extends JpaRepository<PropertyPhoto, Long> {

    List<PropertyPhoto> findByPropertyIdOrderBySortOrderAscIdAsc(Long propertyId);

    /** The next free position in a listing's gallery. */
    int countByPropertyId(Long propertyId);
}
