package com.medicare.util;

import com.medicare.dao.impl.AbstractFileDAO;
import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.function.Supplier;

/** In-process rollback for related FILE writes. Not a crash-recovery journal. */
public final class FileTransactions {
  private FileTransactions() {}

  public static <T> T run(Supplier<T> operation, String... names) {
    synchronized (AbstractFileDAO.LOCK) {
      Map<Path, byte[]> before = new LinkedHashMap<>();
      try {
        for (String name : names) {
          Path p = DataPaths.root().resolve(name);
          before.put(p, Files.exists(p) ? Files.readAllBytes(p) : null);
        }
      } catch (IOException e) {
        throw new IllegalStateException("Cannot snapshot data files", e);
      }
      try {
        return operation.get();
      } catch (RuntimeException error) {
        for (var entry : before.entrySet()) {
          try {
            if (entry.getValue() == null) Files.deleteIfExists(entry.getKey());
            else {
              Path temp = Files.createTempFile(entry.getKey().getParent(), "rollback-", ".tmp");
              Files.write(temp, entry.getValue());
              try {
                Files.move(
                    temp,
                    entry.getKey(),
                    StandardCopyOption.REPLACE_EXISTING,
                    StandardCopyOption.ATOMIC_MOVE);
              } catch (AtomicMoveNotSupportedException e) {
                Files.move(temp, entry.getKey(), StandardCopyOption.REPLACE_EXISTING);
              }
            }
          } catch (IOException rollback) {
            error.addSuppressed(rollback);
          }
        }
        throw error;
      }
    }
  }
}
