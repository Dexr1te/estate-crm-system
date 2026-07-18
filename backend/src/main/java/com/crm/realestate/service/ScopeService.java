package com.crm.realestate.service;

import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.Role;
import com.crm.realestate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.List;

@Component
@RequiredArgsConstructor
public class ScopeService {

    private final UserRepository userRepository;

    public boolean isAdmin(User user) {
        return user != null && user.getRole() == Role.ADMIN;
    }

    public boolean isManager(User user) {
        return user != null && user.getRole() == Role.MANAGER;
    }

    public boolean isAgent(User user) {
        return user != null && user.getRole() == Role.AGENT;
    }

    public List<Long> getAllowedAgentIds(User user) {
        if (user == null) {
            return Collections.emptyList();
        }
        if (user.getDataScope() == DataScope.ALL) {
            return null;
        }
        if (user.getDataScope() == DataScope.OWN) {
            return List.of(user.getId());
        }
        if (user.getDataScope() == DataScope.TEAM) {
            if (user.getTeam() == null || user.getTeam().getId() == null) {
                return List.of(user.getId());
            }
            return userRepository.findByTeamId(user.getTeam().getId())
                    .stream()
                    .map(User::getId)
                    .toList();
        }
        return List.of(user.getId());
    }

    public boolean isWithinScope(User user, Long agentId) {
        if (agentId == null || user == null) {
            return false;
        }
        List<Long> allowed = getAllowedAgentIds(user);
        if (allowed == null) {
            return true;
        }
        return allowed.contains(agentId);
    }

    public <T> Specification<T> buildAgentScope(String agentPath, List<Long> allowedAgentIds) {
        return (root, query, cb) -> {
            if (allowedAgentIds == null) {
                return cb.conjunction();
            }
            if (allowedAgentIds.isEmpty()) {
                return cb.disjunction();
            }
            return root.get(agentPath).get("id").in(allowedAgentIds);
        };
    }
}
