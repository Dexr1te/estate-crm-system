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
import com.crm.realestate.security.SecurityUtils;
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
    private final SecurityUtils      securityUtils;
    private final ScopeService       scopeService;

    public List<MeetingResponse> getAll() {
        User currentUser = securityUtils.getCurrentUser();
        List<Long> allowedAgentIds = scopeService.getAllowedAgentIds(currentUser);
        if (allowedAgentIds == null) {
            return meetingRepository.findAll().stream().map(this::toResponse).collect(Collectors.toList());
        }
        return meetingRepository.findByAgentIdIn(allowedAgentIds)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<UpcomingMeetingResponse> getAllUpcoming() {
        User currentUser = securityUtils.getCurrentUser();
        List<Long> allowedAgentIds = scopeService.getAllowedAgentIds(currentUser);
        if (allowedAgentIds == null) {
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
        return meetingRepository.findAllUpcomingForAgents(allowedAgentIds, LocalDateTime.now())
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
        User currentUser = securityUtils.getCurrentUser();
        if (!scopeService.isWithinScope(currentUser, agentId)) {
            throw new ResourceNotFoundException("Meeting not found");
        }
        return meetingRepository.findByAgentId(agentId)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<MeetingResponse> getUpcoming(Long agentId) {
        User currentUser = securityUtils.getCurrentUser();
        if (!scopeService.isWithinScope(currentUser, agentId)) {
            throw new ResourceNotFoundException("Meeting not found");
        }
        LocalDateTime now  = LocalDateTime.now();
        LocalDateTime week = now.plusDays(7);
        return meetingRepository.findUpcomingByAgent(agentId, now, week)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public MeetingResponse getById(Long id) {
        Meeting meeting = findById(id);
        User currentUser = securityUtils.getCurrentUser();
        if (!scopeService.isWithinScope(currentUser, meeting.getAgent() == null ? null : meeting.getAgent().getId())) {
            throw new ResourceNotFoundException("Meeting not found");
        }
        return toResponse(meeting);
    }

    @Transactional
    public MeetingResponse create(MeetingRequest request) {
        Meeting meeting = new Meeting();
        mapRequestToEntity(request, meeting, securityUtils.getCurrentUser());
        return toResponse(meetingRepository.save(meeting));
    }

    @Transactional
    public MeetingResponse update(Long id, MeetingRequest request) {
        Meeting meeting = findById(id);
        User currentUser = securityUtils.getCurrentUser();
        if (!scopeService.isWithinScope(currentUser, meeting.getAgent() == null ? null : meeting.getAgent().getId())) {
            throw new ResourceNotFoundException("Meeting not found");
        }
        mapRequestToEntity(request, meeting, currentUser);
        return toResponse(meetingRepository.save(meeting));
    }

    @Transactional
    public MeetingResponse markCompleted(Long id) {
        Meeting meeting = findById(id);
        User currentUser = securityUtils.getCurrentUser();
        if (!scopeService.isWithinScope(currentUser, meeting.getAgent() == null ? null : meeting.getAgent().getId())) {
            throw new ResourceNotFoundException("Meeting not found");
        }
        meeting.setCompleted(true);
        return toResponse(meetingRepository.save(meeting));
    }

    @Transactional
    public void delete(Long id) {
        Meeting meeting = findById(id);
        User currentUser = securityUtils.getCurrentUser();
        if (!scopeService.isWithinScope(currentUser, meeting.getAgent() == null ? null : meeting.getAgent().getId())) {
            throw new ResourceNotFoundException("Meeting not found");
        }
        meetingRepository.delete(meeting);
    }


    private Meeting findById(Long id) {
        return meetingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Meeting not found with id: " + id));
    }

    private void mapRequestToEntity(MeetingRequest request, Meeting meeting, User currentUser) {
        meeting.setTitle(request.getTitle());
        meeting.setDescription(request.getDescription());
        meeting.setScheduledAt(request.getScheduledAt());
        meeting.setLocation(request.getLocation());

        User agent;
        if (currentUser.getRole() == com.crm.realestate.enums.Role.ADMIN && request.getAgentId() != null) {
            agent = userRepository.findById(request.getAgentId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Agent not found with id: " + request.getAgentId()));
        } else {
            agent = currentUser;
        }
        meeting.setAgent(agent);

        Client client = clientRepository.findById(request.getClientId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Client not found with id: " + request.getClientId()));
        if (!scopeService.isWithinScope(currentUser, client.getAgent() == null ? null : client.getAgent().getId())) {
            throw new ResourceNotFoundException("Client not found");
        }
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
