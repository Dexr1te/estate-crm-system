package com.crm.realestate.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Where the CRM proper begins.
 *
 * <p>Everything listed here reads or writes an agency's records, so it needs a team behind the
 * caller. Auth, profile, team membership and the admin console are deliberately outside: they are
 * how someone gets a team in the first place. So is {@code /notifications}: an invitation to join
 * an agency reaches somebody who is not in one yet, and the feed only ever shows the caller's own.
 */
@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {

    private final TeamRequiredInterceptor teamRequiredInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(teamRequiredInterceptor)
                .addPathPatterns(
                        "/clients/**",
                        "/properties/**",
                        "/deals/**",
                        "/meetings/**",
                        "/tasks/**",
                        "/dashboard/**",
                        "/users/agents");
    }
}
