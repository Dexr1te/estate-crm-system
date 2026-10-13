package com.crm.realestate.service.demo;

import java.util.Locale;

public final class DemoAccounts {

    public static final String EMAIL_DOMAIN = "@demo.estatecrm.app";

    public static final String PREFIX = "[Demo] ";

    public static final String TEAM_NAME = PREFIX + "Agency";

    public static final String HANDOVER_NAME = PREFIX + "Handover Account";

    public static final String TRY_MAILBOX_PREFIX = "demo-";

    public static final String TRY_EMAIL_PATTERN = TRY_MAILBOX_PREFIX + "%" + EMAIL_DOMAIN;

    private DemoAccounts() {
    }

    public static boolean isDemoAddress(String email) {
        return email != null && normalise(email).endsWith(EMAIL_DOMAIN);
    }

    public static boolean isTryAccount(String email) {
        return isDemoAddress(email) && normalise(email).startsWith(TRY_MAILBOX_PREFIX);
    }

    private static String normalise(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }
}
