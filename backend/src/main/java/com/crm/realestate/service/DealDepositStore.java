package com.crm.realestate.service;

import com.crm.realestate.entity.Deal;
import com.crm.realestate.entity.DealComment;
import com.crm.realestate.entity.DealDeposit;
import com.crm.realestate.entity.User;
import com.crm.realestate.enums.AgencyCurrency;
import com.crm.realestate.enums.DepositHolder;
import com.crm.realestate.enums.DepositOutcome;
import com.crm.realestate.repository.DealCommentRepository;
import com.crm.realestate.repository.DealDepositRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/**
 * The parts of a deal's deposit that {@link DealService} needs as well: closing the active deposit
 * as applied when the deal is won, and writing each change into the deal's discussion.
 *
 * <p>The discussion line is ordinary text under the name of whoever made the change, written in the
 * language their app asks in (Accept-Language), Russian when it names none of en, ru and kk — the
 * same rule as the defaults an agency starts with. It is history, not a translation: the next reader
 * sees it as it was written.
 */
@Component
@RequiredArgsConstructor
public class DealDepositStore {

    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("dd.MM.yyyy");

    private final DealDepositRepository depositRepository;
    private final DealCommentRepository commentRepository;

    /** A won deal's active deposit has gone towards the price: it closes as applied, today. */
    public void applyOnWin(Deal deal, User by) {
        if (deal.getId() == null) {
            return;
        }
        depositRepository.findFirstByDealIdAndOutcomeIsNull(deal.getId())
                .ifPresent(d -> close(d, DepositOutcome.APPLIED, LocalDate.now(), by));
    }

    DealDeposit close(DealDeposit deposit, DepositOutcome outcome, LocalDate on, User by) {
        deposit.setOutcome(outcome);
        deposit.setClosedOn(on);
        DealDeposit saved = depositRepository.save(deposit);
        note(deposit.getDeal(), by, closedText(language(), outcome, on));
        return saved;
    }

    void recorded(DealDeposit deposit, User by) {
        note(deposit.getDeal(), by, heldText(language(), true, deposit));
    }

    void changed(DealDeposit deposit, User by) {
        note(deposit.getDeal(), by, heldText(language(), false, deposit));
    }

    private void note(Deal deal, User by, String text) {
        commentRepository.save(DealComment.builder()
                .deal(deal)
                .team(deal.getTeam())
                .author(by)
                .authorName(by == null ? null : by.getFullName())
                .body(text)
                .build());
    }

    // Wording ---------------------------------------------------------------------------

    static String heldText(String language, boolean recorded, DealDeposit d) {
        AgencyCurrency currency = d.getDeal().getTeam() == null
                ? AgencyCurrency.USD : d.getDeal().getTeam().getCurrency();
        String amount = currency.format(d.getAmount(), Locale.forLanguageTag(language));
        String holder = holderText(language, d.getHolder());
        String until = DATE.format(d.getHoldUntil());
        return switch (language) {
            case "en" -> (recorded ? "Deposit recorded: " : "Deposit changed: ")
                    + amount + ", held by " + holder + " until " + until + ".";
            case "kk" -> (recorded ? "Кепілпұл енгізілді: " : "Кепілпұл өзгертілді: ")
                    + amount + ", " + holder + " сақтайды, " + until + " дейін.";
            default -> (recorded ? "Внесён задаток: " : "Задаток изменён: ")
                    + amount + ", хранится у " + holder + " до " + until + ".";
        };
    }

    static String closedText(String language, DepositOutcome outcome, LocalDate on) {
        String date = DATE.format(on);
        return switch (language) {
            case "en" -> switch (outcome) {
                case APPLIED -> "Deposit applied to the purchase on " + date + ".";
                case REFUNDED -> "Deposit refunded to the buyer on " + date + ".";
                case FORFEITED -> "Deposit forfeited on " + date + ".";
            };
            case "kk" -> switch (outcome) {
                case APPLIED -> "Кепілпұл " + date + " сатып алу есебіне жатқызылды.";
                case REFUNDED -> "Кепілпұл " + date + " сатып алушыға қайтарылды.";
                case FORFEITED -> "Кепілпұл " + date + " ұсталып қалды.";
            };
            default -> switch (outcome) {
                case APPLIED -> "Задаток зачтён в счёт покупки " + date + ".";
                case REFUNDED -> "Задаток возвращён покупателю " + date + ".";
                case FORFEITED -> "Задаток удержан " + date + ".";
            };
        };
    }

    private static String holderText(String language, DepositHolder holder) {
        return switch (language) {
            case "en" -> switch (holder) {
                case AGENCY -> "the agency";
                case SELLER -> "the seller";
                case NOTARY -> "a notary";
            };
            case "kk" -> switch (holder) {
                case AGENCY -> "агенттік";
                case SELLER -> "сатушы";
                case NOTARY -> "нотариус";
            };
            default -> switch (holder) {
                case AGENCY -> "агентства";
                case SELLER -> "продавца";
                case NOTARY -> "нотариуса";
            };
        };
    }

    private static String language() {
        String header = null;
        if (RequestContextHolder.getRequestAttributes() instanceof ServletRequestAttributes attributes) {
            header = attributes.getRequest().getHeader("Accept-Language");
        }
        String language = DefaultChecklist.supported(header);
        return language != null ? language : DefaultChecklist.FALLBACK_LANGUAGE;
    }
}
