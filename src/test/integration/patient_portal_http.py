"""Writes synthetic data: run only on a disposable demo backend."""
import argparse,time,urllib.request,urllib.parse,urllib.error,http.cookiejar,re,json,datetime
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--base',required=True);args=parser.parse_args();base=args.base.rstrip('/')+'/'
class Client:
 def __init__(self):self.op=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()));self.token=None
 def request(self,path,kw=None):
  try:
   x=self.op.open(base+path,None if kw is None else urllib.parse.urlencode(kw).encode());data=x.read().decode();code=x.status
  except urllib.error.HTTPError as e:code=e.code;data=e.read().decode()
  m=re.search(r"name=['\"]csrfToken['\"] value=['\"]([^'\"]+)",data)
  if m:self.token=m.group(1)
  return code,data
 def get(self,path):return self.request(path)
 def post(self,action,**kw):kw.update(action=action,csrfToken=self.token);return self.request('portal',kw)
a=Client();code,html=a.get("portal")
checks=[]
def check(name,condition):
 assert condition,name
 checks.append(name)
check('Public doctors visible','Demo Doctor' in html)
a.get('portal?view=register');email='http'+str(time.time_ns())+'@example.com'
code,html=a.post('register',email=email,password='StrongPassword123',name='HTTP Patient',age='25',gender='Other',phone='0700000002',address='Test address')
check('Registration opens personal portal',code==200 and 'Welcome, HTTP Patient.' in html)
check('Management dashboard denied',a.get('dashboard.jsp')[0]==403)
check('Direct clinical API denied',a.get('patient?action=list')[0]==403)
date=(datetime.date.today()+datetime.timedelta(days=2)).isoformat();code,html=a.get('portal?doctor=D001&date='+date);times=re.findall(r'<option>(\d\d:\d\d)</option>',html)
check('Published slots returned',code==200 and len(times)>0)
code,html=a.post('book',doctor='D001',date=date,time=times[0],reason='HTTP privacy test',patientId='P001',status='Completed')
check('Booking ignores forged identity and status',code==200 and 'HTTP privacy test' in html and 'Booked' in html)
appointment=re.search(r"name='appointment' value='(\d+)'",html).group(1)
b=Client();b.get('portal?view=register');email2='httpother'+str(time.time_ns())+'@example.com'
code,html=b.post('register',email=email2,password='StrongPassword123',name='Other Person',age='24',gender='Other',phone='0700000003',address='Other')
check('Other account cannot see first booking','HTTP privacy test' not in html)
check('Forged cancellation denied',b.post('cancel',appointment=appointment)[0]==403)
code,html=a.post('profile',name='<script>alert(1)</script>',phone='0700000004',address='Changed',patientId='P001')
check('Stored HTML escaped',code==200 and '&lt;script&gt;' in html and '<script>alert' not in html)
old=a.token;a.token='bad';check('Invalid CSRF denied',a.post('profile',name='Bad',phone='0700000004',address='Bad')[0]==403);a.token=old
code,html=a.post('cancel',appointment=appointment);check('Own future booking cancelled',code==200 and 'Cancelled' in html)
a.post('logout');a.get('portal?view=login');code,html=a.post('login',email=email,password='StrongPassword123');check('Patient sign in works',code==200 and 'My profile' in html)
team=Client();team.get('login.jsp');code,html=team.request('login',dict(username='admin',password='admin123',csrfToken=team.token));check('Management login works',code==200 and 'CLINIC WORKSPACE' in html)
code,html=team.get('patient');check('Patient visible to management',code==200 and email in html)
code,html=team.get('appointment');check('Booking visible to management',code==200 and ('Visit #'+appointment.zfill(4)) in html)
print(json.dumps(checks,indent=2))
