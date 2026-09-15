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
import com.crm.realestate.specification.MeetingSpecification;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
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
        return findVisible(MeetingSpecification.build(null, null, null), Sort.unsorted())
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<UpcomingMeetingResponse> getAllUpcoming() {
        LocalDateTime now = LocalDateTime.now();
        Specification<Meeting> upcoming = (root, query, cb) -> cb.and(
                cb.isFalse(root.get("completed")),
                cb.greaterThan(root.get("scheduledAt"), now));
        return findVisible(upcoming, Sort.by("scheduledAt"))
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
        return findVisible(MeetingSpecification.build(agentId, null, null), Sort.unsorted())
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<MeetingResponse> getUpcoming(Long agentId) {
        LocalDateTime now  = LocalDateTime.now();
        LocalDateTime week = now.plusDays(7);
        Specification<Meeting> thisWeek = MeetingSpecification.build(agentId, null, null)
                .and((root, query, cb) -> cb.between(root.get("scheduledAt"), now, week));
        return findVisible(thisWeek, Sort.by("scheduledAt"))
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public MeetingResponse getById(Long id) {
        return toResponse(findVisibleById(id, securityUtils.getCurrentUser()));
    }

    @Transactional
    public MeetingResponse create(MeetingRequest request) {
        Meeting meeting = new Meeting();
        mapRequestToEntity(request, meeting, securityUtils.getCurrentUser());
        return toResponse(meetingRepository.save(meeting));
    }

    @Transactional
    public MeetingResponse update(Long id, MeetingRequest request) {
        User currentUser = securityUtils.getCurrentUser();
        Meeting meeting = findVisibleById(id, currentUser);
        mapRequestToEntity(request, meeting, currentUser);
        return toResponse(meetingRepository.save(meeting));
    }

    @Transactional
    public MeetingResponse markCompleted(Long id) {
        User currentUser = securityUtils.getCurrentUser();
        Meeting meeting = findVisibleById(id, currentUser);
        meeting.setCompleted(true);
        return toResponse(meetingRepository.save(meeting));
    }

    @Transactional
    public void delete(Long id) {
        User currentUser = securityUtils.getCurrentUser();
        Meeting meeting = findVisibleById(id, currentUser);
        meetingRepository.delete(meeting);
    }


    private List<Meeting> findVisible(Specification<Meeting> filter, Sort sort) {
        User currentUser = securityUtils.getCurrentUser();
        return meetingRepository.findAll(filter.and(scopeService.visibleTo(currentUser)), sort);
    }

    /** Someone else's meeting reads as missing, so its existence is not confirmed either. */
    private Meeting findVisibleById(Long id, User currentUser) {
        Meeting meeting = meetingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Meeting not found with id: " + id));
        if (!scopeService.canSee(currentUser, meeting.getTeam(), meeting.getAgent())) {
            throw new ResourceNotFoundException("Meeting not found with id: " + id);
        }
        return meeting;
    }

    /**
     * A meeting lives in its client's agency, and the deal it is about has to come from there too.
     *
     * <p>A new meeting goes to whoever books it. Only an admin may name another agent, who must work
     * in the client's team. Rescheduling never changes hands on its own.
     */
    private void mapRequestToEntity(MeetingRequest request, Meeting meeting, User currentUser) {
        boolean isNew = meeting.getId() == null;
        meeting.setTitle(request.getTitle());
        meeting.setDescription(request.getDescription());
        meeting.setScheduledAt(request.getScheduledAt());
        meeting.setLocation(request.getLocation());

        Client client = clientRepository.findById(request.getClientId())
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Client not found with id: " + request.getClientId()));
        if (!scopeService.canSee(currentUser, client.getTeam(), client.getAgent())) {
            throw new ResourceNotFoundException("Client not found with id: " + request.getClientId());
        }
        meeting.setClient(client);
        meeting.setTeam(client.getTeam());

        if (scopeService.isAdmin(currentUser) && request.getAgentId() != null) {
            User agent = userRepository.findById(request.getAgentId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Agent not found with id: " + request.getAgentId()));
            scopeService.requireSameTeam(client.getTeam(), agent.getTeam(), "Agent");
            meeting.setAgent(agent);
        } else if (isNew) {
            meeting.setAgent(currentUser);
        }

        if (request.getDealId() != null) {
            Deal deal = dealRepository.findById(request.getDealId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Deal not found with id: " + request.getDealId()));
            if (!scopeService.canSee(currentUser, deal.getTeam(), deal.getAgent())) {
                throw new ResourceNotFoundException("Deal not found with id: " + request.getDealId());
            }
            scopeService.requireSameTeam(client.getTeam(), deal.getTeam(), "Deal");
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
