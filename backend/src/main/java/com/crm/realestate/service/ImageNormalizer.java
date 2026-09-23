package com.crm.realestate.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.Optional;

/**
 * Reads what a phone sends and decides whether the app can draw it.
 *
 * <p>The check is on the first bytes rather than the file name, because a name is whatever the
 * client says it is: an iPhone photograph named {@code .jpg} is still HEIC inside, and it would be
 * stored happily and then drawn as an empty tile — Flutter's decoders are JPEG, PNG, GIF, WebP and
 * BMP, and HEIC is not among them. Refusing it at the door is the only answer that reaches the
 * person who can do something about it.
 */
@Component
@Slf4j
public class ImageNormalizer {

    /** The longest side of the copy a list shows. */
    static final int THUMBNAIL_SIZE = 480;

    private static final byte[] JPEG = {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF};
    private static final byte[] PNG = {(byte) 0x89, 'P', 'N', 'G'};
    private static final byte[] GIF = {'G', 'I', 'F', '8'};
    private static final byte[] BMP = {'B', 'M'};

    /** What the bytes actually are, whatever the name claims. */
    public Optional<String> contentTypeOf(byte[] head) {
        if (startsWith(head, JPEG)) return Optional.of("image/jpeg");
        if (startsWith(head, PNG)) return Optional.of("image/png");
        if (startsWith(head, GIF)) return Optional.of("image/gif");
        if (startsWith(head, BMP)) return Optional.of("image/bmp");
        // RIFF....WEBP — the size sits between the two markers.
        if (startsWith(head, new byte[] {'R', 'I', 'F', 'F'})
                && head.length >= 12
                && startsWith(Arrays.copyOfRange(head, 8, 12), new byte[] {'W', 'E', 'B', 'P'})) {
            return Optional.of("image/webp");
        }
        return Optional.empty();
    }

    /**
     * A smaller JPEG copy, or empty when this image cannot be decoded here.
     *
     * <p>Stock ImageIO reads JPEG, PNG, GIF and BMP but not WebP, so a WebP upload is stored whole
     * and listed without a thumbnail rather than refused — it is a format the app can draw, which
     * is the question that matters at the door.
     */
    public Optional<byte[]> thumbnail(MultipartFile file) {
        try (InputStream in = file.getInputStream()) {
            BufferedImage source = ImageIO.read(in);
            if (source == null) {
                return Optional.empty();
            }
            return Optional.of(toJpeg(scaled(source)));
        } catch (IOException | RuntimeException e) {
            log.info("No thumbnail for {}: {}", file.getOriginalFilename(), e.getMessage());
            return Optional.empty();
        }
    }

    private BufferedImage scaled(BufferedImage source) {
        int longest = Math.max(source.getWidth(), source.getHeight());
        if (longest <= THUMBNAIL_SIZE) {
            return source;
        }
        double factor = (double) THUMBNAIL_SIZE / longest;
        int width = Math.max(1, (int) Math.round(source.getWidth() * factor));
        int height = Math.max(1, (int) Math.round(source.getHeight() * factor));

        BufferedImage target = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = target.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION,
                RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        g.drawImage(source, 0, 0, width, height, null);
        g.dispose();
        return target;
    }

    /** Flattened onto white: a transparent PNG turned into JPEG is black otherwise. */
    private byte[] toJpeg(BufferedImage image) throws IOException {
        BufferedImage opaque = new BufferedImage(
                image.getWidth(), image.getHeight(), BufferedImage.TYPE_INT_RGB);
        Graphics2D g = opaque.createGraphics();
        g.drawImage(image, 0, 0, java.awt.Color.WHITE, null);
        g.dispose();

        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ImageIO.write(opaque, "jpg", out);
        return out.toByteArray();
    }

    private static boolean startsWith(byte[] bytes, byte[] prefix) {
        if (bytes.length < prefix.length) return false;
        for (int i = 0; i < prefix.length; i++) {
            if (bytes[i] != prefix[i]) return false;
        }
        return true;
    }
}
