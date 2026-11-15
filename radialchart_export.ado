*! radialchart_export 0.15.1 15nov2026
* Author: choonjoo lee
* Copyright (c) 2026 choonjoo lee. Licensed under the Academic Free License version 3.0.
* SPDX-License-Identifier: AFL-3.0; see LICENSE and LICENSE_CODE.txt.
program define radialchart_export
    version 16
    syntax using/ [, REPLACE FONTFace(string) FONTSize(real 14) GAP(real 8) WRAPWidth(real 0)]
    if "`r(type)'"!="pie" {
        di as err "Run radialchart with type(pie) immediately before radialchart_export"
        exit 301
    }
    tempname G
    matrix `G'=r(geometry)
    local n=rowsof(`G')
    local hole=r(hole)
    local heading `"`r(title)'"'
    local center `"`r(centertext)'"'
    forvalues i=1/`n' {
        local label`i' `"`r(label`i')'"'
        local color`i' `"`r(color`i')'"'
    }
    if "`fontface'"=="" local fontface "Arial, sans-serif"
    if !inrange(`fontsize',6,72) | !inrange(`gap',2,100) | !inrange(`wrapwidth',0,4000) error 198
    if "`replace'"=="" confirm new file `"`using'"'
    quietly findfile _radialchart_fit.ihlp
    local template `"`r(fn)'"'
    mata: _radialchart_export_json("`G'", `hole', `fontsize', `gap', `wrapwidth')
    tempname src dst
    file open `src' using `"`template'"', read text
    file open `dst' using `"`using'"', write text `replace'
    file read `src' line
    while r(eof)==0 {
        if `"`line'"'=="__RADIALCHART_DATA__" file write `dst' `"`json'"' _n
        else file write `dst' `"`line'"' _n
        file read `src' line
    }
    file close `src'
    file close `dst'
    di as text `"Created `using'; open in a browser to measure, fit and verify labels."'
end
mata:
string scalar _rc_jsonquote(string scalar s)
{
    real scalar i,c
    string scalar out,ch
    out=char(34)
    for(i=1;i<=strlen(s);i++) {
        ch=substr(s,i,1);c=ascii(ch)
        if(c==34 | c==92) out=out+char(92)+ch
        else if(c<32) out=out+char(92)+"u"+sprintf("%04x",c)
        else if(c==60) out=out+char(92)+"u003c"
        else out=out+ch
    }
    return(out+char(34))
}
string scalar _rc_jsonnum(real scalar x)
{
    string scalar s
    s=strtrim(strofreal(x,"%24.17g"))
    if(substr(s,1,1)==".") s="0"+s
    if(substr(s,1,2)=="-.") s="-0"+substr(s,2,.)
    return(s)
}
void _radialchart_export_json(string scalar matrixname, real scalar hole, real scalar size, real scalar gap, real scalar wrap)
{
    real matrix g
    real scalar i
    string scalar j
    g=st_matrix(matrixname)
    j="{"+char(34)+"hole"+char(34)+":"+_rc_jsonnum(hole)+","+char(34)+"fontsize"+char(34)+":"+_rc_jsonnum(size)
    j=j+","+char(34)+"gap"+char(34)+":"+_rc_jsonnum(gap)+","+char(34)+"font"+char(34)+":"+_rc_jsonquote(st_local("fontface"))
    j=j+","+char(34)+"wrapwidth"+char(34)+":"+_rc_jsonnum(wrap)
    j=j+","+char(34)+"title"+char(34)+":"+_rc_jsonquote(st_local("heading"))+","+char(34)+"center"+char(34)+":"+_rc_jsonquote(st_local("center"))
    j=j+","+char(34)+"rows"+char(34)+":["
    for(i=1;i<=rows(g);i++) {
        if(i>1) j=j+","
        j=j+"{"+char(34)+"label"+char(34)+":"+_rc_jsonquote(st_local("label"+strofreal(i)))
        j=j+","+char(34)+"color"+char(34)+":"+_rc_jsonquote(st_local("color"+strofreal(i)))
        j=j+","+char(34)+"share"+char(34)+":"+_rc_jsonnum(g[i,2])
        j=j+","+char(34)+"width"+char(34)+":"+_rc_jsonnum(g[i,3])
        j=j+","+char(34)+"mid"+char(34)+":"+_rc_jsonnum(g[i,5])+"}"
    }
    st_local("json",j+"]}")
}
end
