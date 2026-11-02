package com.medicare.util;

import java.security.*;
import java.util.*;
import javax.crypto.*;
import javax.crypto.spec.PBEKeySpec;

public final class Passwords {
  private Passwords() {}

  private static final int ITERATIONS = 120000;

  public static boolean encoded(String value) {
    return value != null && value.startsWith("pbkdf2$");
  }

  public static String hash(String password) {
    if (password == null || password.isBlank())
      throw new IllegalArgumentException("Password is required");
    byte[] salt = new byte[16];
    new SecureRandom().nextBytes(salt);
    return "pbkdf2$"
        + ITERATIONS
        + "$"
        + Base64.getEncoder().encodeToString(salt)
        + "$"
        + Base64.getEncoder().encodeToString(derive(password, salt, ITERATIONS));
  }

  private static byte[] derive(String p, byte[] salt, int iterations) {
    PBEKeySpec spec = new PBEKeySpec(p.toCharArray(), salt, iterations, 256);
    try {
      return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
    } catch (GeneralSecurityException e) {
      throw new IllegalStateException(e);
    } finally {
      spec.clearPassword();
    }
  }

  public static boolean verify(String password, String stored) {
    if (password == null || stored == null) return false;
    if (!encoded(stored))
      return MessageDigest.isEqual(
          password.getBytes(java.nio.charset.StandardCharsets.UTF_8),
          stored.getBytes(java.nio.charset.StandardCharsets.UTF_8));
    try {
      String[] parts = stored.split("\\$");
      int iterations = Integer.parseInt(parts[1]);
      if (iterations < 10000 || iterations > 1000000) return false;
      return MessageDigest.isEqual(
          Base64.getDecoder().decode(parts[3]),
          derive(password, Base64.getDecoder().decode(parts[2]), iterations));
    } catch (RuntimeException e) {
      return false;
    }
  }
}
