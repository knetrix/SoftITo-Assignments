import math
LIGHT=['#F6C835','#1870C2','#D42F34','#47B777','#9499A0']
DARK=['#F0C543','#5AA3EC','#EF6661','#63BE86','#82868E']
def ring(colors,gap=9,r=300,w=112):
    out=[]
    for i,c in enumerate(colors):
        a0=math.radians(-90+i*72+gap/2); a1=math.radians(-90+(i+1)*72-gap/2)
        x0,y0=512+r*math.cos(a0),512+r*math.sin(a0); x1,y1=512+r*math.cos(a1),512+r*math.sin(a1)
        out.append(f'<path d="M{x0:.2f} {y0:.2f}A{r} {r} 0 0 1 {x1:.2f} {y1:.2f}" fill="none" stroke="{c}" stroke-width="{w}"/>')
    return '\n    '.join(out)
def capsule(fill,mid):
    # Zaman kapsülü: dikey hap; anahtar deliği maskeyle oyulur (saydam kalır).
    return (f'<mask id="kh{mid}" maskUnits="userSpaceOnUse" x="0" y="0" width="1024" height="1024">'
            f'<rect width="1024" height="1024" fill="#fff"/>'
            f'<circle cx="512" cy="486" r="26" fill="#000"/><path d="M502 500h20l8 62h-36z" fill="#000"/></mask>'
            f'<rect x="437" y="382" width="150" height="260" rx="75" fill="{fill}" mask="url(#kh{mid})"/>')
def doc(size,body,bg=None):
    b=f'<rect width="{size}" height="{size}" fill="{bg}"/>\n  ' if bg else ''
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="0 0 {size} {size}">\n  <!-- Digura: beş duygu rengi halkası + kilitli zaman kapsülü -->\n  {b}{body}\n</svg>\n'
def mark(c,colors,cap,scale,mid):
    return f'<g transform="translate({c} {c}) scale({scale}) translate(-512 -512)">\n    {ring(colors)}\n    {capsule(cap,mid)}\n  </g>'
files={
 'app_icon':(1024,mark(512,LIGHT,'#202124',1,'a'),'#F8FAFD'),
 'app_icon_foreground':(1024,mark(512,LIGHT,'#202124',0.78,'b'),None),
 'app_icon_monochrome':(1024,mark(512,['#FFFFFF']*5,'#FFFFFF',0.78,'c'),None),
 'splash_logo':(1152,mark(576,LIGHT,'#202124',0.96,'d'),None),
 'splash_logo_dark':(1152,mark(576,DARK,'#E9EBEE',0.96,'e'),None),
}
for n,(s,body,bg) in files.items(): open(f'assets/icon/source/{n}.svg','w').write(doc(s,body,bg))
