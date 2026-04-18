package com.crm.realestate.service;

import com.crm.realestate.dto.request.ClientRequest;
import com.crm.realestate.dto.response.ClientResponse;
import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ClientService {

    private final ClientRepository clientRepository;
    private final UserRepository   userRepository;

    public List<ClientResponse> getAll() {
        return clientRepository.findAll()
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<ClientResponse> getByAgent(Long agentId) {
        return clientRepository.findByAgentId(agentId)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<ClientResponse> getByType(ClientType type) {
        return clientRepository.findByType(type)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<ClientResponse> search(String query) {
        return clientRepository.searchClients(query)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public ClientResponse getById(Long id) {
        return toResponse(findById(id));
    }

    @Transactional
    public ClientResponse create(ClientRequest request) {
        if (request.getEmail() != null && clientRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Client with this email already exists");
        }

        Client client = new Client();
        mapRequestToEntity(request, client);
        return toResponse(clientRepository.save(client));
    }

    @Transactional
    public ClientResponse update(Long id, ClientRequest request) {
        Client client = findById(id);
        mapRequestToEntity(request, client);
        return toResponse(clientRepository.save(client));
    }

    @Transactional
    public void delete(Long id) {
        Client client = findById(id);
        clientRepository.delete(client);
    }

    //Private helpers 

    private Client findById(Long id) {
        return clientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Client not found with id: " + id));
    }

    private void mapRequestToEntity(ClientRequest request, Client client) {
        client.setFullName(request.getFullName());
        client.setEmail(request.getEmail());
        client.setPhone(request.getPhone());
        client.setType(request.getType());
        client.setNotes(request.getNotes());

        if (request.getAgentId() != null) {
            User agent = userRepository.findById(request.getAgentId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Agent not found with id: " + request.getAgentId()));
            client.setAgent(agent);
        }
    }

    private ClientResponse toResponse(Client client) {
        ClientResponse res = new ClientResponse();
        res.setId(client.getId());
        res.setFullName(client.getFullName());
        res.setEmail(client.getEmail());
        res.setPhone(client.getPhone());
        res.setType(client.getType());
        res.setNotes(client.getNotes());
        res.setCreatedAt(client.getCreatedAt());
        res.setUpdatedAt(client.getUpdatedAt());
        if (client.getAgent() != null) {
            res.setAgentId(client.getAgent().getId());
            res.setAgentName(client.getAgent().getFullName());
        }
        return res;
    }
}