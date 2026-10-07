package com.crm.realestate.service;

import com.crm.realestate.dto.request.PartnerRequest;
import com.crm.realestate.dto.response.PartnerHandoffResponse;
import com.crm.realestate.dto.response.PartnerReferralResponse;
import com.crm.realestate.dto.response.PartnerResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Partner;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.PartnerKind;
import com.crm.realestate.enums.ReferralFeeType;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.PartnerHandoffRepository;
import com.crm.realestate.repository.PartnerRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

/**
 * The agency's partners: brokers, notaries, appraisers, developers, other agencies.
 *
 * <p><b>Who sees what.</b> A partner is the agency's, not an agent's: everyone in the agency sees
 * every partner whatever their data scope, and another agency is told it does not exist. What a
 * partner's referrals came to is counted over the clients the caller sees, so an agent on their
 * own records sees their own share and a manager the agency's.
 *
 * <p><b>Who changes what.</b> Anyone in the agency may add a partner. Whoever added it, a manager
 * or an admin may change or delete it.
 *
 * <p><b>Deleting.</b> Refused (409 PARTNER_IN_USE) while any client of the agency says the partner
 * sent them or was sent to them, whoever holds that client: the referral is where a client came
 * from and the fee is owed on it, and a hand-off is part of the client's story. Deleting a partner
 * nothing points at is final. A partner who is no longer worked with can be renamed or noted so.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PartnerService {

    private final PartnerRepository partnerRepository;
    private final PartnerHandoffRepository handoffRepository;
    private final ClientRepository clientRepository;
    private final ScopeService scopeService;
    private final SecurityUtils securityUtils;

    // Reading -----------------------------------------------------------------------------

    /** The agency's partners by name, narrowed by kind and by a word in the name, company or phone. */
    public List<PartnerResponse> list(PartnerKind kind, String search) {
        User user = securityUtils.getCurrentUser();
        Specification<Partner> spec = inAgencyOf(user);
        if (kind != null) {
            spec = spec.and((root, query, cb) -> cb.equal(root.get("kind"), kind));
        }
        String word = strip(search);
        if (word != null) {
            String like = "%" + word.toLowerCase(Locale.ROOT).replace("%", "\\%").replace("_", "\\_") + "%";
            spec = spec.and((root, query, cb) -> cb.or(
                    cb.like(cb.lower(root.get("name")), like, '\\'),
                    cb.like(cb.lower(cb.coalesce(root.get("company"), "")), like, '\\'),
                    cb.like(cb.lower(cb.coalesce(root.get("phone"), "")), like, '\\')));
        }
        List<Partner> partners = partnerRepository.findAll(spec,
                Sort.by(Sort.Order.asc("name").ignoreCase(), Sort.Order.asc("id")));
        return toResponses(partners, user);
    }

    public PartnerResponse get(Long id) {
        User user = securityUtils.getCurrentUser();
        return toResponses(List.of(requireVisible(id, user)), user).get(0);
    }

    /** The clients the partner sent that the caller sees, newest first, each with its fee. */
    public List<PartnerReferralResponse> referrals(Long id) {
        User user = securityUtils.getCurrentUser();
        Partner partner = requireVisible(id, user);
        Specification<Client> referred = (root, query, cb) -> cb.equal(root.get("referredBy").get("id"), partner.getId());
        List<Client> clients = clientRepository.findAll(referred.and(scopeService.visibleTo(user)),
                Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("id")));
        Map<Long, List<Deal>> won = new HashMap<>();
        if (!clients.isEmpty()) {
            for (Deal deal : partnerRepository.findWonDealsOfClients(clients.stream().map(Client::getId).toList())) {
                won.computeIfAbsent(deal.getClient().getId(), k -> new java.util.ArrayList<>()).add(deal);
            }
        }
        return clients.stream().map(c -> {
            Tally tally = new Tally();
            won.getOrDefault(c.getId(), List.of()).forEach(d -> tally.add(ReferralFee.on(partner, d)));
            return PartnerReferralResponse.builder()
                    .clientId(c.getId())
                    .fullName(c.getFullName())
                    .type(c.getType())
                    .agentId(c.getAgent() == null ? null : c.getAgent().getId())
                    .agentName(ChangeSnapshot.person(c.getAgent()))
                    .wonDeals(tally.deals)
                    .feeOwed(tally.fees)
                    .wonDealsWithoutCommission(tally.unknown)
                    .createdAt(c.getCreatedAt())
                    .build();
        }).toList();
    }

    /** The clients sent to the partner that the caller sees, the latest first. */
    public List<PartnerHandoffResponse> handoffs(Long id) {
        User user = securityUtils.getCurrentUser();
        Partner partner = requireVisible(id, user);
        return handoffRepository.findByPartnerLatestFirst(partner.getId(), seesAll(user), user.getId())
                .stream().map(PartnerHandoffService::toResponse).toList();
    }

    // Changing ----------------------------------------------------------------------------

    @Transactional
    public PartnerResponse create(PartnerRequest request) {
        User user = securityUtils.getCurrentUser();
        if (user.getTeam() == null) {
            throw new BusinessException(HttpStatus.FORBIDDEN, "TEAM_REQUIRED",
                    "Join or create an agency to add partners");
        }
        Partner partner = Partner.builder().team(user.getTeam()).createdBy(user).build();
        apply(request, partner);
        return toResponses(List.of(partnerRepository.save(partner)), user).get(0);
    }

    @Transactional
    public PartnerResponse update(Long id, PartnerRequest request) {
        User user = securityUtils.getCurrentUser();
        Partner partner = requireEditable(id, user);
        apply(request, partner);
        return toResponses(List.of(partnerRepository.save(partner)), user).get(0);
    }

    @Transactional
    public void delete(Long id) {
        User user = securityUtils.getCurrentUser();
        Partner partner = requireEditable(id, user);
        if (partnerRepository.hasReferrals(partner.getId()) || handoffRepository.existsByPartnerId(partner.getId())) {
            throw new BusinessException(HttpStatus.CONFLICT, "PARTNER_IN_USE",
                    "Clients are linked to this partner, so it cannot be deleted");
        }
        partnerRepository.delete(partner);
    }

    // For the client card -----------------------------------------------------------------

    /**
     * The partner a client of {@code team} may be linked to: one of that agency's own. Any other
     * reads as missing, the same as opening it would.
     */
    public Partner requireInTeam(Long partnerId, Team team) {
        Partner partner = partnerRepository.findById(partnerId)
                .orElseThrow(() -> new ResourceNotFoundException("Partner not found with id: " + partnerId));
        if (team == null || partner.getTeam() == null || !Objects.equals(team.getId(), partner.getTeam().getId())) {
            throw new ResourceNotFoundException("Partner not found with id: " + partnerId);
        }
        return partner;
    }

    private void apply(PartnerRequest request, Partner partner) {
        String name = strip(request.getName());
        if (name == null) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "NAME_REQUIRED", "Name is required");
        }
        ReferralFeeType type = request.getFeeType();
        BigDecimal value = request.getFeeValue();
        if ((type == null) != (value == null)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_REFERRAL_FEE",
                    "A referral fee needs both its kind and its value");
        }
        if (type == ReferralFeeType.PERCENT
                && (value.signum() <= 0 || value.compareTo(BigDecimal.valueOf(100)) > 0)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_REFERRAL_FEE",
                    "A referral fee in percent is above 0 and at most 100");
        }
        if (type == ReferralFeeType.FIXED
                && (value.signum() <= 0 || value.compareTo(new BigDecimal("9999999999999")) > 0)) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "INVALID_REFERRAL_FEE",
                    "A fixed referral fee is above 0");
        }
        partner.setName(name);
        partner.setCompany(strip(request.getCompany()));
        partner.setKind(request.getKind());
        partner.setPhone(strip(request.getPhone()));
        partner.setEmail(strip(request.getEmail()));
        partner.setNote(strip(request.getNote()));
        partner.setFeeType(type);
        partner.setFeeValue(value);
    }

    /** Partners of the caller's agency; everyone's for an admin, nobody's outside an agency. */
    private Specification<Partner> inAgencyOf(User user) {
        return (root, query, cb) -> {
            if (scopeService.isAdmin(user)) {
                return cb.conjunction();
            }
            Long teamId = scopeService.teamIdOf(user);
            return teamId == null ? cb.disjunction() : cb.equal(root.get("team").get("id"), teamId);
        };
    }

    private Partner requireVisible(Long id, User user) {
        Partner partner = partnerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Partner not found with id: " + id));
        if (!canSee(partner, user)) {
            throw new ResourceNotFoundException("Partner not found with id: " + id);
        }
        return partner;
    }

    private boolean canSee(Partner partner, User user) {
        if (scopeService.isAdmin(user)) {
            return true;
        }
        Long teamId = scopeService.teamIdOf(user);
        return teamId != null && partner.getTeam() != null && teamId.equals(partner.getTeam().getId());
    }

    private Partner requireEditable(Long id, User user) {
        Partner partner = requireVisible(id, user);
        if (!canEdit(partner, user)) {
            throw new AccessDeniedException("Only whoever added this partner or a manager can change it");
        }
        return partner;
    }

    private boolean canEdit(Partner partner, User user) {
        return scopeService.isAdmin(user) || scopeService.isManager(user)
                || (partner.getCreatedBy() != null && Objects.equals(partner.getCreatedBy().getId(), user.getId()));
    }

    private boolean seesAll(User user) {
        return scopeService.isAdmin(user) || scopeService.seesWholeTeam(user);
    }

    /** Each partner with its numbers: three statements for the whole list. */
    private List<PartnerResponse> toResponses(List<Partner> partners, User user) {
        if (partners.isEmpty()) {
            return List.of();
        }
        List<Long> ids = partners.stream().map(Partner::getId).toList();
        Map<Long, Partner> byId = new HashMap<>();
        partners.forEach(p -> byId.put(p.getId(), p));
        boolean whole = seesAll(user);

        Map<Long, Long> referred = new HashMap<>();
        for (Object[] row : partnerRepository.countReferred(ids, whole, user.getId())) {
            referred.put((Long) row[0], ((Number) row[1]).longValue());
        }
        Map<Long, Tally> tallies = new HashMap<>();
        for (Object[] row : partnerRepository.findWonDeals(ids, whole, user.getId())) {
            Long partnerId = (Long) row[1];
            tallies.computeIfAbsent(partnerId, k -> new Tally()).add(ReferralFee.on(byId.get(partnerId), (Deal) row[0]));
        }
        Map<Long, long[]> handoffs = new HashMap<>();
        for (Object[] row : handoffRepository.countByPartner(ids, whole, user.getId())) {
            handoffs.put((Long) row[0], new long[]{((Number) row[1]).longValue(),
                    row[2] == null ? 0 : ((Number) row[2]).longValue()});
        }

        return partners.stream().map(p -> {
            Tally tally = tallies.getOrDefault(p.getId(), new Tally());
            long[] sent = handoffs.getOrDefault(p.getId(), new long[]{0, 0});
            return PartnerResponse.builder()
                    .id(p.getId())
                    .name(p.getName())
                    .company(p.getCompany())
                    .kind(p.getKind())
                    .phone(p.getPhone())
                    .email(p.getEmail())
                    .note(p.getNote())
                    .feeType(p.getFeeType())
                    .feeValue(p.getFeeValue())
                    .createdById(p.getCreatedBy() == null ? null : p.getCreatedBy().getId())
                    .createdByName(ChangeSnapshot.person(p.getCreatedBy()))
                    .canEdit(canEdit(p, user))
                    .createdAt(p.getCreatedAt())
                    .referredClients(referred.getOrDefault(p.getId(), 0L))
                    .wonDeals(tally.deals)
                    .feesOwed(tally.fees)
                    .wonDealsWithoutCommission(tally.unknown)
                    .handoffs(sent[0])
                    .openHandoffs(sent[1])
                    .build();
        }).toList();
    }

    /** Won deals and their fees, with the deals whose fee is unknown counted apart. */
    private static final class Tally {
        long deals;
        long unknown;
        BigDecimal fees = BigDecimal.ZERO.setScale(2);

        void add(BigDecimal fee) {
            deals++;
            if (fee == null) {
                unknown++;
            } else {
                fees = fees.add(fee);
            }
        }
    }

    static String strip(String value) {
        if (value == null) {
            return null;
        }
        String stripped = value.strip();
        return stripped.isEmpty() ? null : stripped;
    }
}
