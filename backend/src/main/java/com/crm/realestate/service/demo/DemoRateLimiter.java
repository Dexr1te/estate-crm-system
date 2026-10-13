package com.crm.realestate.service.demo;

import org.springframework.stereotype.Component;

import java.util.ArrayDeque;
import java.util.Deque;
import java.util.LinkedHashMap;
import java.util.Map;

@Component
public class DemoRateLimiter {

    static final int PER_ADDRESS_LIMIT = 5;
    static final int TOTAL_LIMIT = 100;
    static final long WINDOW_MS = 60 * 60 * 1000L;
    static final int MAX_KEYS = 10_000;

    private final Map<String, Deque<Long>> byAddress = new LinkedHashMap<>(256, 0.75f, true) {
        @Override
        protected boolean removeEldestEntry(Map.Entry<String, Deque<Long>> eldest) {
            return size() > MAX_KEYS;
        }
    };
    private final Deque<Long> overall = new ArrayDeque<>();

    public synchronized boolean tryAcquire(String address) {
        long now = System.currentTimeMillis();
        Deque<Long> perAddress = byAddress.computeIfAbsent(address == null ? "?" : address,
                k -> new ArrayDeque<>());
        trim(perAddress, now);
        trim(overall, now);
        if (perAddress.size() >= PER_ADDRESS_LIMIT || overall.size() >= TOTAL_LIMIT) {
            return false;
        }
        perAddress.addLast(now);
        overall.addLast(now);
        return true;
    }

    public synchronized void reset() {
        byAddress.clear();
        overall.clear();
    }

    private static void trim(Deque<Long> times, long now) {
        while (!times.isEmpty() && times.peekFirst() <= now - WINDOW_MS) {
            times.pollFirst();
        }
    }
}
