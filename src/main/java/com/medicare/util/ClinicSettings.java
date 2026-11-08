package com.medicare.util;

import java.io.*;
import java.nio.file.*;
import java.util.*;

public final class ClinicSettings {
  private ClinicSettings() {}

  public static Properties read() {
    Properties p = new Properties();
    p.setProperty("name", "Medicare");
    p.setProperty("phone", "+94 11 234 5678");
    p.setProperty("address", "123 Healthcare Avenue, Colombo");
    Path f = DataPaths.root().resolve("clinic.properties");
    if (Files.exists(f))
      try (InputStream in = Files.newInputStream(f)) {
        p.load(in);
      } catch (IOException e) {
        throw new IllegalStateException(e);
      }
    return p;
  }

  public static String get(String key) {
    return read().getProperty(key, "");
  }

  public static synchronized void save(String name, String phone, String address) {
    Properties p = read();
    p.setProperty("name", Validation.required(name, "Clinic name"));
    p.setProperty("phone", Validation.required(phone, "Clinic contact"));
    p.setProperty("address", Validation.required(address, "Clinic address"));
    try {
      Path f = DataPaths.root().resolve("clinic.properties"),
          t = Files.createTempFile(f.getParent(), "clinic", ".tmp");
      try (OutputStream out = Files.newOutputStream(t)) {
        p.store(out, "Clinic identity");
      }
      Files.move(t, f, StandardCopyOption.REPLACE_EXISTING);
    } catch (IOException e) {
      throw new IllegalStateException("Cannot save clinic details", e);
    }
  }
}
