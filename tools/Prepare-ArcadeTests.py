from pathlib import Path
root=Path(__file__).resolve().parents[1]
xml=(root/'Project.xml').read_text(encoding='utf-8')
assert 'file="fresno" main="Main"' in xml
xml=xml.replace('file="fresno" main="Main"','file="FresnoArcadeRegression" main="FresnoArcadeTestMain"',1)
assert '<source path="source" />' in xml
xml=xml.replace('<source path="source" />','<source path="source" /><classpath name="tests/native" />',1)
xml=xml.replace('value="export/${destination}"','value="export/arcade-tests"')
(root/'ArcadeTest.xml').write_text(xml,encoding='utf-8')
