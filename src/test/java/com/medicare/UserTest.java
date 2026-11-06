package com.medicare;

import static org.junit.Assert.*;

import com.medicare.model.Person;
import com.medicare.model.User;
import com.medicare.util.Passwords;
import com.medicare.util.Validation;
import org.junit.Test;

/**
 * Unit Tests for Member 6: User Entity, OOP Principles, and Security Utilities.
 */
public class UserTest {

  @Test
  public void testUserInheritanceAndPolymorphism() {
    User user = new User(1, "admin1", "pass123", "ADMIN", "System Admin", "admin@medicare.com");

    // Test Polymorphism: User is an instance of abstract Person
    assertTrue("User must be an instance of Person", user instanceof Person);

    // Test method overriding from Person
    assertEquals("Role label should be overridden as 'User'", "User", user.getRoleLabel());

    // Test inherited concrete method from Person
    assertEquals("Display name format from Person", "User: System Admin", user.getDisplayName());
  }

  @Test
  public void testUserEncapsulationAndConstructors() {
    // Test constructor overloading (3 params)
    User u1 = new User("doctor_john", "secret", "DOCTOR");
    assertEquals("doctor_john", u1.getUsername());
    assertEquals("DOCTOR", u1.getRole());

    // Test full constructor (6 params)
    User u2 = new User(10, "staff_ann", "secret", "STAFF", "Ann Watson", "ann@medicare.com");
    assertEquals(10, u2.getId());
    assertEquals("ann@medicare.com", u2.getEmail());

    // Test setters (Encapsulation)
    u2.setEmail("ann.watson@medicare.com");
    assertEquals("ann.watson@medicare.com", u2.getEmail());
  }

  @Test
  public void testPasswordHashingAndVerification() {
    String rawPassword = "AdminSecurePass123";
    String hashedPassword = Passwords.hash(rawPassword);

    assertNotNull("Hashed password must not be null", hashedPassword);
    assertNotEquals("Hash must not equal plain password", rawPassword, hashedPassword);
    assertTrue("Hash must be marked as encoded", Passwords.encoded(hashedPassword));
    assertTrue("Valid password should verify successfully", Passwords.verify(rawPassword, hashedPassword));
    assertFalse("Incorrect password must fail verification", Passwords.verify("WrongPass", hashedPassword));
  }

  @Test
  public void testValidationUtilities() {
    // Valid input should return trimmed string
    assertEquals("ValidName", Validation.required("  ValidName  ", "Name"));

    // Blank or null should throw IllegalArgumentException
    try {
      Validation.required("   ", "Field");
      fail("Expected IllegalArgumentException for blank input");
    } catch (IllegalArgumentException expected) {
      // Expected
    }

    // Email validation
    assertEquals("test@medicare.com", Validation.email("test@medicare.com"));
    try {
      Validation.email("invalid-email-format");
      fail("Expected IllegalArgumentException for invalid email");
    } catch (IllegalArgumentException expected) {
      // Expected
    }
  }
}
