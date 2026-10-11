package com.crm.realestate.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import javax.annotation.PostConstruct;
import java.io.FileInputStream;
import java.io.IOException;

@Configuration
@Slf4j
public class FirebaseConfig {

    @Value("${firebase.credentials-path:firebase-service-account.json}")
    private String credentialsPath;

    @Value("${firebase.project-id:}")
    private String projectId;

    @PostConstruct
    public void initialize() {
        try {
            if (FirebaseApp.getApps().isEmpty()) {
                FileInputStream serviceAccount = new FileInputStream(credentialsPath);

                FirebaseOptions.Builder options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount));
                // Blank means "the project the service account belongs to".
                if (projectId != null && !projectId.isBlank()) {
                    options.setProjectId(projectId);
                }

                FirebaseApp.initializeApp(options.build());
                log.info("Firebase initialized successfully for project: {}", projectId);
            }
        } catch (IOException e) {
            log.warn("Firebase initialization failed: {}. Push notifications and sign-up email "
                    + "verification will be disabled.", e.getMessage());
        }
    }
}