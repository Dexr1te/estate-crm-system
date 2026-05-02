package com.crm.realestate.service;

import com.crm.realestate.dto.request.MeetingRequest;
import com.crm.realestate.dto.response.MeetingResponse;
import com.crm.realestate.dto.response.UpcomingMeetingResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.User;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MeetingService {

    private final MeetingRepository meetingRepository;
    private final UserRepository    userRepository;
    private final ClientRepository  clientRepository;
    private final DealRepository    dealRepository;

    public List<MeetingResponse> getAll() {
        return meetingRepository.findAll()
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<UpcomingMeetingResponse> getAllUpcoming() {
        return meetingRepository.findAllUpcoming(LocalDateTime.now())
                .stream()
                .map(m -> UpcomingMeetingResponse.builder()
                        .id(m.getId())
                        .title(m.getTitle())
                        .scheduledAt(m.getScheduledAt())
                        .clientName(m.getClient().getFullName())
                        .build())
                .collect(Collectors.toList());
    }    

    public List<MeetingResponse> getByAgent(Long agentId) {
        return meetingRepository.findByAgentId(agentId)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<MeetingResponse> getUpcoming(Long agentId) {
        LocalDateTime now  = LocalDateTime.now();
        LocalDateTime week = now.plusDays(7);
        return meetingRepository.findUpcomingByAgent(agentId, now, week)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public MeetingResponse getById(Long id) {
        return toResponse(findById(id));
    }

    @Transactional
    public MeetingResponse create(MeetingRequest request) {
        Meeting meeting = new Meeting();
        mapRequestToEntity(request, meeting);
        return toResponse(meetingRepository.save(meeting));
    }

    @Transactional
    public MeetingResponse update(Long id, MeetingRequest request) {
        Meeting meeting = findById(id);
        mapRequestToEntity(request, meeting);
        return toResponse(meetingRepository.save(meeting));
    }

    @Transactional
    public MeetingResponse markCompleted(Long id) {
        Meeting meeting = findById(id);
        meeting.setCompleted(true);
        return toResponse(meetingRepository.save(meeting));
    }

    @Transactional
    public void delete(Long id) {
        meetingRepository.delete(findById(id));
    }


    private Meeting findById(Long id) {
        return meetingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Meeting not found with id: " + id));
    }

    private void mapRequestToEntity(MeetingRequest request, Meeting meeting) {
        meeting.setTitle(request.getTitle());
        meeting.setDescription(request.getDescription());
        meeting.setScheduledAt(request.getScheduledAt());
        meeting.setLocation(request.getLocation());

        User agent = userRepository.findById(request.getAgentId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Agent not found with id: " + request.getAgentId()));
        meeting.setAgent(agent);

        Client client = clientRepository.findById(request.getClientId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Client not found with id: " + request.getClientId()));
        meeting.setClient(client);

        if (request.getDealId() != null) {
            Deal deal = dealRepository.findById(request.getDealId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Deal not found with id: " + request.getDealId()));
            meeting.setDeal(deal);
        } else {
            meeting.setDeal(null);
        }
    }

    private MeetingResponse toResponse(Meeting m) {
        MeetingResponse res = new MeetingResponse();
        res.setId(m.getId());
        res.setTitle(m.getTitle());
        res.setDescription(m.getDescription());
        res.setScheduledAt(m.getScheduledAt());
        res.setLocation(m.getLocation());
        res.setCompleted(m.isCompleted());
        res.setCreatedAt(m.getCreatedAt());
        res.setUpdatedAt(m.getUpdatedAt());
        res.setAgentId(m.getAgent().getId());
        res.setAgentName(m.getAgent().getFullName());
        res.setClientId(m.getClient().getId());
        res.setClientName(m.getClient().getFullName());
        if (m.getDeal() != null) {
            res.setDealId(m.getDeal().getId());
            res.setDealTitle(m.getDeal().getTitle());
        }
        return res;
    }
}
