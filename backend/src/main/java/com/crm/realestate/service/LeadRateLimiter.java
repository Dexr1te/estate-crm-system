package com.crm.realestate.service;

import org.springframework.stereotype.Component;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * How often the form on a listing's public page may be sent, kept in memory.
 *
 * <p>Two sliding windows: {@value #PER_ADDRESS_LIMIT} enquiries per address per link every ten
 * minutes, which is more than a person ever needs and less than a script wants, and
 * {@value #PER_LINK_LIMIT} per link a day, so a link pasted somewhere hostile cannot bury its
 * agent in fake clients whatever addresses the requests come from.
 *
 * <p>Both maps are bounded: once {@value #MAX_KEYS} keys are held, the one touched longest ago is
 * forgotten. Forgetting can only let somebody through early; it never blocks anyone wrongly, and
 * memory stays flat however many addresses turn up. One instance holds the counts, so with several
 * replicas each keeps its own — the limits are per instance, which is fine for a single Render
 * service and still a ceiling with more.
 *
 * <p>The address is {@code request.getRemoteAddr()} as the servlet container reports it. The app
 * does not set {@code server.forward-headers-strategy}, so {@code X-Forwarded-For} is not trusted
 * and a client cannot pick its own address by sending one. Behind Render's proxy that address is
 * the proxy's, which makes the per-address limit stricter (shared by everyone on that edge), never
 * looser; turning the strategy on makes it per-visitor without any change here.
 */
@Component
public class LeadRateLimiter {

    static final int PER_ADDRESS_LIMIT = 5;
    static final long PER_ADDRESS_WINDOW_MS = 10 * 60 * 1000L;
    static final int PER_LINK_LIMIT = 50;
    static final long PER_LINK_WINDOW_MS = 24 * 60 * 60 * 1000L;
    static final int MAX_KEYS = 10_000;

    private final Map<String, Deque<Long>> byAddress = lru();
    private final Map<String, Deque<Long>> byLink = lru();

    /**
     * Whether one more enquiry from {@code address} through {@code token} may go ahead, and if it
     * may, counts it. A refused attempt is not counted, so waiting is always enough.
     */
    public synchronized boolean tryAcquire(String token, String address) {
        long now = System.currentTimeMillis();
        String addressKey = token + "|" + (address == null ? "?" : address);
        Deque<Long> perAddress = window(byAddress, addressKey, now, PER_ADDRESS_WINDOW_MS);
        Deque<Long> perLink = window(byLink, token, now, PER_LINK_WINDOW_MS);
        if (perAddress.size() >= PER_ADDRESS_LIMIT || perLink.size() >= PER_LINK_LIMIT) {
            return false;
        }
        perAddress.addLast(now);
        perLink.addLast(now);
        return true;
    }

    /** Forgets everything; for tests that share one application context. */
    public synchronized void reset() {
        byAddress.clear();
        byLink.clear();
    }

    private static Deque<Long> window(Map<String, Deque<Long>> map, String key, long now, long span) {
        Deque<Long> times = map.computeIfAbsent(key, k -> new ArrayDeque<>());
        while (!times.isEmpty() && times.peekFirst() <= now - span) {
            times.pollFirst();
        }
        return times;
    }

    private static Map<String, Deque<Long>> lru() {
        return new LinkedHashMap<>(256, 0.75f, true) {
            @Override
            protected boolean removeEldestEntry(Map.Entry<String, Deque<Long>> eldest) {
                return size() > MAX_KEYS;
            }
        };
    }
}
