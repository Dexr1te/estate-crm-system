package com.crm.realestate.service;

import com.crm.realestate.dto.request.PartnerHandoffRequest;
import com.crm.realestate.dto.response.PartnerHandoffResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Partner;
import com.crm.realestate.entity.PartnerHandoff;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.PartnerHandoffStatus;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.PartnerHandoffRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Objects;

/**
 * Clients sent to a partner: to a broker for a mortgage, to a notary for the papers. A hand-off is
 * the client's, so it sits behind the client's wall: whoever may read the client may list, add,
 * move along and take back its hand-offs, and nobody else learns it exists. The partner is always
 * one of the client's own agency's.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PartnerHandoffService {

    private final PartnerHandoffRepository handoffRepository;
    private final ClientService clientService;
    private final PartnerService partnerService;
    private final SecurityUtils securityUtils;

    public List<PartnerHandoffResponse> forClient(Long clientId) {
        User user = securityUtils.getCurrentUser();
        Client client = clientService.requireVisible(clientId, user);
        return handoffRepository.findByClientLatestFirst(client.getId()).stream()
                .map(PartnerHandoffService::toResponse).toList();
    }

    @Transactional
    public PartnerHandoffResponse create(Long clientId, PartnerHandoffRequest request) {
        User user = securityUtils.getCurrentUser();
        Client client = clientService.requireVisible(clientId, user);
        Partner partner = partnerService.requireInTeam(request.getPartnerId(), client.getTeam());
        PartnerHandoff handoff = PartnerHandoff.builder()
                .team(client.getTeam())
                .client(client)
                .partner(partner)
                .sentBy(user)
                .build();
        apply(request, handoff);
        return toResponse(handoffRepository.save(handoff));
    }

    @Transactional
    public PartnerHandoffResponse update(Long clientId, Long handoffId, PartnerHandoffRequest request) {
        User user = securityUtils.getCurrentUser();
        PartnerHandoff handoff = requireOnClient(clientId, handoffId, user);
        if (!Objects.equals(handoff.getPartner().getId(), request.getPartnerId())) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "PARTNER_CHANGE_NOT_ALLOWED",
                    "A hand-off stays with its partner; send the client to the other one instead");
        }
        apply(request, handoff);
        return toResponse(handoffRepository.save(handoff));
    }

    @Transactional
    public void delete(Long clientId, Long handoffId) {
        User user = securityUtils.getCurrentUser();
        handoffRepository.delete(requireOnClient(clientId, handoffId, user));
    }

    private PartnerHandoff requireOnClient(Long clientId, Long handoffId, User user) {
        Client client = clientService.requireVisible(clientId, user);
        PartnerHandoff handoff = handoffRepository.findById(handoffId)
                .filter(h -> Objects.equals(h.getClient().getId(), client.getId()))
                .orElseThrow(() -> new ResourceNotFoundException("Hand-off not found with id: " + handoffId));
        return handoff;
    }

    private static void apply(PartnerHandoffRequest request, PartnerHandoff handoff) {
        LocalDate today = LocalDate.now();
        LocalDate sentOn = request.getSentOn() == null ? today : request.getSentOn();
        if (sentOn.isAfter(today)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "SENT_ON_IN_FUTURE",
                    "A client cannot have been sent on a day still to come");
        }
        handoff.setSentOn(sentOn);
        handoff.setStatus(request.getStatus() == null ? PartnerHandoffStatus.SENT : request.getStatus());
        handoff.setNote(PartnerService.strip(request.getNote()));
    }

    static PartnerHandoffResponse toResponse(PartnerHandoff h) {
        Partner partner = h.getPartner();
        return PartnerHandoffResponse.builder()
                .id(h.getId())
                .clientId(h.getClient().getId())
                .clientName(h.getClient().getFullName())
                .partnerId(partner.getId())
                .partnerName(partner.getName())
                .partnerCompany(partner.getCompany())
                .partnerKind(partner.getKind())
                .sentOn(h.getSentOn())
                .status(h.getStatus())
                .note(h.getNote())
                .sentById(h.getSentBy() == null ? null : h.getSentBy().getId())
                .sentByName(ChangeSnapshot.person(h.getSentBy()))
                .createdAt(h.getCreatedAt())
                .updatedAt(h.getUpdatedAt())
                .build();
    }
}
