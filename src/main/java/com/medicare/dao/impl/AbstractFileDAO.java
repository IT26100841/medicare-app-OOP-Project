package com.medicare.dao.impl;

import com.medicare.util.DataPaths;
import java.beans.*;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;

/**
 * Shared file storage: escaped TSV, complete bean fields, atomic replace and a JVM-wide lock. One
 * application instance must own a data directory. Never edit these files while running.
 */
public abstract class AbstractFileDAO<T> {
  public static final Object LOCK = new Object();
  private final String fileName;
  private final Class<T> type;
  private final String[] fields;

  protected AbstractFileDAO(String fileName, Class<T> type, String... fields) {
    this.fileName = fileName;
    this.type = type;
    this.fields = fields;
  }

  private PropertyDescriptor property(String name) throws Exception {
    for (PropertyDescriptor p : Introspector.getBeanInfo(type).getPropertyDescriptors())
      if (p.getName().equals(name)) return p;
    throw new IllegalStateException("Unknown field: " + name);
  }

  private static String encode(Object value) {
    return value == null
        ? "\\N"
        : value
            .toString()
            .replace("\\", "\\\\")
            .replace("\t", "\\t")
            .replace("\n", "\\n")
            .replace("\r", "\\r");
  }

  private static String decode(String value) {
    if (value.equals("\\N")) return null;
    StringBuilder out = new StringBuilder();
    boolean escaped = false;
    for (char c : value.toCharArray()) {
      if (escaped) {
        out.append(c == 't' ? '\t' : c == 'n' ? '\n' : c == 'r' ? '\r' : c);
        escaped = false;
      } else if (c == '\\') escaped = true;
      else out.append(c);
    }
    if (escaped) throw new IllegalStateException("Invalid escape in data file");
    return out.toString();
  }

  protected List<T> readAll() {
    synchronized (LOCK) {
      Path path = DataPaths.root().resolve(fileName);
      if (!Files.exists(path)) return new ArrayList<>();
      try {
        List<String> lines = Files.readAllLines(path, StandardCharsets.UTF_8);
        List<T> result = new ArrayList<>();
        if (lines.isEmpty()) return result;
        if (!lines.get(0).equals("#medicare-tsv-v1\t" + String.join("\t", fields)))
          throw new IOException(
              "Unsupported file format: " + fileName + "; migrate legacy CSV first");
        for (int line = 1; line < lines.size(); line++) {
          if (lines.get(line).isBlank()) continue;
          String[] parts = lines.get(line).split("\t", -1);
          if (parts.length != fields.length)
            throw new IOException("Invalid row " + (line + 1) + " in " + fileName);
          T bean = type.getDeclaredConstructor().newInstance();
          for (int i = 0; i < fields.length; i++) {
            PropertyDescriptor p = property(fields[i]);
            String value = decode(parts[i]);
            Object parsed = value;
            if (p.getPropertyType() == int.class) parsed = Integer.parseInt(value);
            if (p.getPropertyType() == double.class) parsed = Double.parseDouble(value);
            p.getWriteMethod().invoke(bean, parsed);
          }
          result.add(bean);
        }
        return result;
      } catch (Exception e) {
        throw new IllegalStateException("Cannot read " + fileName, e);
      }
    }
  }

  protected boolean writeAll(List<T> rows) {
    synchronized (LOCK) {
      Path temp = null;
      try {
        Path path = DataPaths.root().resolve(fileName);
        temp = Files.createTempFile(path.getParent(), fileName, ".tmp");
        try (BufferedWriter w = Files.newBufferedWriter(temp, StandardCharsets.UTF_8)) {
          w.write("#medicare-tsv-v1\t" + String.join("\t", fields));
          w.newLine();
          for (T bean : rows) {
            List<String> values = new ArrayList<>();
            for (String field : fields)
              values.add(encode(property(field).getReadMethod().invoke(bean)));
            w.write(String.join("\t", values));
            w.newLine();
          }
        }
        try {
          Files.move(
              temp, path, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE);
        } catch (AtomicMoveNotSupportedException e) {
          Files.move(temp, path, StandardCopyOption.REPLACE_EXISTING);
        }
        return true;
      } catch (Exception e) {
        throw new IllegalStateException("Cannot save " + fileName, e);
      } finally {
        if (temp != null)
          try {
            Files.deleteIfExists(temp);
          } catch (IOException ignored) {
          }
      }
    }
  }

  protected T find(java.util.function.Predicate<T> match) {
    for (T value : readAll()) if (match.test(value)) return value;
    return null;
  }

  protected boolean insert(T bean) {
    synchronized (LOCK) {
      List<T> rows = readAll();
      rows.add(bean);
      return writeAll(rows);
    }
  }

  protected boolean replace(T bean, java.util.function.Predicate<T> match) {
    synchronized (LOCK) {
      List<T> rows = readAll();
      for (int i = 0; i < rows.size(); i++)
        if (match.test(rows.get(i))) {
          rows.set(i, bean);
          return writeAll(rows);
        }
      return false;
    }
  }

  protected boolean remove(java.util.function.Predicate<T> match) {
    synchronized (LOCK) {
      List<T> rows = readAll();
      return rows.removeIf(match) && writeAll(rows);
    }
  }

  protected List<T> search(String keyword, java.util.function.Function<T, String> text) {
    String term = keyword == null ? "" : keyword.toLowerCase(Locale.ROOT).trim();
    List<T> result = new ArrayList<>();
    for (T bean : readAll())
      if (text.apply(bean).toLowerCase(Locale.ROOT).contains(term)) result.add(bean);
    return result;
  }
}
