package com.crm.realestate.service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class FirebaseNotificationService {

    // Отправить push уведомление на конкретное устройство
    public void sendToDevice(String fcmToken, String title, String body) {
        if (fcmToken == null || fcmToken.isBlank()) {
            log.warn("FCM token is empty, skipping notification");
            return;
        }

        try {
            Message message = Message.builder()
                    .setToken(fcmToken)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .build();

            String response = FirebaseMessaging.getInstance().send(message);
            log.info("Push notification sent: {}", response);

        } catch (FirebaseMessagingException e) {
            log.error("Failed to send push notification: {}", e.getMessage());
        }
    }

    // Отправить на топик (например, всем агентам)
    public void sendToTopic(String topic, String title, String body) {
        try {
            Message message = Message.builder()
                    .setTopic(topic)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .build();

            String response = FirebaseMessaging.getInstance().send(message);
            log.info("Push notification sent to topic [{}]: {}", topic, response);

        } catch (FirebaseMessagingException e) {
            log.error("Failed to send push to topic: {}", e.getMessage());
        }
    }
}