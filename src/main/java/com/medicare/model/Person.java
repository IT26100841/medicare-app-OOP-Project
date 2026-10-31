package com.medicare.model;

/** Common contract shared by people in the hospital. Concrete roles supply the label. */
public abstract class Person {
  public abstract String getName();

  public abstract String getEmail();

  public abstract String getRoleLabel();

  public String getDisplayName() {
    return getRoleLabel() + ": " + getName();
  }
}
