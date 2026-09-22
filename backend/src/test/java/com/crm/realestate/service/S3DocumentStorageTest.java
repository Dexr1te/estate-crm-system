package com.crm.realestate.service;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.mock.web.MockMultipartFile;
import software.amazon.awssdk.core.ResponseBytes;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.s3.model.NoSuchKeyException;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.nio.charset.StandardCharsets;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * The object store, against a mocked client.
 *
 * <p>There is no S3 to talk to in a test run, and standing one up would test the
 * SDK rather than this class. What is worth holding it to is what it asks the
 * client for: the key it writes, the bucket it writes to, and that a key the
 * bucket has never heard of reads as a missing file rather than as a crash —
 * the same way the other two stores answer.
 */
class S3DocumentStorageTest {

    private static final String BUCKET = "estate-crm";

    @Test
    void storesUnderTheKeyTheRowWillRecord() {
        S3Client s3 = mock(S3Client.class);
        S3DocumentStorage storage = new S3DocumentStorage(s3, BUCKET);
        byte[] bytes = "a signed contract".getBytes(StandardCharsets.UTF_8);

        String key = storage.store(
                new MockMultipartFile("file", "Договор №14.pdf", "application/pdf", bytes),
                "deals", 7L, "pdf");

        assertThat(key).startsWith("deals/7/").endsWith(".pdf");
        assertThat(key).doesNotContain("Договор");

        ArgumentCaptor<PutObjectRequest> put = ArgumentCaptor.forClass(PutObjectRequest.class);
        verify(s3).putObject(put.capture(), any(RequestBody.class));
        assertThat(put.getValue().bucket()).isEqualTo(BUCKET);
        assertThat(put.getValue().key()).isEqualTo(key);
        assertThat(put.getValue().contentType()).isEqualTo("application/pdf");
    }

    @Test
    void readsTheBytesBack() throws Exception {
        S3Client s3 = mock(S3Client.class);
        byte[] bytes = "a signed contract".getBytes(StandardCharsets.UTF_8);
        when(s3.getObjectAsBytes(any(GetObjectRequest.class))).thenReturn(
                ResponseBytes.fromByteArray(GetObjectResponse.builder().build(), bytes));

        var resource = new S3DocumentStorage(s3, BUCKET).load("7/abc.pdf");

        assertThat(resource.getContentAsByteArray()).isEqualTo(bytes);
    }

    @Test
    void aKeyTheBucketNeverHeardOfIsAMissingFile() {
        S3Client s3 = mock(S3Client.class);
        when(s3.getObjectAsBytes(any(GetObjectRequest.class)))
                .thenThrow(NoSuchKeyException.builder().message("nope").build());

        assertThatThrownBy(() -> new S3DocumentStorage(s3, BUCKET).load("deals/7/gone.pdf"))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("missing from storage");
    }

    @Test
    void removingSomethingAlreadyGoneIsNotAnError() {
        S3Client s3 = mock(S3Client.class);
        when(s3.deleteObject(any(DeleteObjectRequest.class)))
                .thenThrow(NoSuchKeyException.builder().message("nope").build());

        new S3DocumentStorage(s3, BUCKET).delete("deals/7/gone.pdf");
    }

    @Test
    void refusesToStartWithoutABucket() {
        assertThatThrownBy(() -> new S3DocumentStorage(mock(S3Client.class), ""))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("S3_BUCKET");
    }
}
