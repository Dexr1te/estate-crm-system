package com.crm.realestate.service;

import com.crm.realestate.dto.response.StarResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Star;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.StarType;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.StarRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.EnumMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Starred records: the clients, listings and deals somebody is working on right now.
 *
 * <p><b>Whose.</b> A star is one person's. Nobody else sees it, and nobody stars on somebody
 * else's behalf; every call is about the caller's own.
 *
 * <p><b>What may be starred.</b> Exactly what the caller may read: a client or a deal inside their
 * agency and their data scope, a listing inside their agency. Anything else answers as not found,
 * the same as reading it would, so a star does not confirm a record exists.
 *
 * <p><b>Twice is once.</b> Starring a starred record answers with the star already there, and
 * taking off a star that is not there is not an error, so the app can repeat either.
 *
 * <p><b>What the list shows.</b> The stars on records the caller can still see, newest first. A
 * record that was deleted, or has left the caller's agency or data scope, drops out; its star is
 * kept and shows again if the record comes back into view. Deleting a record takes everybody's
 * stars on it ({@link StarStore}). The records are read a type at a time, one query each, however
 * many stars there are.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class StarService {

    private final StarRepository starRepository;
    private final ClientRepository clientRepository;
    private final PropertyRepository propertyRepository;
    private final DealRepository dealRepository;
    private final ClientService clientService;
    private final PropertyService propertyService;
    private final DealService dealService;
    private final ScopeService scopeService;
    private final CommissionSplitStore splitStore;

    /** The caller's stars on records they can still see, newest first. */
    public List<StarResponse> list(User actor) {
        List<Star> stars = starRepository.findByUserIdOrderByCreatedAtDescIdDesc(actor.getId());
        if (stars.isEmpty()) {
            return List.of();
        }
        Map<StarType, Set<Long>> wanted = new EnumMap<>(StarType.class);
        for (Star star : stars) {
            wanted.computeIfAbsent(star.getEntityType(), t -> new LinkedHashSet<>()).add(star.getEntityId());
        }
        Map<StarType, Map<Long, Shown>> shown = new EnumMap<>(StarType.class);
        shown.put(StarType.CLIENT, visible(wanted.get(StarType.CLIENT),
                ids -> clientRepository.findAll(scopeService.<Client>visibleTo(actor).and(idIn(ids))),
                Client::getId, StarService::shown));
        shown.put(StarType.PROPERTY, visible(wanted.get(StarType.PROPERTY),
                ids -> propertyRepository.findAll(scopeService.<Property>visibleToTeam(actor).and(idIn(ids))),
                Property::getId, StarService::shown));
        shown.put(StarType.DEAL, visible(wanted.get(StarType.DEAL),
                ids -> dealRepository.findAll(splitStore.visibleTo(actor).and(idIn(ids))),
                Deal::getId, StarService::shown));
        return stars.stream()
                .map(star -> {
                    Shown record = shown.get(star.getEntityType()).get(star.getEntityId());
                    return record == null ? null : respond(star, record);
                })
                .filter(Objects::nonNull)
                .toList();
    }

    /**
     * Stars a record the caller may read, or answers with the star already on it. Anything they
     * may not read is not found.
     */
    @Transactional
    public StarResponse star(User actor, String type, Long id) {
        StarType starType = typeOf(type);
        Shown record = requireVisible(actor, starType, id);
        Star star = starRepository.findByUserIdAndEntityTypeAndEntityId(actor.getId(), starType, id)
                .orElseGet(() -> starRepository.save(Star.builder()
                        .user(actor)
                        .entityType(starType)
                        .entityId(id)
                        .build()));
        return respond(star, record);
    }

    /** Takes the caller's star off a record, if there is one. */
    @Transactional
    public void unstar(User actor, String type, Long id) {
        starRepository.deleteOne(actor.getId(), typeOf(type), id);
    }

    // Reading the records ------------------------------------------------------------------

    /** The two lines a starred record is recognised by. */
    private record Shown(String title, String subtitle) {
    }

    private Shown requireVisible(User actor, StarType type, Long id) {
        return switch (type) {
            case CLIENT -> shown(clientService.requireVisible(id, actor));
            case PROPERTY -> shown(propertyService.requireVisible(id, actor));
            case DEAL -> shown(dealService.requireVisible(id, actor));
        };
    }

    /** The records among {@code ids} the query lets through, by id; no query for no ids. */
    private static <T> Map<Long, Shown> visible(Set<Long> ids, Function<Collection<Long>, List<T>> query,
                                                Function<T, Long> idOf, Function<T, Shown> show) {
        if (ids == null || ids.isEmpty()) {
            return Map.of();
        }
        return query.apply(ids).stream().collect(Collectors.toMap(idOf, show, (a, b) -> a));
    }

    private static <T> Specification<T> idIn(Collection<Long> ids) {
        return (root, query, cb) -> root.get("id").in(ids);
    }

    private static Shown shown(Client client) {
        return new Shown(client.getFullName(), firstPresent(client.getPhone(), client.getEmail()));
    }

    private static Shown shown(Property property) {
        return new Shown(property.getTitle(), firstPresent(property.getAddress(), property.getCity()));
    }

    /** The client is fetched with the deal: every deal query here goes through its entity graph. */
    private static Shown shown(Deal deal) {
        return new Shown(deal.getTitle(), deal.getClient() == null ? null : deal.getClient().getFullName());
    }

    private static StarResponse respond(Star star, Shown record) {
        return StarResponse.builder()
                .type(star.getEntityType())
                .id(star.getEntityId())
                .title(record.title())
                .subtitle(record.subtitle())
                .starredAt(star.getCreatedAt())
                .build();
    }

    private static StarType typeOf(String raw) {
        StarType type = StarType.parse(raw);
        if (type == null) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, "STAR_TYPE_UNKNOWN",
                    "Only a client, a property or a deal can be starred");
        }
        return type;
    }

    private static String firstPresent(String... values) {
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value.strip();
            }
        }
        return null;
    }
}
