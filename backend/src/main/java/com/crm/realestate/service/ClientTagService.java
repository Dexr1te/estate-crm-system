package com.crm.realestate.service;

import com.crm.realestate.dto.response.ClientTagUsage;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.ClientTag;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.exception.BusinessException;
import com.crm.realestate.repository.ClientTagRepository;
import com.crm.realestate.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Tags on clients, inside one agency's vocabulary.
 *
 * <p>A typed tag is normalised by {@link ClientTags}. It then resolves against the vocabulary of
 * the client's own agency: an existing tag with the same key is reused under the spelling the
 * agency already has, and a new one is added under the spelling just typed. A client therefore
 * never carries another agency's tag, and nobody's suggestions show one.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ClientTagService {

    private final ClientTagRepository tagRepository;
    private final ScopeService scopeService;
    private final SecurityUtils securityUtils;

    /**
     * Gives the client exactly these tags, refusing more than {@link ClientTags#MAX_PER_CLIENT}
     * or one longer than {@link ClientTags#MAX_LENGTH} with a 400 the app can name.
     */
    @Transactional
    public void assign(Client client, Collection<String> typed) {
        List<String> names = ClientTags.normalise(typed);
        String violation = ClientTags.violation(names);
        if (violation != null) {
            throw new BusinessException(HttpStatus.BAD_REQUEST, violation, ClientTags.TOO_LONG.equals(violation)
                    ? "A tag can be at most " + ClientTags.MAX_LENGTH + " characters"
                    : "A client can carry at most " + ClientTags.MAX_PER_CLIENT + " tags");
        }
        replace(client, names);
    }

    /**
     * Two cards' tags on one: the target's own first, then the source's it lacks, up to the
     * limit. Returns how many of the source's were added.
     */
    @Transactional
    public int union(Client target, Collection<String> carried) {
        List<String> own = names(target);
        List<String> all = new ArrayList<>(own);
        all.addAll(carried);
        List<String> names = ClientTags.normalise(all);
        List<String> fitting = names.subList(0, Math.min(names.size(), ClientTags.MAX_PER_CLIENT));
        replace(target, fitting);
        if (fitting.size() < names.size()) {
            // A tag only the deleted card carried, and that did not fit, is carried by nobody now.
            forgetUnused(target.getTeam());
        }
        return fitting.size() - ClientTags.normalise(own).size();
    }

    /** The tag names the client carries, in name order. */
    public List<String> names(Client client) {
        return client.getTags().stream()
                .sorted(Comparator.comparing(ClientTag::getNameKey))
                .map(ClientTag::getName)
                .toList();
    }

    /**
     * The tags of the caller's agency that some client carries, most used first. Counted over the
     * whole agency whatever the caller's data scope: it is the agency's vocabulary, offered so that
     * everyone spells a tag the way the agency already does. Someone in no agency gets none.
     */
    public List<ClientTagUsage> usage() {
        User currentUser = securityUtils.getCurrentUser();
        Long teamId = scopeService.teamIdOf(currentUser);
        if (teamId == null) {
            return List.of();
        }
        return tagRepository.usageByTeam(teamId).stream()
                .map(row -> new ClientTagUsage((String) row[0], ((Number) row[1]).longValue()))
                .toList();
    }

    /** Each client's tag names, in name order, for a page of clients: one statement. */
    public Map<Long, List<String>> namesByClient(Collection<Long> clientIds) {
        Map<Long, List<String>> result = new HashMap<>();
        if (clientIds.isEmpty()) {
            return result;
        }
        for (Object[] row : tagRepository.namesByClients(clientIds)) {
            result.computeIfAbsent((Long) row[0], id -> new ArrayList<>()).add((String) row[1]);
        }
        return result;
    }

    /**
     * The agency's tags for these normalised names, adding the ones it does not have yet. The
     * import resolves a whole file's tags through here at once.
     */
    @Transactional
    public Map<String, ClientTag> resolve(Team team, Collection<String> names) {
        Map<String, String> wanted = new LinkedHashMap<>();
        for (String name : names) {
            wanted.putIfAbsent(ClientTags.key(name), name);
        }
        Map<String, ClientTag> byKey = new HashMap<>();
        if (wanted.isEmpty()) {
            return byKey;
        }
        Long teamId = team == null ? null : team.getId();
        for (ClientTag tag : tagRepository.findByTeamAndKeys(teamId, wanted.keySet())) {
            byKey.put(tag.getNameKey(), tag);
        }
        wanted.forEach((key, name) -> byKey.computeIfAbsent(key, k -> tagRepository.save(
                ClientTag.builder().team(team).name(name).nameKey(k).build())));
        return byKey;
    }

    @Transactional
    public void forgetUnused(Team team) {
        tagRepository.deleteUnused(team == null ? null : team.getId());
    }

    private void replace(Client client, List<String> names) {
        Map<String, ClientTag> byKey = resolve(client.getTeam(), names);
        Set<ClientTag> wanted = new LinkedHashSet<>();
        for (String name : names) {
            wanted.add(byKey.get(ClientTags.key(name)));
        }
        boolean removed = client.getTags().retainAll(wanted);
        client.getTags().addAll(wanted);
        if (removed && client.getId() != null) {
            forgetUnused(client.getTeam());
        }
    }
}
