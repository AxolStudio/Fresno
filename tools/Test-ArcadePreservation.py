"""Compare Non-desktop source projections; never compile or submit an Android app."""
from pathlib import Path
import subprocess,re
import xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
BASE='6e7b92d'
def git(*args):return subprocess.check_output(['git',*args],cwd=ROOT,text=True,encoding="utf-8")
def condition(expr,symbols):
    expr=re.sub(r'(?<=\w)\s+(?=\w)', ' && ', expr)
    expr=re.sub(r'\b[a-zA-Z_]\w*(?:\.\w+)*\b',lambda m:str(m[0] in symbols),expr.strip())
    expr=expr.replace('&&',' and ').replace('||',' or ')
    expr=re.sub(r'!(?!=)',' not ',expr)
    return bool(eval(expr,{'__builtins__':{}},{}))
def project(text,symbols):
    stack=[];active=True;out=[]
    for line in text.splitlines():
        m=re.match(r'\s*#(if|elseif|else|end)\b(.*)',line)
        if not m:
            if active:out.append(line)
            continue
        op,expr=m.groups()
        if op=='if':
            yes=condition(expr,symbols);stack.append([active,yes]);active=active and yes
        elif op=='elseif':
            parent,seen=stack[-1];yes=condition(expr,symbols);active=parent and not seen and yes;stack[-1][1]=seen or yes
        elif op=='else':
            parent,seen=stack[-1];active=parent and not seen;stack[-1][1]=True
        else:active=stack.pop()[0]
    assert not stack
    return '\n'.join(x.strip() for x in out if x.strip())
def xml_projection(text,symbols):
    root=ET.fromstring(text.replace('config:android','config_android').replace('android:','android_'))
    def keep(node):
        if 'if' in node.attrib and not condition(node.attrib['if'],symbols):return None
        if 'unless' in node.attrib and condition(node.attrib['unless'],symbols):return None
        attrs=tuple(sorted((k,v) for k,v in node.attrib.items() if k not in ('if','unless')))
        children=tuple(x for c in node if (x:=keep(c)) is not None)
        return node.tag,attrs,(node.text or '').strip(),children
    return keep(root)
count=0
for path in git('diff','--name-only',BASE).splitlines():
    if path=='Project.xml':
        before=git('show',BASE+':'+path)
        now=(ROOT/path).read_text(encoding='utf-8-sig')
        for symbols in [{'android','mobile'},{'android','mobile','debug'},{'html5'},{'html5','ng'},{'html5','gj'}]:
            assert xml_projection(before,symbols)==xml_projection(now,symbols),'Android Project.xml changed'
    elif path.startswith(('source/','core/')):
        now=(ROOT/path).read_text(encoding='utf-8-sig')
        exists=bool(git('ls-tree',BASE,'--',path).strip())
        before=git('show',BASE+':'+path) if exists else ''
        for extra in [set(),{'debug'},{'FLX_TOUCH'},{'debug','FLX_TOUCH'},{'release'},{'release','FLX_TOUCH'}]:
            symbols={'android','mobile','cpp','sys','target.threaded'}|extra
            if exists:assert project(now,symbols)==project(before,symbols),'Android source changed: '+path
            else:
                p=re.sub(r'/\*.*?\*/|//[^\n]*','',project(now,symbols),flags=re.S)
                assert not p.strip(),'New source active on Android: '+path
        for extra in [set(),{'debug'},{'ng'},{'gj'}]:
            symbols={'html5','js'}|extra
            if exists:assert project(now,symbols)==project(before,symbols),'HTML5 source changed: '+path
            else:
                text=re.sub(r'/\*.*?\*/|//[^\n]*','',project(now,symbols),flags=re.S)
                assert not text.strip(),'New source active on HTML5: '+path
        count+=1
    elif path=='.gitignore':pass
    elif path.startswith(('.github/','tests/','tools/','docs/','ci/')):pass
    else:raise AssertionError('Protected file changed: '+path)
for path in ['assets','raw']:
    assert not git('diff',BASE,'--',path).strip(),'Protected Android subtree changed: '+path
print('PASS Non-desktop source projections for',count,'changed modules; Android/HTML5 config and assets/raw untouched')
