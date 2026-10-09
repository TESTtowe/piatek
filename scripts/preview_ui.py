#!/usr/bin/env python3
"""Project actual GUI snapshots onto HTML for layout review; not Roblox rendering.

Optional developer tool: requires Playwright Chromium and build/visual/Oswald.ttf.
The font is only used locally; no font binary is distributed with the game.
"""
from pathlib import Path
import base64
import json
import shutil
from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parents[1]
VISUAL = ROOT / 'build/visual'
HTML = r'''<!doctype html><html lang="pl"><meta charset="utf-8"><style>
@font-face{font-family:Oswald;src:url(data:font/ttf;base64,FONT_DATA)}
*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden;background:#262a31}
.node{position:absolute;min-height:0;flex-shrink:0} .text{display:flex;flex-direction:column;overflow:hidden}
.copy{white-space:pre-wrap;overflow-wrap:normal;font-family:Arial,sans-serif}
.scroll{overflow-y:auto;overflow-x:hidden;scrollbar-width:thin;scrollbar-color:#979ba3 transparent}
.list{display:flex;flex-direction:column}.list>.node{position:relative;left:auto!important;top:auto!important;transform:none!important}
#note{position:fixed;bottom:4px;right:6px;z-index:999;color:#7d838d;font:8px Arial}
</style><div id="root"></div><div id="note">PODGLĄD UKŁADU GUI · BEZ RENDERA ROBLOX</div><script>
const snapshot=SCENE_DATA;
function size(d){return `calc(${(d?.Scale||0)*100}% + ${d?.Offset||0}px)`}
function rgba(c,a=1){return `rgba(${c?.r||0},${c?.g||0},${c?.b||0},${a})`}
function render(n,parent){
 const p=n.props,klass=p.ClassName,children=Array.isArray(n.children)?n.children:[];
 if(klass.startsWith('UI')||p.Visible===false)return;
 const e=document.createElement('div');e.className='node';e.dataset.name=p.Name;e.dataset.kind=klass;
 const st=e.style;st.zIndex=p.ZIndex||1;
 if(klass==='ScreenGui'){st.width='100%';st.height='100%'}else{
 st.width=size(p.Size?.X);st.height=p.AutomaticSize==='Y'?'auto':size(p.Size?.Y);
 st.left=size(p.Position?.X);st.top=size(p.Position?.Y);
 if(p.AnchorPoint)st.transform=`translate(${-p.AnchorPoint.X*100}%,${-p.AnchorPoint.Y*100}%)`;
 }
 const gradient=children.find(x=>x.props.ClassName==='UIGradient');
 if(p.BackgroundColor3){st.background=rgba(p.BackgroundColor3,1-(p.BackgroundTransparency||0));
 if(gradient?.props.Transparency)st.background=`linear-gradient(90deg,${gradient.props.Transparency.map(k=>`${rgba(p.BackgroundColor3,1-k.Value)} ${k.Time*100}%`).join(',')})`;}
 const corner=children.find(x=>x.props.ClassName==='UICorner');if(corner)st.borderRadius=size(corner.props.CornerRadius);
 const stroke=children.find(x=>x.props.ClassName==='UIStroke');if(stroke)st.outline=`${stroke.props.Thickness}px solid ${rgba(stroke.props.Color,1-stroke.props.Transparency)}`;
 const pad=children.find(x=>x.props.ClassName==='UIPadding')?.props;
 if(pad)for(const side of ['Left','Right','Top','Bottom'])st['padding'+side]=size(pad['Padding'+side]);
 const list=children.find(x=>x.props.ClassName==='UIListLayout');if(list){e.classList.add('list');st.gap=size(list.props.Padding);}
 if(klass==='ScrollingFrame')e.classList.add('scroll');
 if(klass==='TextLabel'||klass==='TextButton'){
 e.classList.add('text');st.justifyContent=p.TextYAlignment==='Top'?'flex-start':p.TextYAlignment==='Bottom'?'flex-end':'center';
 const t=document.createElement('span');t.className='copy';t.textContent=p.Text;t.style.fontSize=(p.TextSize||14)+'px';t.style.color=rgba(p.TextColor3||{r:235,g:234,b:228});
 t.style.textAlign=(p.TextXAlignment||'Center').toLowerCase();t.style.lineHeight=p.LineHeight||1.18;
 if(p.Font==='Oswald')t.style.fontFamily='Oswald';else if(p.Font==='Code')t.style.fontFamily='monospace';
 else if(p.Font==='GothamBold')t.style.fontWeight='700';else if(p.Font==='GothamMedium')t.style.fontWeight='500';
 e.appendChild(t);
 }
 parent.appendChild(e);
 const ordered=list?children.toSorted((a,b)=>(a.props.LayoutOrder||0)-(b.props.LayoutOrder||0)):children;
 ordered.forEach(child=>render(child,e));
}
render(snapshot.tree,document.getElementById('root'));
</script>'''


def main():
    font = VISUAL / 'Oswald.ttf'
    if not font.exists():
        raise SystemExit('Place a licensed Oswald TTF in build/visual/Oswald.ttf for local previews.')
    encoded = base64.b64encode(font.read_bytes()).decode()
    out = ROOT / 'docs/previews'
    out.mkdir(exist_ok=True)
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True, executable_path=shutil.which('chromium'), channel='chromium', args=['--no-sandbox'])
        for source in sorted(VISUAL.glob('*.json')):
            scene = json.loads(source.read_text())
            page = browser.new_page(viewport={'width':scene['width'],'height':scene['height']},device_scale_factor=1)
            errors=[]
            page.on('pageerror',lambda err: errors.append(str(err)))
            page.set_content(HTML.replace('FONT_DATA',encoded).replace('SCENE_DATA',json.dumps(scene)))
            page.evaluate('document.fonts.ready')
            if errors:
                raise RuntimeError(errors)
            # Visible text controls must stay within their horizontal viewport.
            bounds = page.locator('[data-kind="TextButton"]').evaluate_all('es=>es.map(e=>({name:e.dataset.name,x:e.getBoundingClientRect().x,right:e.getBoundingClientRect().right}))')
            assert all(b['x']>=-1 and b['right']<=scene['width']+1 for b in bounds),bounds
            page.screenshot(path=str(out/(scene['screen']+'.png')))
            print('Reviewed layout snapshot:',scene['screen'])
            page.close()
        browser.close()


if __name__=='__main__':
    main()
