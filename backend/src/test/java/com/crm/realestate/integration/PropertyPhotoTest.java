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

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
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
        byte[] bytes = jpegBytes();

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
                new MockMultipartFile("file", "contract.pdf", "application/pdf",
                        "%PDF-1.4".getBytes(StandardCharsets.UTF_8))))
                .isInstanceOf(IllegalArgumentException.class);

        assertThat(photoRepository.findAll()).isEmpty();
    }

    @Test
    @DisplayName("an iPhone photograph in HEIC is refused, whatever it is named")
    void heicIsRefusedBecauseTheAppCannotDrawIt() {
        // ftypheic in the first bytes — what an iPhone writes by default, and what
        // Flutter has no decoder for. The name says jpg; the bytes are what count.
        byte[] heic = new byte[] {
                0, 0, 0, 0x18, 'f', 't', 'y', 'p', 'h', 'e', 'i', 'c',
                0, 0, 0, 0};

        assertThatThrownBy(() -> photoService.upload(listing.getId(),
                new MockMultipartFile("file", "IMG_0412.jpg", "image/jpeg", heic)))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("not an image the app can show");

        assertThat(photoRepository.findAll())
                .as("storing it would mean a photograph that uploads and then shows nothing")
                .isEmpty();
    }

    @Test
    @DisplayName("a listing's cover is the smaller copy of its first photograph")
    void theCoverIsASmallerCopy() throws Exception {
        PropertyPhotoResponse first = photoService.upload(listing.getId(), image("facade.jpg"));
        photoService.upload(listing.getId(), image("kitchen.jpg"));

        assertThat(first.isHasThumbnail()).isTrue();
        byte[] cover = photoService.cover(listing.getId()).resource().getContentAsByteArray();

        assertThat(cover)
                .as("a list of twenty listings must not pull twenty full-size photographs")
                .hasSizeLessThan(jpegBytes().length);
        assertThat(ImageIO.read(new java.io.ByteArrayInputStream(cover)).getWidth())
                .isLessThanOrEqualTo(480);
    }

    @Test
    @DisplayName("the gallery can be put in another order, and the cover follows")
    void theCoverIsWhateverIsFirst() throws Exception {
        PropertyPhotoResponse hallway = photoService.upload(listing.getId(), image("hallway.jpg"));
        PropertyPhotoResponse facade = photoService.upload(listing.getId(), image("facade.jpg"));
        PropertyPhotoResponse kitchen = photoService.upload(listing.getId(), image("kitchen.jpg"));

        List<PropertyPhotoResponse> reordered = photoService.reorder(listing.getId(),
                List.of(facade.getId(), kitchen.getId(), hallway.getId()));

        assertThat(reordered).extracting(PropertyPhotoResponse::getFileName)
                .as("the agent shot the hallway first; it should not be the face of the listing")
                .containsExactly("facade.jpg", "kitchen.jpg", "hallway.jpg");
        assertThat(photoService.getByProperty(listing.getId()))
                .extracting(PropertyPhotoResponse::getFileName)
                .containsExactly("facade.jpg", "kitchen.jpg", "hallway.jpg");
    }

    @Test
    @DisplayName("an order that does not name every photograph is refused")
    void halfAnOrderIsNoOrder() {
        PropertyPhotoResponse first = photoService.upload(listing.getId(), image("facade.jpg"));
        photoService.upload(listing.getId(), image("kitchen.jpg"));

        assertThatThrownBy(() -> photoService.reorder(listing.getId(), List.of(first.getId())))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("exactly once");

        assertThatThrownBy(() -> photoService.reorder(listing.getId(),
                List.of(first.getId(), first.getId())))
                .as("a duplicate would leave one photograph at a position that means nothing")
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("an order naming a photograph from elsewhere is refused")
    void aStrangersPhotographIsNotPartOfThisGallery() {
        PropertyPhotoResponse mine = photoService.upload(listing.getId(), image("facade.jpg"));
        Property another = listing("Tverskaya 12", team, agent);
        PropertyPhotoResponse theirs = photoService.upload(another.getId(), image("other.jpg"));

        assertThatThrownBy(() -> photoService.reorder(listing.getId(),
                List.of(mine.getId(), theirs.getId())))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    @DisplayName("a listing with no photographs has no cover")
    void nothingToShowIsNotAnEmptyImage() {
        assertThatThrownBy(() -> photoService.cover(listing.getId()))
                .isInstanceOf(ResourceNotFoundException.class);
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

    /** A real one-pixel JPEG: the service reads the header, not the name. */
    static MockMultipartFile image(String name) {
        return new MockMultipartFile("file", name, "image/jpeg", jpegBytes());
    }

    static byte[] jpegBytes() {
        try {
            BufferedImage pixel = new BufferedImage(600, 400, BufferedImage.TYPE_INT_RGB);
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            ImageIO.write(pixel, "jpg", out);
            return out.toByteArray();
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
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
