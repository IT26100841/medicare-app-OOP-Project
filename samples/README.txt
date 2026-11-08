To generate a rich demo with current-day records, start Tomcat with a fresh directory:
-Dmedicare.data.dir=C:/medicare-demo-v2
-Dmedicare.storage=FILE
-Dmedicare.demo=true

See docs/DEMO_WALKTHROUGH.md. Source fixtures and examples are in DemoWorkspace.java.
No existing FILE directory or database is overwritten by this opt-in seed.

The data/ directory also contains versioned .txt sample files generated with the
optional demo on 28 October 2026, for assignment evidence. These examples do not
replace your existing records. Prefer the fresh-directory option for a new day.
