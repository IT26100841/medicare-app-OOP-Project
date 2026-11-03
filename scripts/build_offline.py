"""Compile current source and run regression tests without Maven/network access."""
import argparse,os,pathlib,shutil,subprocess,sys,tempfile,zipfile
root=pathlib.Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--tomcat',required=True,help='Tomcat 9 directory');p.add_argument('--test',action='store_true');args=p.parse_args()
servlet=pathlib.Path(args.tomcat).expanduser().resolve()/'lib/servlet-api.jar'
if not servlet.is_file():p.error('Tomcat 9 lib/servlet-api.jar was not found')
java=shutil.which('java');javac=shutil.which('javac')
if not java:p.error('Install a JDK and put its bin directory on PATH')
compiler=[javac] if javac else [java,'com.sun.tools.javac.Main']
target=root/'target';classes=target/'offline-classes';tests=target/'offline-test-classes'
if classes.exists():shutil.rmtree(classes)
classes.mkdir(parents=True,exist_ok=True)
sources=sorted((root/'src/main/java').rglob('*.java'))
subprocess.run(compiler+['--release','11','-encoding','UTF-8','-cp',str(servlet),'-d',str(classes)]+[str(s) for s in sources],check=True)
if args.test:
 tests.mkdir(parents=True,exist_ok=True)
 cp=os.pathsep.join([str(classes),str(servlet)]+[str(j) for j in sorted((root/'tools/test-libs').glob('*.jar'))])
 subprocess.run(compiler+['--release','11','-encoding','UTF-8','-cp',cp,'-d',str(tests)]+[str(s) for s in sorted((root/'src/test/java').rglob('*.java'))],check=True)
 subprocess.run([java,'-cp',str(tests)+os.pathsep+cp,'org.junit.runner.JUnitCore','com.medicare.RegressionTest','com.medicare.WorkflowTest','com.medicare.PatientPortalTest','com.medicare.BillingChargesTest','com.medicare.ReviewFixTest'],check=True)
prebuilt=root/'dist/medicare-app.war'
if not prebuilt.is_file():p.error('Bundled dist/medicare-app.war is needed for offline runtime dependencies; alternatively use Maven')
output=target/'medicare-app.war'
with zipfile.ZipFile(prebuilt) as old,zipfile.ZipFile(output,'w',zipfile.ZIP_DEFLATED) as war:
 for entry in old.infolist():
  if entry.filename.startswith('WEB-INF/lib/') and entry.filename.endswith('.jar'):war.writestr(entry,old.read(entry.filename))
 for path in sorted((root/'src/main/webapp').rglob('*')):
  if path.is_file():war.write(path,path.relative_to(root/'src/main/webapp').as_posix())
 for path in sorted(classes.rglob('*.class')):war.write(path,'WEB-INF/classes/'+path.relative_to(classes).as_posix())
 resources=root/'src/main/resources'
 if resources.exists():
  for path in resources.rglob('*'):
   if path.is_file():war.write(path,'WEB-INF/classes/'+path.relative_to(resources).as_posix())
print('Built',output)
