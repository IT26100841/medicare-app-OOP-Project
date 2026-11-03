package com.medicare.service;

import com.medicare.dao.impl.AbstractFileDAO;
import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import java.util.*;

public class BillingService {
  public Bill create(int appointmentId) {
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
      Bill b = new Bill(appointmentId, a.getPatientId(), d.getConsultationFee(), "Cash", "Unpaid");
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
