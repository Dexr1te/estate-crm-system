package com.crm.realestate.config;

import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
@SecurityScheme(
        name = "bearerAuth",
        type = SecuritySchemeType.HTTP,
        scheme = "bearer",
        bearerFormat = "JWT",
        description = "Paste your JWT access token here"
)
public class SwaggerConfig {

    @Value("${app.base-url:http://localhost:8080}")
    private String baseUrl;

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
                .servers(List.of(
                        new Server().url(baseUrl).description("Current server")
                ))
                .info(new Info()
                        .title("Real Estate CRM API")
                        .description("""
                                REST API for Real Estate CRM System.
                                
                                **How to use:**
                                1. Call `POST /auth/register` to create an account
                                2. Call `POST /auth/login` to get your JWT token
                                3. Click **Authorize** button and paste the token
                                4. All endpoints are now available
                                """)
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("CRM Dev Team")
                                .email("dev@realestate-crm.com")));
    }
}
