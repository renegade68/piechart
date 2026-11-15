<!doctype html><html lang="en"><meta charset="utf-8">
<!-- Author: choonjoo lee. Copyright (c) 2026 choonjoo lee.
Licensed under the Academic Free License version 3.0. SPDX-License-Identifier: AFL-3.0.
See LICENSE and LICENSE_CODE.txt. -->
<title>radialchart measured export</title>
<style>body{font:14px Arial,sans-serif;margin:20px;color:#17212b}#canvas{overflow:auto;border:1px solid #ddd}button{padding:8px 14px;margin:8px 8px 12px 0}#status{white-space:pre-wrap}svg{display:block;background:white}.note{max-width:900px}fieldset{max-width:1000px;border:1px solid #ccd3da;padding:12px}label{display:inline-block;margin:6px 14px 6px 0}input{padding:6px}input[type=number]{width:80px}</style>
<h1>Measured radialchart export</h1>
<p class="note">All captions are placed outside without shortening or dropping categories. Font bounds are measured in this browser. The canvas expands to fit. Review the verification report before downloading. Recheck after changing fonts or rendering in another application.</p>
<fieldset><legend>Label layout</legend>
<label>Font family <input id="font" type="text" size="24"></label>
<label>Font size (px) <input id="size" type="number" min="6" max="72" step="any"></label>
<label>Label gap (px) <input id="gap" type="number" min="2" max="100" step="any"></label>
<label>Wrap width (px; 0 = off) <input id="wrap" type="number" min="0" max="4000" step="any"></label>
<button id="apply">Apply and verify</button><button id="reset">Restore exported settings</button>
</fieldset>
<button id="savehtml" disabled>Save adjusted HTML</button><button id="download" disabled>Download verified SVG</button><button id="retry">Measure again</button><button id="report" disabled>Download report</button>
<div id="canvas"></div><details><summary id="verdict">Waiting for verification…</summary><pre id="status">Waiting for font measurement…</pre></details>
<script id="chartdata" type="application/json">
__RADIALCHART_DATA__
</script>
<script>
'use strict';
const data=JSON.parse(document.getElementById('chartdata').textContent);
const NS='http://www.w3.org/2000/svg';
const palette=['#4477AA','#228833','#EE6677','#CCBB44','#66CCEE','#AA3377','#BBBBBB','#332288'];
let current,revision=0;
const initialSettings={font:data.font,fontsize:data.fontsize,gap:data.gap,wrapwidth:data.wrapwidth||0};
function el(tag,attrs,parent){const n=document.createElementNS(NS,tag);Object.entries(attrs||{}).forEach(function(e){n.setAttribute(e[0],e[1]);});if(parent)parent.appendChild(n);return n;}
function text(s,parent){let n=el('text',{'font-family':data.font,'font-size':data.fontsize,fill:'#17212b'},parent);n.textContent=s;return n;}
function wrapText(n,label,width){
 n.setAttribute('xml:space','preserve');
 n.style.whiteSpace='pre';
 if(!width)return 1;
 const graphemes=typeof Intl.Segmenter==='function'?[...new Intl.Segmenter(undefined,{granularity:'grapheme'}).segment(label)].map(function(s){return s.segment;}):Array.from(label);
 const lines=[];let line='';
 for(const ch of graphemes){
  const trial=line+ch;n.textContent=trial;
  if(n.getBBox().width<=width){line=trial;continue;}
  if(!line)throw Object.assign(Error('One glyph exceeds wrapwidth; increase wrapwidth or reduce fontsize.'),{code:'WRAP_TOO_NARROW'});
  let split=-1;for(let i=0;i<line.length;i++)if(/\s/.test(line[i]))split=i+1;
  if(split>0){lines.push(line.slice(0,split));line=line.slice(split)+ch;}
  else {lines.push(line);line=ch;}
  n.textContent=line;
  if(n.getBBox().width>width){
   const remainder=line.slice(0,line.length-ch.length);
   if(remainder)lines.push(remainder);
   line=ch;
   n.textContent=ch;
   if(n.getBBox().width>width)throw Object.assign(Error('One glyph exceeds wrapwidth; increase wrapwidth or reduce fontsize.'),{code:'WRAP_TOO_NARROW'});
  }
 }
 if(line||!lines.length)lines.push(line);
 let top=0,bottom=0;lines.forEach(function(s){n.textContent=s;const b=n.getBBox();top=Math.min(top,b.y);bottom=Math.max(bottom,b.y+b.height);});
 const lineHeight=Math.max(data.fontsize*1.25,bottom-top+2);
 n.replaceChildren();
 lines.forEach(function(s,i){const t=el('tspan',{x:0,dy:i?lineHeight:0},n);t.textContent=s;});
 return lines.length;
}
function placeText(n,x,y){n.setAttribute('x',x);n.setAttribute('y',y);n.querySelectorAll('tspan').forEach(function(t){t.setAttribute('x',x);});}
function bounds(n){const b=n.getBBox();return {x:b.x,y:b.y,w:b.width,h:b.height};}
function intersect(a,b,gap){return a.x<b.x+b.w+gap && b.x<a.x+a.w+gap && a.y<b.y+b.h+gap && b.y<a.y+a.h+gap;}
function cross(a,b,c){return (b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0]);}
function properCross(a,b,c,d){return cross(a,b,c)*cross(a,b,d)<-1e-8 && cross(c,d,a)*cross(c,d,b)<-1e-8;}
function pointDistance(p,a,b){const dx=b[0]-a[0],dy=b[1]-a[1],den=dx*dx+dy*dy;const t=den?Math.max(0,Math.min(1,((p[0]-a[0])*dx+(p[1]-a[1])*dy)/den)):0;return Math.hypot(p[0]-a[0]-t*dx,p[1]-a[1]-t*dy);}
function segmentDistance(a,b,c,d){if(properCross(a,b,c,d))return 0;return Math.min(pointDistance(a,c,d),pointDistance(b,c,d),pointDistance(c,a,b),pointDistance(d,a,b));}
function segmentRectHit(a,b,r){const inside=function(p){return p[0]>=r.x-.5&&p[0]<=r.x+r.w+.5&&p[1]>=r.y-.5&&p[1]<=r.y+r.h+.5;};if(inside(a)||inside(b))return true;const c=[[r.x,r.y],[r.x+r.w,r.y],[r.x+r.w,r.y+r.h],[r.x,r.y+r.h]];for(let i=0;i<4;i++)if(segmentDistance(a,b,c[i],c[(i+1)%4])<.5)return true;return false;}
const colorNames={navy:'#1a476f',teal:'#6e8e84',cranberry:'#c10534',orange:'#ff7f00',forest_green:'#55752f',lavender:'#938dd2',gold:'#ffd200',sand:'#d9c66b',black:'#000000',white:'#ffffff',red:'#ff0000',blue:'#0000ff',green:'#008000'};
function resolveColor(d){if(colorNames[d.color])return colorNames[d.color];if(/^gs([0-9]|1[0-6])$/.test(d.color)){let v=Math.round(255*Number(d.color.slice(2))/16);return 'rgb('+v+','+v+','+v+')';}return palette[d.id%palette.length];}
async function fit(multiplier,history,run){
 if(run===undefined){invalidate();run=revision;}
 if(!Array.isArray(history))history=[];
 if(typeof multiplier!=='number')multiplier=1;
 const status=document.getElementById('status'),button=document.getElementById('download');button.disabled=true;document.getElementById('report').disabled=true;
 try {
 document.getElementById('canvas').replaceChildren();
 const svg=el('svg',{xmlns:NS,width:800,height:600,viewBox:'0 0 800 600'},document.getElementById('canvas'));
 const rows=data.rows.map(function(d,i){return Object.assign({},d,{id:i,node:text(d.label,svg),side:Math.sin(d.mid)>=0?1:-1});});
 const heading=text(data.title||'Category composition',svg),center=text(data.center||'',svg);
 await document.fonts.ready;
 if(run!==revision)return;
 rows.forEach(function(d){d.lines=wrapText(d.node,d.label,data.wrapwidth||0);d.box=bounds(d.node);});
 const hb=bounds(heading),cb=bounds(center),pad=24,gap=data.gap;
 let R=160*multiplier;
 if(data.hole>0 && data.center)R=Math.max(R,(Math.hypot(cb.w/2,cb.h/2)+gap)/data.hole);
 const left=rows.filter(function(d){return d.side<0;}),right=rows.filter(function(d){return d.side>0;});
 const maxw=function(a){return Math.max(0,...a.map(function(d){return d.box.w;}));};
 const need=function(a){return a.reduce(function(v,d){return v+d.box.h+gap;},0);};
 const spreadSpan=function(group){const copy=group.slice().sort(function(a,b){return -Math.cos(a.mid)+Math.cos(b.mid)||a.id-b.id;});let prev=-Infinity,lo=0,hi=0;copy.forEach(function(d,i){let y=Math.max(-R*Math.cos(d.mid),prev+d.box.h/2);if(!i)lo=y-d.box.h/2;hi=y+d.box.h/2;prev=hi+gap;});return hi-lo;};
 let bodyH=Math.max(2*R+2*gap,need(left),need(right),spreadSpan(left)+2*gap,spreadSpan(right)+2*gap);
 const cy=pad+hb.h+gap+bodyH/2;
 const leftW=maxw(left),rightW=maxw(right),corridor=Math.max(100,R*.5);
 let W=2*pad+leftW+rightW+2*R+2*corridor;
 const extra=Math.max(0,hb.w+2*pad-W);W+=extra;
 const cx=pad+leftW+corridor+R+extra/2;
 const H=cy+bodyH/2+pad+data.fontsize*2;
 if(W>16000||H>16000)throw Object.assign(Error('Required canvas exceeds 16000 pixels; no labels were removed.'),{code:'CANVAS_LIMIT',details:{width:Math.ceil(W),height:Math.ceil(H),scaleMultiplier:multiplier}});
 svg.setAttribute('width',Math.ceil(W));svg.setAttribute('height',Math.ceil(H));svg.setAttribute('viewBox','0 0 '+Math.ceil(W)+' '+Math.ceil(H));
 const shapes=el('g',{},svg);svg.insertBefore(shapes,svg.firstChild);
 const point=function(a,r){return [cx+r*Math.sin(a),cy-r*Math.cos(a)];};
 rows.forEach(function(d){
  if(d.share<=0)return;
  const steps=Math.max(8,Math.ceil(d.width*R/2)),p=[];
  for(let i=0;i<=steps;i++)p.push(point(d.mid-d.width/2+d.width*i/steps,R));
  if(data.hole>0){for(let i=steps;i>=0;i--)p.push(point(d.mid-d.width/2+d.width*i/steps,R*data.hole));}else p.push([cx,cy]);
  el('path',{d:'M'+p.map(function(v){return v.join(',');}).join(' L')+' Z',fill:resolveColor(d),'fill-opacity':.85,stroke:'white','stroke-width':.7},shapes);
 });
 const paths=[];
 [left,right].forEach(function(group){
  group.sort(function(a,b){return -Math.cos(a.mid)+Math.cos(b.mid)||a.id-b.id;});
  let previous=-Infinity;
  group.forEach(function(d){d.anchor=point(d.mid,R);d.y=Math.max(d.anchor[1],previous+d.box.h/2);previous=d.y+d.box.h/2+gap;});
  if(!group.length)return;
  const lo=group[0].y-group[0].box.h/2,hi=group[group.length-1].y+group[group.length-1].box.h/2;
  const shift=Math.max(0,hi-(cy+bodyH/2))+Math.min(0,lo-(cy-bodyH/2));
  group.forEach(function(d){
   d.y-=shift;
   const x=d.side<0?cx-R-corridor-d.box.w:cx+R+corridor;
   placeText(d.node,x-d.box.x,d.y-d.box.h/2-d.box.y);
   if(d.share<=0)return; // Zero has no wedge: retain caption but no misleading anchor.
   const pts=[d.anchor,[cx+d.side*(R+corridor*.25),d.anchor[1]],[cx+d.side*(R+corridor*.75),d.y],[cx+d.side*(R+corridor-gap),d.y]];
   el('polyline',{points:pts.map(function(p){return p.join(',');}).join(' '),fill:'none',stroke:'#66717d','stroke-width':1},shapes);
   paths.push({id:d.id,points:pts});
  });
 });
 heading.setAttribute('x',(W-hb.w)/2-hb.x);heading.setAttribute('y',pad-hb.y);
 center.setAttribute('x',cx-cb.w/2-cb.x);center.setAttribute('y',cy-cb.h/2-cb.y);
 const note=text('Measured browser export • '+rows.length+' categories • zero-value captions have no connector',svg);
 const nb=bounds(note);note.setAttribute('x',pad);note.setAttribute('y',H-pad-nb.y-nb.h);
 // Expand for the footnote rather than allowing it to clip.
 if(nb.w+2*pad>W){W=nb.w+2*pad;svg.setAttribute('width',Math.ceil(W));svg.setAttribute('viewBox','0 0 '+Math.ceil(W)+' '+Math.ceil(H));}
 if(W>16000)throw Object.assign(Error('Footnote exceeds the canvas limit.'),{code:'CANVAS_LIMIT',details:{width:Math.ceil(W),height:Math.ceil(H)}});
 const boxes=rows.map(function(d){return {id:d.id,...bounds(d.node)};});
 const all=boxes.concat([bounds(heading),bounds(note)]);
 if(data.center)all.push(bounds(center));
 // Verify the final rendered captions, not only the layout inputs.
 let captionChanges=0,wrapOverflows=0,lineOverlaps=0;
 rows.forEach(function(d){
  if(d.node.textContent!==d.label)captionChanges++;
  if(data.wrapwidth>0 && bounds(d.node).w>data.wrapwidth+.01)wrapOverflows++;
  const lines=[...d.node.querySelectorAll('tspan')].map(bounds);
  for(let i=0;i<lines.length;i++)for(let j=i+1;j<lines.length;j++)
   if(intersect(lines[i],lines[j],0))lineOverlaps++;
 });
 const contactPairs=[];
 let overlaps=0,clipped=0,crossings=0,lineText=0,strokeContacts=0,pieIntersections=0;
 for(let i=0;i<all.length;i++){
  let b=all[i];if(b.x<0||b.y<0||b.x+b.w>W+.01||b.y+b.h>H+.01)clipped++;
  for(let j=i+1;j<all.length;j++)if(intersect(b,all[j],1))overlaps++;
 }
 for(let i=0;i<paths.length;i++)for(let j=i+1;j<paths.length;j++)for(let a=0;a<3;a++)for(let b=0;b<3;b++)if(properCross(paths[i].points[a],paths[i].points[a+1],paths[j].points[b],paths[j].points[b+1]))crossings++;
 paths.forEach(function(path){all.forEach(function(b){for(let a=0;a<3;a++)if(segmentRectHit(path.points[a],path.points[a+1],b))lineText++;});});
 for(let i=0;i<paths.length;i++)for(let j=i+1;j<paths.length;j++){
 let close=false;for(let a=0;a<3;a++)for(let b=0;b<3;b++)if(segmentDistance(paths[i].points[a],paths[i].points[a+1],paths[j].points[b],paths[j].points[b+1])<1.5)close=true;
 if(close){strokeContacts++;if(contactPairs.length<10)contactPairs.push([paths[i].id+1,paths[j].id+1]);}
 }
 history.push({scaleMultiplier:multiplier,width:Math.ceil(W),height:Math.ceil(H),connectorStrokeContacts:strokeContacts,contactPairs:contactPairs});
 if(strokeContacts>0 && multiplier<64)return fit(multiplier*1.5,history,run);
 paths.forEach(function(path){for(let a=0;a<3;a++)if(pointDistance([cx,cy],path.points[a],path.points[a+1])<R-.001)pieIntersections++;});
 const report={status:overlaps+clipped+crossings+lineText+strokeContacts+pieIntersections+captionChanges+wrapOverflows+lineOverlaps===0?'PASS':'FAIL',labels:rows.length,overlaps:overlaps,clipped:clipped,connectorCrossings:crossings,connectorTextIntersections:lineText,connectorStrokeContacts:strokeContacts,connectorPieIntersections:pieIntersections,scaleMultiplier:multiplier,width:Math.ceil(W),height:Math.ceil(H),font:data.font,fontSize:data.fontsize};
 report.version='0.15.1';
 report.captionChanges=captionChanges;
 report.wrapOverflows=wrapOverflows;
 report.lineOverlaps=lineOverlaps;
 report.gap=data.gap;
 report.wrapWidth=data.wrapwidth||0;
 report.lineCounts=rows.map(function(d){return d.lines;});
 report.graphemeSegmentation=typeof Intl.Segmenter==='function';
 report.attempts=history;
 report.zeroLabels=rows.filter(function(d){return d.share===0;}).map(function(d){return d.id+1;});
 report.subpixelSlices=rows.filter(function(d){return d.share>0 && d.width*R<1;}).map(function(d){return d.id+1;});
 report.colorFallbacks=rows.filter(function(d){return !colorNames[d.color]&&!/^gs([0-9]|1[0-6])$/.test(d.color);}).map(function(d){return d.id+1;});
 report.labelBoxes=boxes;
 report.suggestions=report.status==='PASS'?[]:['Try a smaller font or shorter captions.','For nearly coincident tiny wedges, use native labels(legend) instead of connectors.'];
 if(captionChanges||wrapOverflows||lineOverlaps)report.suggestions.unshift('Caption verification failed: rerun measurement and retain the diagnostic report; do not use this SVG.');
 report.scope='Current browser, current fonts and SVG coordinates; glyph outlines are not embedded.';
 svg.dataset.verification=JSON.stringify(report);
 window.radialchartReport=report;
 status.textContent=JSON.stringify(report,null,2)+'\nScope: measured text boxes, canvas clipping, connector/text and connector/pie intersections and 1.5-pixel connector separation in this browser. Different viewers/fonts require rechecking; zero-value captions have no connector. Browser palette supports common Stata names and gs0..gs16; other styles use fallback colors.';
 document.getElementById('verdict').textContent=report.status+' — verification details';
 document.body.dataset.status=report.status;
 current=svg;button.disabled=report.status!=='PASS';document.getElementById('savehtml').disabled=report.status!=='PASS';document.getElementById('report').disabled=false;
 }catch(e){const report={version:'0.15.1',status:'FAIL',code:e.code||'RENDER_ERROR',error:e.message,details:e.details||{},attempts:history,suggestions:e.code==='WRAP_TOO_NARROW'?['Increase wrapwidth() or reduce fontsize(); a single glyph cannot fit.']:['Keep all categories and use native labels(legend) when tiny anchors cannot be separated.','For long captions, shorten them explicitly or reduce fontsize(); rerun measurement.'],labels:data.rows.length};status.textContent=JSON.stringify(report,null,2);document.body.dataset.status='FAIL';document.getElementById('verdict').textContent='FAIL — verification details';window.radialchartReport=report;document.getElementById('report').disabled=false;}
}
function invalidate(){
 revision++;current=null;window.radialchartReport=null;
 document.body.dataset.status='PENDING';document.getElementById('verdict').textContent='PENDING — apply and verify';
 document.getElementById('download').disabled=true;document.getElementById('savehtml').disabled=true;
 document.getElementById('report').disabled=true;
 document.getElementById('status').textContent='Settings changed. Apply and verify before downloading.';
}
function fillControls(){
 for(const [id,key] of [['font','font'],['size','fontsize'],['gap','gap'],['wrap','wrapwidth']])document.getElementById(id).value=data[key]||0;
}
function applySettings(){
 invalidate();
 const font=document.getElementById('font').value.trim();
 const fields=[['size',6,72],['gap',2,100],['wrap',0,4000]];
 const values=fields.map(function(f){const raw=document.getElementById(f[0]).value;return raw.trim()===''?NaN:Number(raw);});
 if(!font||fields.some(function(f,i){return !Number.isFinite(values[i])||values[i]<f[1]||values[i]>f[2];})){
  const report={version:'0.15.1',status:'FAIL',code:'INVALID_SETTINGS',error:'Use a font family, size 6–72, gap 2–100, and wrap width 0–4000.'};
  window.radialchartReport=report;document.body.dataset.status='FAIL';document.getElementById('verdict').textContent='FAIL — verification details';
  document.getElementById('status').textContent=JSON.stringify(report,null,2);
  document.getElementById('report').disabled=false;return;
 }
 Object.assign(data,{font:font,fontsize:values[0],gap:values[1],wrapwidth:values[2]});
 fit();
}
fillControls();
for(const id of ['font','size','gap','wrap'])document.getElementById(id).oninput=invalidate;
document.getElementById('apply').onclick=applySettings;
document.getElementById('retry').onclick=applySettings;
document.getElementById('reset').onclick=function(){Object.assign(data,initialSettings);fillControls();fit();};
function savedHTML(){
 if(!current||document.body.dataset.status!=='PASS')return null;
 const copy=document.documentElement.cloneNode(true);
 copy.querySelector('#chartdata').textContent=JSON.stringify(data).replace(/</g,'\\u003c');
 copy.querySelector('#canvas').replaceChildren();
 copy.querySelector('body').dataset.status='PENDING';
 copy.querySelector('#status').textContent='Waiting for fresh font measurement…';
 copy.querySelector('#verdict').textContent='PENDING — rechecking saved settings';
 for(const id of ['download','savehtml','report'])copy.querySelector('#'+id).setAttribute('disabled','');
 copy.querySelector('details').removeAttribute('open');
 return '<!doctype html>\n'+copy.outerHTML;
}
document.getElementById('savehtml').onclick=function(){
 const content=savedHTML();if(content===null)return;
 const blob=new Blob([content],{type:'text/html;charset=utf-8'}),a=document.createElement('a');
 a.href=URL.createObjectURL(blob);a.download='radialchart_adjusted.html';a.click();
 setTimeout(function(){URL.revokeObjectURL(a.href);},1000);
};
document.getElementById('report').onclick=function(){if(!window.radialchartReport)return;const blob=new Blob([JSON.stringify(window.radialchartReport,null,2)],{type:'application/json'});const a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download='radialchart_report.json';a.click();setTimeout(function(){URL.revokeObjectURL(a.href);},1000);};
document.getElementById('download').onclick=function(){if(!current||document.body.dataset.status!=='PASS')return;const blob=new Blob([new XMLSerializer().serializeToString(current)],{type:'image/svg+xml'});const a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download='radialchart_measured.svg';a.click();setTimeout(function(){URL.revokeObjectURL(a.href);},1000);};
fit();
</script></html>
