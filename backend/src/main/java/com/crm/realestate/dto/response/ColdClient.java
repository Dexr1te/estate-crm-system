package com.crm.realestate.dto.response;

import com.crm.realestate.enums.ClientType;
import com.crm.realestate.enums.DealStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/** A client nobody has spoken to in a while, and why they are still worth the call. */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ColdClient {
    private Long id;
    private String fullName;
    private String phone;
    private ClientType type;
    private Long agentId;
    private String agentName;
    /** The latest logged contact or past meeting; null when there has never been one. */
    private LocalDateTime lastContactAt;
    /** Whole days since the last contact — or since the card was created, if never contacted. */
    private long silentDays;
    /** Most valuable first. Never empty. */
    private List<Reason> reasons;
    private NextStep nextStep;

    public enum ReasonCode { OPEN_DEAL, MATCHES, NEW_LEAD }

    /** What the call should be about. The app words it. */
    public enum NextStep { PUSH_DEAL, SEND_MATCHES, FIRST_CALL, CHECK_IN }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Reason {
        private ReasonCode code;
        /** OPEN_DEAL only: the most advanced open deal. */
        private String dealTitle;
        private DealStatus dealStatus;
        /** MATCHES only: available listings that fit, not counting ones turned down. */
        private Long matchCount;
    }
}
