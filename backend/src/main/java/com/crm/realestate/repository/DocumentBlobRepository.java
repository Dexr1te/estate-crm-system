package com.crm.realestate.repository;

import com.crm.realestate.entity.DocumentBlob;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DocumentBlobRepository extends JpaRepository<DocumentBlob, String> {
}
