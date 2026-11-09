# MEDICARE CLINIC MANAGEMENT SYSTEM
## Comprehensive Project & User Manual (පද්ධති මෙහෙයුම් සහ තාක්ෂණික අත්පොත)

**Course:** SE1020 Object Oriented Programming  
**Application Type:** Java Web Application (MVC Architecture)  
**Technology:** Java Servlet (javax.servlet), JSP, JDBC, MySQL, HTML5/CSS3/JavaScript  
**Build Tool:** Apache Maven  
**Target Application Server:** Apache Tomcat 9 (JDK 11+)  
**Document Version:** 1.0 (Coursework Release)

---

## 1. System Overview (පද්ධතිය පිළිබඳ හැඳින්වීම)

Medicare යනු රෝහල්/සායන කළමනාකරණය සඳහා නිර්මාණය කරන ලද සම්පූර්ණ Java Web Application එකකි. මෙහි ප්‍රධාන වශයෙන් වෙන වෙනම පිවිසුම් ද්වාර (Entrances) දෙකක් පවතී:

1. **Patient Self-Service Portal (`/portal`):** රෝගීන්ට තමන්ගේම ගිණුමක් සාදාගැනීම, වෛද්‍යවරුන්ගේ වේලාවන් (Published Slots) පරීක්ෂා කිරීම, Appointment එකක් වෙන්කරවා ගැනීම (Booking), Cancellation කිරීම සහ Notifications බලාගැනීම සඳහායි.
2. **Internal Hospital Management Portal (`/login.jsp`):** රෝහල් කාර්ය මණ්ඩලය (Receptionist, Doctors, Administrators) සඳහා රෝගීන් ලියාපදිංචිය, Check-in කිරීම, Consultation සහ Prescription ලිවීම, Invoice/Billing සකස් කිරීම, සහ පරිශීලක ගිණුම් කළමනාකරණය සඳහායි.

පද්ධතියේ ප්‍රධානතම ලක්ෂණය වන්නේ **Dual-Storage Support** (MySQL Database Mode සහ File Storage Mode) එකම කේත පදනමක් (Single Codebase) තුළ Polymorphism ආධාරයෙන් ක්‍රියාත්මක වීමයි.

---

## 2. Technology Stack & Prerequisites (තාක්ෂණික අවශ්‍යතා)

| Component | Required Version | Important Notes |
|---|---|---|
| **Java Development Kit (JDK)** | JDK 11 හෝ JDK 17 | Java 11 bytecode target එකට compile වේ. |
| **Servlet Container** | **Apache Tomcat 9.0.x** | ⚠️ **Tomcat 10 හෝ 11 භාවිත කළ නොහැක** (`javax.servlet` namespace භාවිත වන බැවින්). |
| **Database Server** | MySQL 8.0.x හෝ MariaDB 10.4+ | Default port: `3306` |
| **Build Tool** | Apache Maven 3.8+ | `mvnw` wrapper එක project එක තුළම ඇත. |
| **IDE** | IntelliJ IDEA / Eclipse / VS Code | IntelliJ IDEA Ultimate or Community (Smart Tomcat plugin) නිර්දේශිතයි. |
| **Web Browser** | Chrome, Edge, Firefox | Headless Chromium 131+ දක්වා mobile/desktop responsive පරීක්ෂා කර ඇත. |

---

## 3. Installation & Setup Guide (පද්ධතිය ස්ථාපනය කිරීමේ පියවර)

### පියවර 1: Source Code එක IDE එකට Load කිරීම
1. IntelliJ IDEA විවෘත කරන්න.
2. `File` → `Open` වෙත ගොස් `medicare-app` folder එකේ ඇති **`pom.xml`** file එක තෝරා **Open as Project** ලබාදෙන්න.
3. Maven dependencies බාගත වන තෙක් මද වේලාවක් රැඳෙන්න.
4. Project SDK එක ලෙස **JDK 11** හෝ **JDK 17** තෝරන්න (`File` → `Project Structure` → `Project` → `SDK`).

### පියවර 2: Database එක සකස් කිරීම (DB Mode සඳහා)
පහත ක්‍රම දෙකෙන් එකක් තෝරාගන්න:

* **ක්‍රමය A (දැනට ඇති `medicare_db` එක upgrade කර ගැනීම - පහසුම ක්‍රමය):**
  1. MySQL Workbench හෝ phpMyAdmin විවෘත කරන්න.
  2. `database/upgrade-reviewed.sql` file එක run කරන්න. (මෙහි අලුත් columns සහ constraints එකතු වේ).
* **ක්‍රමය B (අලුත්ම Database එකක් ලෙස import කිරීම):**
  1. `database/medicare-database-updated.sql` file එක MySQL තුළ execute කරන්න.
  2. මෙය `medicare_db_updated` නමින් අලුත් database එකක් සාදයි.

### පියවර 3: Apache Tomcat 9 Configure කිරීම
1. IntelliJ හි `Run` → `Edit Configurations...` වෙත යන්න.
2. `+` ලකුණ ඔබා **Tomcat Server** → **Local** තෝරන්න (නැතහොත් Smart Tomcat plugin එක භාවිත කරන්න).
3. Tomcat Home directory එක ලෙස ඔබගේ පරිගණකයේ ඇති **Tomcat 9** folder එක තෝරන්න.
4. `Deployment` tab එකට ගොස් `+` ඔබා `medicare-app:war` හෝ `medicare-app:war exploded` තෝරන්න.
5. **Application Context** එක ලෙස **`/medicare-app`** ලබාදෙන්න.

### පියවර 4: VM Options ලබාදීම (Storage Configuration)
Tomcat Run Configuration එකෙහි **VM options** කොටුව තුළ පහත parameter ඇතුළත් කරන්න:

#### Database Mode සඳහා:
```bash
-Dmedicare.storage=DB
-Dmedicare.db.url=jdbc:mysql://localhost:3306/medicare_db
-Dmedicare.db.user=root
-Dmedicare.db.password=YOUR_MYSQL_PASSWORD
```
*(ඔබගේ MySQL password එක වෙනස් නම් `YOUR_MYSQL_PASSWORD` වෙනුවට එය ඇතුළත් කරන්න).*

#### File Mode සඳහා (Database නොමැතිව ධාවනය කිරීමට):
```bash
-Dmedicare.storage=FILE
-Dmedicare.data.dir=C:/medicare-data
```

### පියවර 5: Application එක ධාවනය කිරීම (Run)
1. Tomcat Server එක **Run** හෝ **Debug** කරන්න.
2. Browser එක විවෘත කර පහත URL ඔස්සේ පිවිසෙන්න:
   * **Patient Portal:** `http://localhost:8080/medicare-app/portal`
   * **Staff / Admin Login:** `http://localhost:8080/medicare-app/login.jsp`

---

## 4. User Accounts & Default Credentials (පරිශීලක ගිණුම් විස්තර)

පද්ධතිය පරීක්ෂා කිරීම (Demo / Testing) සඳහා භාවිත කළ හැකි පෙරනිමි ගිණුම්:

| Role | Username | Password | Purpose & Accessible Pages |
|---|---|---|---|
| **Administrator** | `admin` | `admin123` | System settings, User management, Doctor scheduling, Audit logs, Full Access |
| **Staff / Receptionist** | `staff` | `staff123` | Patient CRUD, Check-in arrivals, Billing, Invoices |
| **Doctor** | `doctor` | `doc123` | Assigned consultations, Clinical records, Prescription writing |
| **Patient** | *(Self-registered email)* | *(User-created password)* | Patient Portal, View Slots, Book Appointment, Cancel Own Appointment |

---

## 5. Module-by-Module Operation Guide (පද්ධතියේ මොඩියුල ක්‍රියාත්මක වන ආකාරය)

### මොඩියුලය 1: Patient Self-Service Portal (රෝගී පිවිසුම)
* **URL:** `/portal`
* **පියවර:**
  1. නව රෝගියෙකු නම් **Create an account** ක්ලික් කර නම, දුරකථන අංකය, ඊමේල් සහ මුරපදය ලබාදී register වන්න.
  2. Login වූ පසු තමන්ගේ ඉදිරි Appointments, වෛද්‍ය ඉතිහාසය සහ Notifications බලාගත හැක.
  3. **Book Appointment:** වෛද්‍යවරයා, දිනය සහ Available Time Slot එකක් තෝරා Reason එක ඇතුළත් කර **Book** කරන්න.
  4. වෙන්කරගත් වහාම System එක මඟින් Confirmation Notification එකක් ජනනය වේ.
  5. අවශ්‍ය නම් අනාගත දිනයක ඇති Appointment එකක් **Cancel** කළ හැක (තමන්ගේ නොවන වෙනත් අයගේ bookings cancel කිරීමට system එක ඉඩ නොදේ).

### මොඩියුලය 2: Front Desk & Reception Workflow (පිළිගැනීමේ අංශය)
* **පියවර:**
  1. `staff` ගිණුමෙන් Login වන්න.
  2. **Patients Menu:** රෝගීන් අලුතින් ඇතුළත් කිරීම (Add), විස්තර වෙනස් කිරීම (Edit), සෙවීම (Search) කළ හැක.
  3. **Check-in Process:** අද දින පැමිණි රෝගියා හඳුනාගෙන Appointments ලැයිස්තුවෙන් **Check-in** බොත්තම ඔබන්න. Appointment Status එක `Checked-in` බවට පත්වේ.

### මොඩියුලය 3: Doctor Consultation & Clinical Workflow (වෛද්‍ය අංශය)
* **පියවර:**
  1. `doctor` ගිණුමෙන් Login වන්න.
  2. Doctor Dashboard එකෙහි තමන් වෙත යොමු කර ඇති `Checked-in` රෝගීන් පෙන්වයි.
  3. **Start Consultation:** බොත්තම එබූ විට Status එක `In consultation` බවට පත්වේ.
  4. රෝගියා පරීක්ෂා කිරීමෙන් පසු **Diagnosis**, **Prescription (ඖෂධ විස්තර)**, සහ **Clinical Notes** ඇතුළත් කර **Save & Complete** කරන්න.
  5. Status එක `Completed` බවට පත්වන අතර, ඖෂධ වට්ටෝරුව **PDF** එකක් ලෙස බාගත කර මුද්‍රණය කළ හැක.

### මොඩියුලය 4: Billing, Invoicing & Payments (බිල්පත් සහ ගෙවීම්)
* **පියවර:**
  1. Consultation එක අවසන් වූ පසු Receptionist හට එම visit එක සඳහා Bill එකක් සැකසිය හැක.
  2. **Charges Breakdown:**
     * **Doctor Consultation Fee:** වෛද්‍යවරයාගේ profile එකෙන් ස්වයංක්‍රීයව snapshot එකක් ලෙස පැමිණේ.
     * **Hospital Charge:** රෝහල් ගාස්තුව ඇතුළත් කරන්න.
     * **Medical Treatment / Pharmacy Charge:** ඖෂධ හෝ ප්‍රතිකාර ගාස්තු ඇතුළත් කරන්න.
  3. Grand Total එක ස්වයංක්‍රීයව ගණනය වන අතර **Generate Invoice** ලබාදෙන්න.
  4. ගෙවීම් පියවූ පසු (Cash / Card) Status එක **Paid** ලෙස update කර **Printable Invoice** එක PDF / Browser print ලබාගත හැක.

### මොඩියුලය 5: Admin & System Administration (පරිපාලන අංශය)
* **පියවර:**
  1. `admin` ගිණුමෙන් Login වන්න.
  2. **Doctors & Availability:** නව වෛද්‍යවරුන් ඇතුළත් කිරීම සහ ඔවුන්ගේ සතිපතා සායන වේලාවන් (Published Slots) සම්පාදනය කිරීම.
  3. **Team & Access:** නව Staff / Doctor accounts සෑදීම සහ Doctor profile එක Login account එකකට link කිරීම.
  4. **Audit Logs:** පද්ධතිය තුළ සිදුවූ වැදගත් සිදුවීම් (Logins, Failed deletions, State changes) පිළිබඳ විගණන සටහන් නැරඹීම.

---

## 6. Architecture & Design Patterns (මෘදුකාංග ගෘහ නිර්මාණ ශිල්පය)

1. **MVC Pattern:**
   * **Model:** `com.medicare.model.*` (Patient, Doctor, Appointment, Bill ආදී දත්ත ව්‍යුහයන්).
   * **View:** `src/main/webapp/*.jsp` (JSP පිටු සහ views).
   * **Controller:** `com.medicare.servlet.*` (HTTP Requests භාරගන්නා Servlets).
2. **DAO (Data Access Object) Pattern:**
   * Business logic එක සහ Storage logic එක වෙන් කර ඇත (`PatientDAO`, `BillDAO` interfaces).
3. **Factory Pattern (`DAOFactory`):**
   * Runtime එකේදී System configuration එක අනුව File DAOs ද Database DAOs ද යන්න තීරණය කර නිවැරදි Object එක ලබාදෙයි.
4. **State Pattern / Finite State Machine:**
   * `AppointmentStatus.java` Enum එක මඟින් වලංගු නොවන status transitions (උදා: Booked සිට කෙළින්ම Completed වීම) වළක්වයි.

---

## 7. Troubleshooting & FAQs (පොදු ගැටලු සහ විසඳුම්)

### ගැටලුව 1: `jakarta.servlet.ServletException` හෝ Deployment Fails
* **හේතුව:** ඔබ Apache Tomcat 10 හෝ 11 භාවිත කිරීම.
* **විසඳුම:** මෙම project එක Java EE (`javax.servlet`) පදනම් කරගත් එකක් බැවින් අනිවාර්යයෙන්ම **Apache Tomcat 9.0.x** භාවිත කරන්න.

### ගැටලුව 2: Port 8080 already in use
* **හේතුව:** වෙනත් server එකක් (Oracle, Jenkins හෝ වෙනත් Tomcat) port 8080 භාවිත කිරීම.
* **විසඳුම:** Tomcat configuration හි HTTP port එක `8081` හෝ `8085` ලෙස වෙනස් කරන්න.

### ගැටලුව 3: MySQL Connection Refused / Access Denied
* **හේතුව:** MySQL server එක start කර නොතිබීම හෝ password එක වැරදි වීම.
* **විසඳුම:** XAMPP / MySQL Service එක running දැයි බලන්න. VM options හි ඔබගේ නිවැරදි password එක ලබාදී ඇත්දැයි තහවුරු කරගන්න.

### ගැටලුව 4: Patient Record එක Delete කිරීමට නොහැකි වීම
* **හේතුව:** ආරක්ෂිත පියවරක් ලෙස (CSRF & Role check) Patient Deletion සඳහා Admin අනුමැතිය අවශ්‍ය වන අතර එය POST request එකක් මඟින් පමණක් ක්‍රියාත්මක වේ. සාමාන්‍ය Staff සාමාජිකයින්ට Delete කළ නොහැක.

---

## 8. Verification & Running Automated Tests (පරීක්ෂා කිරීම)

Project එකෙහි ඇති සියලුම Unit Tests සහ Regression Tests ධාවනය කිරීමට:

```bash
mvn test
```
* **ප්‍රතිඵලය:** Tests 46 ක් ධාවනය වන අතර, සියල්ල සාර්ථකව Pass විය යුතුය (Windows non-elevated පරිසරවල symlink test 1 ක් skip වීම සාමාන්‍ය වේ).

---
*Medicare Clinic Management System — SE1020 Coursework Documentation.*
