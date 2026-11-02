package com.medicare.util;

public final class Html {
  private Html() {}

  public static String escape(Object v) {
    return v == null
        ? ""
        : v.toString()
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
  }
}
