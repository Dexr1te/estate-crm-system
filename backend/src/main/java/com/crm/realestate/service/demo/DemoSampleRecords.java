package com.crm.realestate.service.demo;

import com.crm.realestate.entity.Client;
import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.Meeting;
import com.crm.realestate.entity.Property;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DealLostReason;
import com.crm.realestate.enums.DealStatus;
import com.crm.realestate.enums.PropertyStatus;
import com.crm.realestate.enums.PropertyType;
import com.crm.realestate.repository.ClientRepository;
import com.crm.realestate.repository.DealRepository;
import com.crm.realestate.repository.MeetingRepository;
import com.crm.realestate.repository.PropertyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
public class DemoSampleRecords {

    private final ClientRepository   clientRepository;
    private final PropertyRepository propertyRepository;
    private final DealRepository     dealRepository;
    private final MeetingRepository  meetingRepository;

    public void seed(User agent) {
        Client aigerim = client(agent, "Aigerim Nurlanova", "aigerim", "+7 701 000 01 01",
                ClientType.BUYER, "Looking for a two-room flat near the centre. Viewings after 18:00.");
        Client daniyar = client(agent, "Daniyar Serikov", "daniyar", "+7 701 000 01 02",
                ClientType.BUYER, "Mortgage pre-approved. Wants a school within walking distance.");
        Client madina = client(agent, "Madina Abenova", "madina", "+7 701 000 01 03",
                ClientType.SELLER, "Selling the retail unit on Abay. Deal closed in her favour.");
        Client ruslan = client(agent, "Ruslan Iskakov", "ruslan", "+7 701 000 01 04",
                ClientType.BUYER, "Relocating from Astana. Needs the house before September.");
        Client zhanna = client(agent, "Zhanna Karimova", "zhanna", "+7 701 000 01 05",
                ClientType.SELLER, "Withdrew the office floor from sale; may relist in spring.");
        client(agent, "Timur Bekov", "timur", "+7 701 000 01 06",
                ClientType.BUYER, "First call taken, nothing shortlisted yet.");

        property(agent, "2-room apartment on Dostyk", "Dostyk Ave 210",
                PropertyType.APARTMENT, PropertyStatus.AVAILABLE, "128000", 62.5, 2, 7, 12);
        Property alFarabi = property(agent, "3-room apartment on Al-Farabi", "Al-Farabi Ave 77",
                PropertyType.APARTMENT, PropertyStatus.RESERVED, "215000", 94.0, 3, 5, 9);
        Property house = property(agent, "Family house in Gornyi Gigant", "Zhamakayev St 12",
                PropertyType.HOUSE, PropertyStatus.AVAILABLE, "430000", 240.0, 5, 1, 2);
        Property office = property(agent, "Office floor at Nurly Tau", "Al-Farabi Ave 17/1",
                PropertyType.OFFICE, PropertyStatus.AVAILABLE, "310000", 180.0, null, 8, 16);
        Property retail = property(agent, "Retail space on Abay", "Abay Ave 44",
                PropertyType.COMMERCIAL, PropertyStatus.SOLD, "265000", 120.0, null, 1, 1);

        Deal search = deal(agent, aigerim, null, "Apartment search for Aigerim",
                DealStatus.LEAD, null, "140000", null);
        Deal negotiation = deal(agent, daniyar, alFarabi, "Al-Farabi three-room for Daniyar",
                DealStatus.NEGOTIATION, "210000", "220000", null);
        Deal won = deal(agent, madina, retail, "Abay retail unit for Madina",
                DealStatus.CLOSED_WON, "265000", null, LocalDateTime.now().minusDays(12));
        Deal viewing = deal(agent, ruslan, house, "Gornyi Gigant house for Ruslan",
                DealStatus.NEGOTIATION, "430000", "450000", null);
        deal(agent, zhanna, office, "Nurly Tau office floor for Zhanna",
                DealStatus.CLOSED_LOST, null, null, LocalDateTime.now().minusDays(5));

        meeting(agent, daniyar, negotiation, "Viewing at Al-Farabi 77",
                LocalDate.now().plusDays(1).atTime(11, 0), "Al-Farabi Ave 77", false);
        meeting(agent, ruslan, viewing, "Second viewing of the house",
                LocalDate.now().plusDays(3).atTime(15, 30), "Zhamakayev St 12", false);
        meeting(agent, aigerim, search, "Intake call",
                LocalDate.now().minusDays(2).atTime(10, 0), "Phone", true);
        meeting(agent, madina, won, "Handover of the keys",
                LocalDate.now().minusDays(9).atTime(13, 0), "Abay Ave 44", true);
    }

    private Client client(User agent, String name, String mailbox, String phone,
                          ClientType type, String notes) {
        return clientRepository.save(Client.builder()
                .fullName(DemoAccounts.PREFIX + name)
                .email(mailbox + DemoAccounts.EMAIL_DOMAIN)
                .phone(phone)
                .type(type)
                .notes(notes)
                .agent(agent)
                .team(agent.getTeam())
                .build());
    }

    private Property property(User agent, String title, String address, PropertyType type,
                              PropertyStatus status, String price, Double areaSqm,
                              Integer rooms, Integer floor, Integer totalFloors) {
        return propertyRepository.save(Property.builder()
                .title(DemoAccounts.PREFIX + title)
                .address(address)
                .city("Almaty")
                .type(type)
                .status(status)
                .price(new BigDecimal(price))
                .areaSqm(areaSqm)
                .rooms(rooms)
                .floor(floor)
                .totalFloors(totalFloors)
                .agent(agent)
                .team(agent.getTeam())
                .build());
    }

    private Deal deal(User agent, Client client, Property property, String title,
                      DealStatus status, String dealPrice, String budget, LocalDateTime closedAt) {
        return dealRepository.save(Deal.builder()
                .title(title)
                .status(status)
                .client(client)
                .property(property)
                .agent(agent)
                .team(agent.getTeam())
                .dealPrice(dealPrice == null ? null : new BigDecimal(dealPrice))
                .budget(budget == null ? null : new BigDecimal(budget))
                .closedAt(closedAt)
                .lostReason(status == DealStatus.CLOSED_LOST ? DealLostReason.PRICE : null)
                .build());
    }

    private void meeting(User agent, Client client, Deal deal, String title,
                         LocalDateTime scheduledAt, String location, boolean completed) {
        meetingRepository.save(Meeting.builder()
                .title(title)
                .scheduledAt(scheduledAt)
                .location(location)
                .completed(completed)
                .client(client)
                .deal(deal)
                .agent(agent)
                .team(agent.getTeam())
                .build());
    }
}
