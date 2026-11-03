package com.medicare.dao.impl;

import com.medicare.dao.BillDAO;
import com.medicare.model.Bill;
import java.util.*;

public class BillDAOFileImpl extends AbstractFileDAO<Bill> implements BillDAO {
  public BillDAOFileImpl() {
    super(
        "bills.txt",
        Bill.class,
        "billId",
        "appointmentId",
        "patientId",
        "amount",
        "paymentMethod",
        "paymentStatus",
        "consultationCharge",
        "hospitalCharge",
        "treatmentCharge");
  }

  public List<Bill> getAllBills() {
    return readAll();
  }

  public Bill getBillById(int id) {
    return find(b -> b.getBillId() == id);
  }

  public boolean createBill(Bill b) {
    synchronized (LOCK) {
      b.setBillId(readAll().stream().mapToInt(Bill::getBillId).max().orElse(0) + 1);
      return insert(b);
    }
  }

  public boolean updatePaymentStatus(int id, String method, String status) {
    synchronized (LOCK) {
      Bill b = getBillById(id);
      if (b == null) return false;
      b.setPaymentMethod(method);
      b.setPaymentStatus(status);
      return replace(b, x -> x.getBillId() == id);
    }
  }
}
