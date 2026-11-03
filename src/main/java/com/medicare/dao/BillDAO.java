package com.medicare.dao;

import com.medicare.model.Bill;
import java.util.List;

public interface BillDAO {
  boolean createBill(Bill bill);

  List<Bill> getAllBills();

  Bill getBillById(int billId);

  boolean updatePaymentStatus(int billId, String paymentMethod, String status);
}
