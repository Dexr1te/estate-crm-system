package com.crm.realestate.repository;

import com.crm.realestate.entity.Document;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DocumentRepository extends JpaRepository<Document, Long> {

    List<Document> findByDealId(Long dealId);

    List<Document> findByUploadedById(Long userId);
}