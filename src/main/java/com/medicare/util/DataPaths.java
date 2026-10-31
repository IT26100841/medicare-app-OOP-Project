package com.medicare.util;

import java.nio.file.*;

public final class DataPaths {
  private DataPaths() {}

  public static Path root() {
    String configured = System.getProperty("medicare.data.dir", System.getenv("MEDICARE_DATA_DIR"));
    Path root =
        Paths.get(
                configured == null || configured.isBlank()
                    ? System.getProperty("user.home") + "/medicare-data"
                    : configured)
            .toAbsolutePath()
            .normalize();
    try {
      Files.createDirectories(root);
    } catch (java.io.IOException e) {
      throw new IllegalStateException("Cannot create data directory", e);
    }
    return root;
  }
}
