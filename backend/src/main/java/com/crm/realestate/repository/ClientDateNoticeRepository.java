package com.crm.realestate.repository;

import com.crm.realestate.entity.ClientDateNotice;
import com.crm.realestate.enums.ClientDateKind;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClientDateNoticeRepository extends JpaRepository<ClientDateNotice, Long> {

    boolean existsByClientIdAndKindAndOccurrenceYear(Long clientId, ClientDateKind kind, Integer occurrenceYear);
}
