import urllib.request,urllib.parse,urllib.error,http.cookiejar,uuid
class Response:
 def __init__(self,r):
  self.status_code=r.code;self.url=r.url;self.headers=r.headers;self.content=r.read();self.text=self.content.decode('utf-8',errors='replace')
class NoRedirect(urllib.request.HTTPRedirectHandler):
 def redirect_request(self,req,fp,code,msg,headers,newurl):return None
class Session:
 def __init__(self):self.cookies=http.cookiejar.CookieJar()
 def get(self,url,**kw):return self.request(url,None,**kw)
 def post(self,url,data=None,files=None,**kw):
  if files:
   boundary=uuid.uuid4().hex;parts=[]
   for key,val in (data or {}).items():parts.append(('--'+boundary+'\r\nContent-Disposition: form-data; name="'+key+'"\r\n\r\n'+str(val)+'\r\n').encode())
   for key,(name,content,typ) in files.items():parts.append(('--'+boundary+'\r\nContent-Disposition: form-data; name="'+key+'"; filename="'+name+'"\r\nContent-Type: '+typ+'\r\n\r\n').encode()+content+b'\r\n')
   body=b''.join(parts)+('--'+boundary+'--\r\n').encode();headers={'Content-Type':'multipart/form-data; boundary='+boundary}
  else:body=urllib.parse.urlencode(data or {}).encode();headers={'Content-Type':'application/x-www-form-urlencoded'}
  return self.request(url,body,headers=headers,**kw)
 def request(self,url,data,allow_redirects=True,headers=None):
  handlers=[urllib.request.ProxyHandler({}),urllib.request.HTTPCookieProcessor(self.cookies)]
  if not allow_redirects:handlers.append(NoRedirect())
  opener=urllib.request.build_opener(*handlers)
  try:r=opener.open(urllib.request.Request(url,data=data,headers=headers or {}),timeout=30)
  except urllib.error.HTTPError as e:r=e
  return Response(r)
class Requests:Session=Session
requests=Requests()

import re,json,datetime,os
import argparse
parser=argparse.ArgumentParser(description="Writes demo data: use a disposable backend with a same-day fixture only")
parser.add_argument('--base-url',required=True);parser.add_argument('--patient',required=True);parser.add_argument('--disposable-data',action='store_true')
args=parser.parse_args()
if not args.disposable_data:parser.error('Use a fresh disposable backend and pass --disposable-data')
B=args.base_url.rstrip('/')+'/';PID=args.patient
checks=0
def check(condition,label):
 global checks
 assert condition,label;checks+=1

def token(text):
 m=re.search(r'name=[\"\']csrfToken[\"\']\s+value=[\"\']([^\"\']+)',text);assert m,'Missing token';return m[1]
def login(username,password):
 s=Session();t=token(s.get(B+'login.jsp').text);r=s.post(B+'login',data={'username':username,'password':password,'csrfToken':t});check(r.status_code==200 and 'dashboard.jsp' in r.url,'login '+username);return s,t
s,t=login('admin','admin123')
for path in ['dashboard.jsp','patient-list.jsp','patient?action=view&id='+PID,'edit-patient?id='+PID,'doctor?action=list','doctor?action=edit&id=D001','doctor?action=view&id=D001','appointment?action=new','appointment?action=list','medical-record-list.jsp','medical-record?action=new','bill-list.jsp','create-bill.jsp','patient-documents.jsp','insurance-claims.jsp','audit-logs.jsp','notifications.jsp','settings.jsp','change-password.jsp','users','users?action=new','users?action=edit&id=1','availability','availability?edit=1']:
 r=s.get(B+path);check(r.status_code==200,(path,r.text[:1200]));check('HTTP Status 500' not in r.text,path+' JSP');print('PAGE',path,r.status_code,flush=True)
check('MySQL' in s.get(B+'settings.jsp').text,'settings modes');check(s.get(B+'assets/app.css').status_code==200,'local CSS')
# Fresh future booking uses the server-provided slots.
tomorrow=(datetime.date.today()+datetime.timedelta(days=1)).isoformat();r=s.get(B+'slots?doctorId=D001&date='+tomorrow);check(r.status_code==200,'slots endpoint');slots=json.loads(r.text);check(len(slots)>1,'published slots');tm=slots[0]
data={'csrfToken':t,'action':'insert','patientId':PID,'doctorId':'D001','appointmentDate':tomorrow,'appointmentTime':tm,'reason':'Follow-up, sample only','status':'Completed'}
r=s.post(B+'appointment',data=data);check('msg=booked' in r.url,('booking',r.status_code,r.text[:500]));r=s.get(B+'appointment?action=list');future=re.findall(r'appointment\?action=edit&id=(\d+)',r.text);fid=future[-1];check('Booked' in r.text,'new visit status is forced to Booked');r=s.post(B+'appointment',data=data);check('Schedule Conflict' in r.text or r.status_code==400,'duplicate rejected')
r=s.post(B+'visit',data={'csrfToken':t,'id':fid,'status':'Checked-in'});check(r.status_code==400,'future checkin blocked')
# Registration and complete patient edit.
r=s.post(B+'add-patient',data={'csrfToken':t,'name':'HTTP Test Patient','age':'29','gender':'Other','phone':'0701234567','email':'http@example.com','blood_group':'A+','address':'12, Sample Lane','allergies':'Sample allergy','medical_history':'Sample history'});check(r.status_code==200,'registration');r=s.get(B+'patient-list.jsp');m=re.search(r'HTTP Test Patient</strong><small>([^<]+)',r.text);newid=m[1];check(bool(newid),'generated patient id')
r=s.post(B+'edit-patient',data={'csrfToken':t,'id':newid,'name':'HTTP Test Patient Updated','age':'30','gender':'Other','contact':'0701234567','email':'edited@example.com','bloodGroup':'O+','address':'45, New Address','allergies':'Updated allergy','medicalHistory':'New history'});check(r.status_code==200,'full edit');r=s.get(B+'patient?action=view&id='+newid);check('edited@example.com' in r.text and 'Updated allergy' in r.text and '45, New Address' in r.text,'all patient fields persist')
# Same-day visit is inserted as a fixture before this suite to permit check-in regardless of the clock.
r=s.get(B+'appointment?action=list');ids=re.findall(r'name="id" value="(\d+)"><input type="hidden" name="status" value="Checked-in"',r.text);check(bool(ids),'fixture booked visit');aid=ids[0]
staff,st=login('staff','staff123');doctor,dt=login('doctor','doc123')
r=doctor.post(B+'visit',data={'csrfToken':dt,'id':aid,'status':'Checked-in'});check(r.status_code==403,'doctor cannot checkin')
r=staff.post(B+'visit',data={'csrfToken':st,'id':aid,'status':'Checked-in'});check(r.status_code==200,'reception checkin')
r=staff.post(B+'visit',data={'csrfToken':st,'id':aid,'status':'In consultation'});check(r.status_code==403,'staff cannot consult')
r=doctor.post(B+'visit',data={'csrfToken':dt,'id':aid,'status':'In consultation'});check(r.status_code==200,'mapped doctor starts consultation')
r=doctor.post(B+'visit',data={'csrfToken':dt,'id':aid,'status':'Completed'});check(r.status_code==400,'completion needs note')
r=doctor.get(B+'medical-record?action=new&appointmentId='+aid);check(r.status_code==200 and PID in r.text,'prefilled clinical form')
med={'csrfToken':dt,'action':'insert','patientId':PID,'doctorId':'D001','appointmentId':aid,'diagnosis':'Sample assessment, follow-up\n<script>alert(1)</script>','prescription':'Demonstration only; no treatment instructions','notes':'Sample notes\nNew line','recordDate':datetime.date.today().isoformat()}
r=doctor.post(B+'medical-record',data=med);check(r.status_code==200 and '&lt;script&gt;' in r.text and '<script>alert(1)</script>' not in r.text,'clinical note saved and escaped');rid=re.search(r'medical-record\?action=edit&id=(\d+)',r.text)[1]
r=doctor.get(B+'medical-record?action=edit&id='+rid);check(r.status_code==200,'edit note page');r=doctor.get(B+'download-prescription?id='+rid);check(r.status_code==200 and 'CLINICAL NOTE' in r.text,'print note')
r=doctor.post(B+'visit',data={'csrfToken':dt,'id':aid,'status':'Completed'});check(r.status_code==200,'complete visit')
r=staff.get(B+'create-bill.jsp?appointmentId='+aid);check(r.status_code==200 and 'data-invoice-amount' in r.text,'invoice preview')
r=staff.post(B+'bill',data={'csrfToken':st,'appointmentId':aid,'amount':'1','patientId':'wrong','paymentStatus':'Paid'});check(r.status_code==200 and '2,500.00' in r.text,'server-derived invoice amount');bid=re.search(r'name="billId" value="(\d+)"',r.text)[1]
r=staff.post(B+'bill',data={'csrfToken':st,'appointmentId':aid});check(r.status_code==400,'duplicate invoice rejected')
r=staff.post(B+'bill',data={'csrfToken':st,'action':'pay','billId':bid,'paymentMethod':'Cash'});check(r.status_code==200,'payment recorded');r=staff.get(B+'download-bill?id='+bid);check(r.status_code==200 and 'Payment received' in r.text,'receipt print')
r=doctor.post(B+'medical-record',data={'csrfToken':dt,'action':'delete','id':rid});check(r.status_code==400,'completed note retained')
r=staff.post(B+'insurance-claim',data={'csrfToken':st,'action':'create','patientId':PID,'providerName':'Demo insurer','policyNumber':'TEST1','claimAmount':'1000'});check(r.status_code==200 and 'Demo insurer' in r.text,'claim saved')
r=staff.post(B+'upload-document',data={'csrfToken':st,'patientId':PID},files={'file':('report.pdf',b'%PDF-1.4\nSample','application/pdf')});check(r.status_code==200 and 'report.pdf' in r.text,'upload');docid=re.search(r'view-document\?id=(\d+)',r.text)[1];r=staff.get(B+'view-document?id='+docid);check(r.status_code==200 and r.content.startswith(b'%PDF'),'download')
for role,client in [('staff',staff),('doctor',doctor)]:
 for path in ['settings.jsp','users','audit-logs.jsp']:
  check(client.get(B+path).status_code==403,role+' forbidden '+path)
check(s.post(B+'visit',data={'id':aid,'status':'Completed'}).status_code==403,'CSRF');check(Session().get(B+'patient-list.jsp',allow_redirects=False).status_code==302,'anon login redirect')
# Add a second mapped clinician and ensure visit ownership applies to direct POSTs.
r=s.post(B+'doctor?action=insert',data={'csrfToken':t,'id':'D999','name':'Second Doctor','specialization':'General','qualification':'MBBS','phone':'0701112222','email':'other@example.com','consultationFee':'3000'});check(r.status_code==200,'new doctor')
r=s.post(B+'users',data={'csrfToken':t,'action':'insert','username':'otherdoc','password':'password123','role':'DOCTOR','email':'other@example.com','doctorId':'D999'});check(r.status_code==200,'mapped clinician account')
other,ot=login('otherdoc','password123');r=other.get(B+'medical-record?action=edit&id='+rid);check(r.status_code==403,'other clinician record blocked');r=other.get(B+'download-prescription?id='+rid);check(r.status_code==403,'other clinician print blocked');check('HTTP Test Patient' not in other.get(B+'appointment?action=list').text,'own queue only')
print('PASS HTTP CHECKS:',checks,flush=True)
