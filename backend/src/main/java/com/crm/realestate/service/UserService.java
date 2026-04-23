package com.crm.realestate.service;

import com.crm.realestate.dto.response.AgentOptionResponse;
import com.crm.realestate.enums.Role;
import com.crm.realestate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;

    // only active agents for frontend select (for meetings, deals)
    public List<AgentOptionResponse> getAgentOptions() {
        return userRepository.findByRoleAndIsActiveTrueOrderByFullNameAsc(Role.AGENT)
                .stream()
                .map(user -> AgentOptionResponse.builder()
                        .id(user.getId())
                        .fullName(user.getFullName())
                        .build())
                .collect(Collectors.toList());
    }
}