package com.crm.realestate.integration;

import com.crm.realestate.dto.response.PropertyPhotoResponse;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.Team;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.DataScope;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.enums.Role;
import com.crm.realestate.enums.UserStatus;
import com.crm.realestate.exception.ResourceNotFoundException;
import com.crm.realestate.repository.PropertyPhotoRepository;
import com.crm.realestate.repository.PropertyRepository;
import com.crm.realestate.repository.TeamRepository;
import com.crm.realestate.repository.UserRepository;
import com.crm.realestate.service.PropertyPhotoService;
import com.crm.realestate.service.PropertyService;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * Photographs of a listing.
 *
 * <p>A gallery takes images and nothing else — a PDF here would be shown as a
 * broken tile rather than refused — and the order matters, because the first
 * one is the cover a list of listings shows. The rest is the wall every read
 * stands behind and the rule that a photograph has no meaning once the flat it
 * pictures is gone.
 */
@SpringBootTest
@Transactional
class PropertyPhotoTest {

    @Autowired private PropertyPhotoService    photoService;
    @Autowired private PropertyService         propertyService;
    @Autowired private PropertyPhotoRepository photoRepository;
    @Autowired private PropertyRepository      propertyRepository;
    @Autowired private UserRepository          userRepository;
    @Autowired private TeamRepository          teamRepository;
    @Autowired private EntityManager           entityManager;

    private Team team;
    private User agent;
    private Property listing;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.clearContext();
        photoRepository.deleteAll();
        propertyRepository.deleteAll();
        userRepository.deleteAll();
        teamRepository.deleteAll();

        team = teamRepository.save(Team.builder().name("Almaty Realty").build());
        agent = user("agent@estate.crm", team);
        signIn(agent);
        listing = listing("Severny Residence, apt 84", team, agent);
    }

    @Test
    @DisplayName("a photograph is stored, listed and read back")
    void aPhotographSurvivesTheRoundTrip() throws Exception {
        byte[] bytes = "not really a jpeg".getBytes(StandardCharsets.UTF_8);

        PropertyPhotoResponse added = photoService.upload(listing.getId(),
                new MockMultipartFile("file", "Гостиная.jpg", "image/jpeg", bytes));

        assertThat(added.getFileName()).isEqualTo("Гостиная.jpg");
        assertThat(added.getContentType()).isEqualTo("image/jpeg");
        assertThat(added.getFileSize()).isEqualTo(bytes.length);

        assertThat(photoService.getByProperty(listing.getId())).hasSize(1);
        assertThat(photoService.download(listing.getId(), added.getId())
                .resource().getContentAsByteArray()).isEqualTo(bytes);
    }

    @Test
    @DisplayName("the gallery keeps the order they were added in")
    void theFirstOneUploadedIsTheCover() {
        photoService.upload(listing.getId(), image("1-facade.jpg"));
        photoService.upload(listing.getId(), image("2-kitchen.jpg"));
        photoService.upload(listing.getId(), image("3-view.jpg"));

        assertThat(photoService.getByProperty(listing.getId()))
                .extracting(PropertyPhotoResponse::getFileName)
                .containsExactly("1-facade.jpg", "2-kitchen.jpg", "3-view.jpg");
    }

    @Test
    @DisplayName("a gallery takes photographs and not paperwork")
    void aContractIsNotAPhotograph() {
        assertThatThrownBy(() -> photoService.upload(listing.getId(),
                new MockMultipartFile("file", "contract.pdf", "application/pdf", "x".getBytes())))
                .isInstanceOf(IllegalArgumentException.class);

        assertThat(photoRepository.findAll()).isEmpty();
    }

    @Test
    @DisplayName("removing a photograph takes its bytes with it")
    void deletingIsNotJustTheRow() {
        PropertyPhotoResponse added = photoService.upload(listing.getId(), image("facade.jpg"));

        photoService.delete(listing.getId(), added.getId());

        assertThat(photoService.getByProperty(listing.getId())).isEmpty();
    }

    @Test
    @DisplayName("a photograph of another agency's listing is not readable")
    void theWallHoldsHere() {
        Team other = teamRepository.save(Team.builder().name("Astana Estate").build());
        User stranger = user("stranger@other.crm", other);
        Property theirs = listing("Their listing", other, stranger);

        assertThatThrownBy(() -> photoService.upload(theirs.getId(), image("facade.jpg")))
                .isInstanceOf(ResourceNotFoundException.class);
        assertThatThrownBy(() -> photoService.getByProperty(theirs.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    @DisplayName("a photograph of a deleted listing goes with it")
    void nothingOutlivesTheFlatItPictures() {
        photoService.upload(listing.getId(), image("facade.jpg"));

        propertyService.delete(listing.getId());
        entityManager.flush();
        entityManager.clear();

        assertThat(photoRepository.findAll())
                .as("a picture of a flat that is gone pictures nothing")
                .isEmpty();
    }

    private MockMultipartFile image(String name) {
        return new MockMultipartFile("file", name, "image/jpeg",
                name.getBytes(StandardCharsets.UTF_8));
    }

    private Property listing(String title, Team where, User owner) {
        return propertyRepository.save(Property.builder()
                .title(title).address(title).city("Almaty")
                .type(PropertyType.APARTMENT).status(PropertyStatus.AVAILABLE)
                .price(new BigDecimal("28000000")).rooms(3).areaSqm(62.0)
                .agent(owner).team(where).build());
    }

    private User user(String email, Team where) {
        return userRepository.save(User.builder()
                .email(email).password("x").fullName(email)
                .role(Role.AGENT).dataScope(DataScope.TEAM).team(where)
                .status(UserStatus.ACTIVE).isActive(true)
                .build());
    }

    private void signIn(User who) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(who.getEmail(), null, List.of()));
    }
}
