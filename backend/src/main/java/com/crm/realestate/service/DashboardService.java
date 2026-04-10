package com.crm.realestate.service;

import com.crm.realestate.dto.response.DashboardSummary;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DashboardService {

    private final DealRepository    dealRepository;
    private final ClientRepository  clientRepository;
    private final MeetingRepository meetingRepository;

    public DashboardSummary getSummary() {
        long totalDeals   = dealRepository.count();
        long closedDeals  = dealRepository.findByStatus(DealStatus.CLOSED_WON).size()
                          + dealRepository.findByStatus(DealStatus.CLOSED_LOST).size();
        long activeDeals  = totalDeals - closedDeals;
        long totalClients = clientRepository.count();
        long upcomingMeetings = meetingRepository.findAllUpcoming(LocalDateTime.now()).size();

        return DashboardSummary.builder()
                .totalDeals(totalDeals)
                .activeDeals(activeDeals)
                .closedDeals(closedDeals)
                .totalClients(totalClients)
                .upcomingMeetings(upcomingMeetings)
                .build();
    }
}