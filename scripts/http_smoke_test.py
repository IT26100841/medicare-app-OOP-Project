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

import argparse,re,getpass
parser=argparse.ArgumentParser(description='Verify an admin deployment without changing patient records')
parser.add_argument('--base-url',required=True);parser.add_argument('--username',default='admin');args=parser.parse_args()
base=args.base_url.rstrip('/')+'/';session=Session();html=session.get(base+'login.jsp').text
match=re.search(r'name=["\']csrfToken["\']\s+value=["\']([^"\']+)',html)
if not match:raise SystemExit('Login page or form token is missing')
response=session.post(base+'login',data={'csrfToken':match[1],'username':args.username,'password':getpass.getpass('Clinic password: ')})
if response.status_code!=200 or 'dashboard.jsp' not in response.url:raise SystemExit('Login failed')
for path in ['dashboard.jsp','patient-list.jsp','doctor?action=list','appointment?action=list','medical-record-list.jsp','bill-list.jsp','availability','patient-documents.jsp','insurance-claims.jsp','settings.jsp','users','assets/app.css','assets/app.js']:
 result=session.get(base+path)
 if result.status_code!=200:raise SystemExit(path+': HTTP '+str(result.status_code))
 print('OK',path)
print('Deployment smoke check passed. No patient/clinical/billing records were changed.')
