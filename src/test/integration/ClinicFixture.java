import com.medicare.factory.DAOFactory;import com.medicare.model.*;import java.time.*;
public class ClinicFixture{public static void main(String[] args){Appointment a=new Appointment(args[0],"D001",LocalDate.now().toString(),"08:00","Same-day workflow fixture","Booked");if(!DAOFactory.getAppointmentDAO().addAppointment(a))throw new IllegalStateException("Fixture not added");}}
