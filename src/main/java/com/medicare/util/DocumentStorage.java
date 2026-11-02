package com.medicare.util;

import java.io.*;
import java.nio.file.*;

public final class DocumentStorage {
  private DocumentStorage() {}

  public static Path root() throws IOException {
    Path p = DataPaths.root().resolve("uploads");
    Files.createDirectories(p);
    return p.toRealPath();
  }

  public static Path resolve(String name) throws IOException {
    if (name == null
        || name.isBlank()
        || name.contains("/")
        || name.contains("\\")
        || name.equals(".")
        || name.equals("..")) throw new IllegalArgumentException("Invalid document path");
    Path root = root();
    Path path = root.resolve(name).normalize();
    if (!path.startsWith(root)) throw new IllegalArgumentException("Invalid document path");
    if (Files.exists(path) && !path.toRealPath().startsWith(root))
      throw new IllegalArgumentException("Invalid document path");
    return path;
  }
}
