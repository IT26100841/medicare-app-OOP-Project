package com.medicare.dao.impl;

import java.util.*;

/** Typed repository for supporting hospital modules. */
public class EntryFileDAO<T> extends AbstractFileDAO<T> {
  public EntryFileDAO(String name, Class<T> type, String... fields) {
    super(name, type, fields);
  }

  public boolean delete(java.util.function.Predicate<T> match) {
    return remove(match);
  }

  public List<T> list() {
    return readAll();
  }

  public boolean save(T entry) {
    return insert(entry);
  }

  public boolean update(T entry, java.util.function.Predicate<T> match) {
    return replace(entry, match);
  }
}
