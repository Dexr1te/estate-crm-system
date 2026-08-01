package com.crm.realestate.service;

import java.util.Hashtable;
import java.util.Locale;
import java.util.concurrent.ConcurrentHashMap;

import javax.naming.NameNotFoundException;
import javax.naming.NamingException;
import javax.naming.directory.Attributes;
import javax.naming.directory.InitialDirContext;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * Checks that the domain of an email address can actually receive mail.
 *
 * <p><strong>What this does and does not prove.</strong> {@code @Email} on the request already
 * rejects malformed addresses, but it happily accepts {@code someone@gmial.com}. This asks DNS
 * whether the domain publishes an MX record (or, failing that, an A record — some small domains
 * accept mail on the host itself), which catches a mistyped or invented domain before we create a
 * user that can never be reached.
 *
 * <p>It deliberately does <em>not</em> try to prove the mailbox exists. The only way to ask that is
 * an SMTP {@code RCPT TO} probe, which the large providers refuse to answer honestly, which returns
 * a false positive for every catch-all domain, and which gets the sending IP blocklisted. Whether a
 * mailbox is real is answered by the invite being accepted, or by a bounce.
 *
 * <p>A lookup that fails for any reason other than "no such domain" is treated as inconclusive and
 * the address is allowed through: a DNS outage on our side must not stop an admin inviting people.
 */
@Service
@Slf4j
public class EmailDomainValidator {

    private static final String DNS_FACTORY = "com.sun.jndi.dns.DnsContextFactory";

    private final ConcurrentHashMap<String, Boolean> cache = new ConcurrentHashMap<>();

    @Value("${app.mail.verify-domain:true}")
    private boolean enabled;

    @Value("${app.mail.verify-domain-timeout-ms:3000}")
    private String timeoutMs;

    public boolean acceptsMail(String email) {
        if (!enabled) {
            return true;
        }
        String domain = domainOf(email);
        if (domain == null) {
            return false;
        }
        return cache.computeIfAbsent(domain, this::lookup);
    }

    private String domainOf(String email) {
        if (email == null) {
            return null;
        }
        int at = email.lastIndexOf('@');
        if (at < 1 || at == email.length() - 1) {
            return null;
        }
        return email.substring(at + 1).trim().toLowerCase(Locale.ROOT);
    }

    private boolean lookup(String domain) {
        Hashtable<String, String> env = new Hashtable<>();
        env.put("java.naming.factory.initial", DNS_FACTORY);
        // Without a bound timeout a black-holed resolver would hang the invite request.
        env.put("com.sun.jndi.dns.timeout.initial", timeoutMs);
        env.put("com.sun.jndi.dns.timeout.retries", "1");

        InitialDirContext ctx = null;
        try {
            ctx = new InitialDirContext(env);
            Attributes mx = ctx.getAttributes(domain, new String[] {"MX"});
            if (mx.get("MX") != null && mx.get("MX").size() > 0) {
                return true;
            }
            Attributes a = ctx.getAttributes(domain, new String[] {"A"});
            return a.get("A") != null && a.get("A").size() > 0;
        } catch (NameNotFoundException e) {
            log.info("Rejecting invite: domain '{}' does not exist", domain);
            return false;
        } catch (NamingException e) {
            log.warn("Could not resolve '{}' ({}); allowing the address through", domain, e.getMessage());
            return true;
        } finally {
            if (ctx != null) {
                try {
                    ctx.close();
                } catch (NamingException ignored) {
                    // Nothing useful to do while closing a lookup context.
                }
            }
        }
    }
}
