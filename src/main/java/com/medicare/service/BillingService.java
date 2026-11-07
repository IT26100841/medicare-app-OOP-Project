package com.medicare.service;

import com.medicare.dao.impl.AbstractFileDAO;
import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import java.util.*;

public class BillingService {
  public Bill create(int appointmentId) {
    return create(appointmentId, "0", "0");
  }

  private java.math.BigDecimal money(String raw) {
    if (raw == null || raw.isBlank()) return java.math.BigDecimal.ZERO.setScale(2);
    try {
      java.math.BigDecimal n = new java.math.BigDecimal(raw.trim());
      if (n.signum() < 0
          || n.compareTo(new java.math.BigDecimal("9999999999.99")) > 0
          || n.scale() > 2) throw new NumberFormatException();
      return n.setScale(2);
    } catch (NumberFormatException ex) {
      throw new IllegalArgumentException(
          "Charges must be non-negative amounts with at most two decimal places (maximum LKR"
              + " 9,999,999,999.99)");
    }
  }

  public Bill create(int appointmentId, String hospital, String treatment) {
    java.math.BigDecimal h = money(hospital), t = money(treatment);
    synchronized (AbstractFileDAO.LOCK) {
      Appointment a = DAOFactory.getAppointmentDAO().getAppointmentById(appointmentId);
      if (a == null || !"Completed".equals(a.getStatus()))
        throw new IllegalArgumentException(
            "Invoices can only be created for completed consultations");
      for (Bill b : DAOFactory.getBillDAO().getAllBills())
        if (b.getAppointmentId() == appointmentId)
          throw new IllegalArgumentException("An invoice already exists for this visit");
      Doctor d = DAOFactory.getDoctorDAO().getDoctorById(a.getDoctorId());
      if (d == null) throw new IllegalArgumentException("Doctor not found");
      java.math.BigDecimal consultation = money(String.valueOf(d.getConsultationFee()));
      java.math.BigDecimal total = consultation.add(h).add(t);
      money(total.toPlainString());
      Bill b = new Bill(appointmentId, a.getPatientId(), total.doubleValue(), "Cash", "Unpaid");
      b.setConsultationCharge(consultation.doubleValue());
      b.setHospitalCharge(h.doubleValue());
      b.setTreatmentCharge(t.doubleValue());
      if (!DAOFactory.getBillDAO().createBill(b))
        throw new IllegalStateException("Invoice was not saved");
      return b;
    }
  }

  public void pay(int id, String method) {
    synchronized (AbstractFileDAO.LOCK) {
      if (!Arrays.asList("Cash", "Card", "Bank transfer").contains(method))
        throw new IllegalArgumentException("Select a supported payment method");
      Bill bill = DAOFactory.getBillDAO().getBillById(id);
      if (bill == null) throw new IllegalArgumentException("Invoice not found");
      if ("Paid".equals(bill.getPaymentStatus()))
        throw new IllegalArgumentException("This invoice has already been paid");
      if (!DAOFactory.getBillDAO().updatePaymentStatus(id, method, "Paid"))
        throw new IllegalStateException("Payment was not recorded");
    }
  }
}
