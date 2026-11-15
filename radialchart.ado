*! radialchart 0.15.1 15nov2026
* Author: choonjoo lee
* Copyright (c) 2026 choonjoo lee. Licensed under the Academic Free License version 3.0.
* SPDX-License-Identifier: AFL-3.0; see LICENSE and LICENSE_CODE.txt.
program define radialchart, rclass sortpreserve
    version 16.0
    syntax [varlist(numeric max=1 default=none)] [if] [in], OVER(varname) [TYPE(string) ///
        START(string) ANGLE0(string) NOCLOCKwise COUNTERClockwise SCALE(real 0) LABels(string) ///
        FORMAT(string) TITLE(string) NAME(string) REPLACE ///
        OUTSIDEpct(real 5) LABELGap(real .16) LABELSize(string) ///
        LABELContent(string) INSIDEContent(string) OUTSIDEContent(string) ///
        PCTDigits(integer 1) NOCONnect ///
        LABELMax(integer 0) LABELSpace(real 1.1) CONNECTor(string) CONNECTColor(string) ANCHors STATistic(string) MISSing SORT DESCending ///
        COLORS(string) COLORVar(varname numeric) COLOROrder(string) ///
        HOLE(real 0) CENTERText(string) CENTERSize(string) LEGENDCols(integer 1)]
    if "`start'" != "" & "`angle0'" != "" {
        di as err "Specify either start() or angle0(), not both"
        exit 198
    }
    foreach angle in start angle0 {
        if "``angle''" != "" {
            capture confirm number ``angle''
            if _rc error 198
            if missing(``angle'') error 198
        }
    }
    if "`angle0'" != "" local start = 90-`angle0'
    if "`start'" == "" local start 0
    local start = mod(mod(`start',360)+360,360)
    if "`noclockwise'" != "" local counterclockwise counterclockwise
    if "`type'" == "" local type pie
    if !inlist("`type'", "pie", "area", "radius", "spoke", "radar") {
        di as err "type() must be pie, area, radius, spoke, or radar"
        exit 198
    }
    if "`labels'" == "" local labels outside
    if !inlist("`labels'", "outside", "mixed", "legend", "none") error 198
    if !inrange(`legendcols',1,6) error 198
    if "`labels'"=="legend" & !inlist("`type'","pie","area","radius") {
        di as err "labels(legend) currently requires a sector chart"
        exit 198
    }
    if "`labels'" == "mixed" & "`type'" != "pie" {
        di as err "labels(mixed) currently applies only to type(pie)"
        exit 198
    }
    if !inrange(`outsidepct',0,100) | `labelgap'<=0 | missing(`labelgap') error 198
    if "`labelsize'" == "" local labelsize small
    if "`labelcontent'" == "" local labelcontent both
    if !inlist("`labelcontent'", "both", "name", "value", "percent") error 198
    foreach place in inside outside {
        if "``place'content'" == "" local `place'content "`labelcontent'"
        if !inlist("``place'content'", "both", "name", "value", "percent") error 198
    }
    if !inrange(`pctdigits',0,6) error 198
    if "`format'" == "" local format %9.3g
    if `scale' < 0 | missing(`scale') | missing(`start') error 198
    if "`type'" == "pie" & `scale' != 0 {
        di as err "scale() applies only to non-pie charts"
        exit 198
    }
    if `labelmax'<0 | (`labelmax'>0 & `labelmax'<4) error 198
    if `labelspace'<=0 | missing(`labelspace') error 198
    if "`connector'" == "" local connector routed
    if !inlist("`connector'", "routed", "direct") error 198
    if "`connectcolor'" == "" local connectcolor gray
    if !inlist("`connectcolor'", "gray", "slice") error 198
    if "`connectcolor'" == "slice" & !inlist("`type'", "pie", "area", "radius") {
        di as err "connectcolor(slice) requires a sector chart"
        exit 198
    }
    if "`statistic'" == "" local statistic = cond("`varlist'"=="","count","asis")
    if !inlist("`statistic'", "asis", "sum", "count") error 198
    if "`statistic'" == "count" & "`varlist'" != "" {
        di as err "statistic(count) counts observations; omit the value variable"
        exit 198
    }
    if "`statistic'" != "count" & "`varlist'" == "" {
        di as err "statistic(`statistic') requires a value variable"
        exit 198
    }
    if "`colors'" == "" local colors navy teal cranberry orange forest_green lavender gold sand
    local ncolors : word count `colors'
    if `ncolors'<1 | `ncolors'>20 {
        di as err "colors() requires 1 to 20 Stata color styles"
        exit 198
    }
    if "`colororder'" == "" local colororder category
    if !inlist("`colororder'", "category", "slice") error 198
    if "`colorvar'" != "" & "`colororder'"=="slice" {
        di as err "colorvar() cannot be combined with colororder(slice)"
        exit 198
    }
    if !inrange(`hole',0,.9) error 198
    if `hole'>0 & "`type'"!="pie" {
        di as err "hole() is supported only for type(pie)"
        exit 198
    }
    if `"`centertext'"'!="" & `hole'==0 {
        di as err "centertext() requires a positive hole()"
        exit 198
    }
    if "`centersize'"=="" local centersize medium
    marksample use, novarlist
    quietly count if `use'
    local ninput = r(N)
    if `ninput' == 0 error 2000
    if "`statistic'" == "asis" {
        quietly count if `use' & missing(`varlist')
        if r(N) error 459
        if "`missing'" == "" {
            quietly count if `use' & missing(`over')
            if r(N) error 459
        }
    }
    else {
        if "`missing'" == "" quietly replace `use'=0 if missing(`over')
        if "`statistic'" == "sum" quietly replace `use'=0 if missing(`varlist')
    }
    quietly count if `use'
    local nused = r(N)
    if `nused' == 0 error 2000
    if "`varlist'" != "" {
        quietly count if `use' & `varlist'<0
        if r(N) {
            di as err "Negative input values are not supported"
            exit 459
        }
    }
    preserve
    quietly {
        tempvar val cat key slot
        * Define the category universe before if/in and missing exclusions.
        egen long `key' = group(`over'), missing
        if "`colorvar'" != "" gen double `slot' = `colorvar'
        else gen double `slot' = mod(`key'-1,`ncolors')+1
        keep if `use'
        count if missing(`slot') | `slot'!=floor(`slot') | !inrange(`slot',1,`ncolors')
        if r(N) {
            noi di as err "colorvar() must contain integer palette slots from 1 to `ncolors' on used rows"
            exit 459
        }
        tempvar original_row
        gen long `original_row' = _n
        sort `key' `slot'
        capture by `key': assert `slot'==`slot'[1]
        if _rc {
            noi di as err "Each category must have one consistent colorvar() slot on used rows"
            exit 459
        }
        sort `original_row' 
        if "`statistic'" == "count" gen double `val' = 1
        else gen double `val' = `varlist'
        capture confirm string variable `over'
        if !_rc {
            gen strL `cat' = `over'
            replace `cat' = "(missing)" if missing(`over')
        }
        else {
            capture decode `over', gen(`cat')
            if _rc tostring `over', gen(`cat') usedisplayformat
        }
        keep `val' `cat' `key' `slot'
        rename `val' v
        rename `cat' category
        rename `key' category_id
        rename `slot' colorid
        compress category
        if "`statistic'" == "asis" {
            capture isid category_id
            if _rc {
                noi di as err "One row per category required for statistic(asis); use statistic(sum) to aggregate"
                exit 459
            }
        }
        else {
            sort category_id
            by category_id: replace v = sum(v)
            by category_id: keep if _n==_N
        }
        local ordering "input order retained"
        if "`statistic'" != "asis" local ordering "category order"
        gen long original_order = _n
        if "`sort'" != "" {
            if "`descending'" == "" sort v original_order
            else gsort -v original_order
            local ordering "ascending value order"
            if "`descending'" != "" local ordering "descending value order"
        }
        else if "`descending'" != "" {
            gsort -original_order
            local ordering "reversed category/input order"
        }
        local n = _N
        if `n' > 60 {
            noi di as err "This initial version supports at most 60 categories"
            exit 198
        }
        if "`type'" == "radar" & `n' < 3 {
            noi di as err "radar requires at least three categories"
            exit 459
        }
        summarize v, meanonly
        local total = r(sum)
        local vmax = r(max)
        if missing(`total') | `total' <= 0 {
            noi di as err "The selected values must have a finite positive total"
            exit 459
        }
        local reference = cond(`scale'==0, `vmax', `scale')
        if "`type'" != "pie" & `reference' < `vmax' {
            noi di as err "scale() must be at least the largest selected value"
            exit 459
        }
        gen int id = _n
        gen double share = v/`total'
        gen double width = cond("`type'"=="pie", 2*_pi*share, 2*_pi/`n')
        gen double begin = sum(width)-width
        local direction = cond("`counterclockwise'"=="",1,-1)
        local offset = `start'*_pi/180
        gen double mid = `offset'+`direction'*(begin+width/2)
        if inlist("`type'", "spoke", "radar") replace mid = `offset'+`direction'*begin
        gen double radius = 1
        if "`type'" == "area" replace radius = sqrt(v/`reference')
        if inlist("`type'", "radius", "spoke", "radar") replace radius = v/`reference'
        tempname geometry
        if "`colororder'"=="slice" replace colorid=mod(id-1,`ncolors')+1
        forvalues i=1/`n' {
            local slot`i' = colorid[`i']
            local hue`i' : word `slot`i'' of `colors'
        }
        mkmat v share width radius mid category_id colorid, matrix(`geometry')
        gen double ax = radius*sin(mid)
        gen double ay = radius*cos(mid)
        gen byte side = cond(sin(mid)>=0,1,-1)
        gen double ly = 1.15*cos(mid)
        local pctformat "%12.`pctdigits'f"
        local pctunit = 10^(-`pctdigits')
        local pctcut = strtrim(string(`pctunit', "`pctformat'"))
        gen strL percent = strtrim(string(100*share,"`pctformat'"))+"%"
        gen byte tinypercent = share>0 & real(strtrim(string(100*share,"`pctformat'")))==0
        replace percent = "<`pctcut'%" if tinypercent
        local pctupper = strtrim(string(100-`pctunit', "`pctformat'"))
        replace percent = ">`pctupper'%" if share<1 & real(strtrim(string(100*share,"`pctformat'")))==100
        count if tinypercent
        local ntinypercent = r(N)
        gen strL rawvalue = strtrim(string(v,"`format'"))
        gen strL shown = category
        gen byte shortened = 0
        if `labelmax'>0 {
            replace shortened = ustrlen(category)>`labelmax'
            replace shown = usubstr(category,1,`labelmax'-1)+uchar(8230) if shortened
        }
        count if shortened
        local nshortened = r(N)
        if `nshortened'>0 & "`labels'"!="none" & ///
            (inlist("`insidecontent'", "both", "name") | inlist("`outsidecontent'", "both", "name")) ///
            noi di as text "Note: `nshortened' category labels shortened by labelmax(); data unchanged."
        gen byte outside = "`labels'"=="outside"
        if "`labels'" == "mixed" replace outside = 100*share<=`outsidepct'
        gen strL caption = ""
        foreach place in inside outside {
            local content "``place'content'"
            if "`labels'"=="legend" local content "`outsidecontent'"
            local selection = cond("`place'"=="outside",1,0)
            if "`content'"=="name" replace caption=shown if outside==`selection'
            if "`content'"=="value" replace caption=rawvalue if outside==`selection'
            if "`content'"=="percent" replace caption=percent if outside==`selection'
            if "`content'"=="both" {
                if "`type'"=="pie" replace caption=shown+"  "+percent if outside==`selection'
                else replace caption=shown+"  "+rawvalue if outside==`selection'
            }
        }
        forvalues i=1/`n' {
            local caption`i' = caption[`i']
        }
        gen double ix = (`hole'+.65*(1-`hole'))*ax
        gen double iy = (`hole'+.65*(1-`hole'))*ay
        * Only outside labels participate in spacing, in vertical anchor order.
        sort outside side ly id
        * Least-squares spacing: pool adjacent violations after removing gap.
        mata: _radialchart_spread(`labelgap')
        gen double rx = side*1.08
        gen double ex = side*1.25
        gen double tx = side*1.45
        tempname layout
        sort id
        mkmat outside side ax ay ex tx ly ix iy rx, matrix(`layout')
        count if outside
        local noutside = r(N)
        gen double zero = 0
        sort id
        local plots
        local palette `colors'
        if inlist("`type'", "pie", "area", "radius") {
            local vertices = cond(`hole'>0,363,183)
            expand `vertices'
            bysort id: gen int vertex = _n
            gen double theta = `offset'+`direction'*(begin+width*(vertex-2)/180)
            gen double vradius = radius
            if `hole'>0 {
                replace theta = `offset'+`direction'*(begin+width*(vertex-1)/180) if vertex<=181
                replace theta = `offset'+`direction'*(begin+width*(362-vertex)/180) if inrange(vertex,182,362)
                replace theta = `offset'+`direction'*begin if vertex==363
                replace vradius = `hole' if inrange(vertex,182,362)
            }
            gen double px=vradius*sin(theta)
            gen double py=vradius*cos(theta)
            if `hole'==0 {
                replace px=0 if inlist(vertex,1,183)
                replace py=0 if inlist(vertex,1,183)
            }
            forvalues i=1/`n' {
                local ci = `slot`i''
                local color : word `ci' of `palette'
                local outline "lcolor(white) lwidth(vthin)"
                if "`type'"=="pie" {
                    count if id==`i' & share==1
                    if r(N)>0 local outline "lcolor(white) lwidth(none)"
                }
                local plots `plots' (area py px if id==`i' & v>0, nodropbase fcolor(`color') fintensity(75) `outline')
            }
            foreach variable in ax ay ly ex tx ix iy rx {
                replace `variable' = . if vertex!=1
            }
        }
        else {
            local plots (pcspike zero zero ay ax, lcolor(gs12)) (scatter ay ax, mcolor(navy) msymbol(O))
            if "`type'" == "radar" {
                local last = `n'+1
                set obs `last'
                replace ax=ax[1] in `last'
                replace ay=ay[1] in `last'
                local plots `plots' (line ay ax, lcolor(navy))
            }
        }
        local labelplots
        if inlist("`labels'", "outside", "mixed") {
            local groups = cond("`connectcolor'"=="slice",`ncolors',1)
            forvalues c=1/`groups' {
                local restriction "outside==1"
                local linecolor gs8
                if "`connectcolor'" == "slice" {
                    local restriction "outside==1 & colorid==`c'"
                    local linecolor : word `c' of `palette'
                }
                if "`noconnect'" == "" {
                    if "`connector'" == "direct" local labelplots `labelplots' ///
                        (pcspike ay ax ly ex if `restriction', lcolor(`linecolor') lwidth(thin))
                    else local labelplots `labelplots' ///
                        (pcspike ay ax ay rx if `restriction', lcolor(`linecolor') lwidth(thin)) ///
                        (pcspike ay rx ly ex if `restriction', lcolor(`linecolor') lwidth(thin))
                    local labelplots `labelplots' ///
                        (pcspike ly ex ly tx if `restriction', lcolor(`linecolor') lwidth(thin))
                }
                if "`anchors'" != "" local labelplots `labelplots' ///
                    (scatter ay ax if `restriction', msymbol(O) msize(vsmall) mcolor(`linecolor'))
            }
            local labelplots `labelplots' ///
                (scatter ly tx if side==1 & outside==1, msymbol(none) mlabel(caption) mlabposition(3) mlabsize(`labelsize') mlabcolor(black)) ///
                (scatter ly tx if side==-1 & outside==1, msymbol(none) mlabel(caption) mlabposition(9) mlabsize(`labelsize') mlabcolor(black))
            if "`labels'" == "mixed" local labelplots `labelplots' ///
                (scatter iy ix if outside==0, msymbol(none) mlabel(caption) mlabposition(0) mlabsize(`labelsize') mlabcolor(black))
        }
        local bound = 1.35
        if `noutside' > 0 {
            summarize ly if outside==1, meanonly
            local bound = max(1.35, abs(r(min))+.15, abs(r(max))+.15)
        }
        local xbound = max(1.45+`labelspace', `bound')
        local ratio = `bound'/`xbound'
        local naming
        if "`name'" != "" local naming name(`name', `replace')
        local note ""
        if "`type'" == "pie" local note "Shares of selected total = `total'; `ordering'."
        if "`type'" == "area" local note "Sector AREA proportional to value; outer radius represents `reference'."
        if inlist("`type'", "radius", "spoke", "radar") local note "RADIAL LENGTH proportional to value; outer radius represents `reference'."
        local legendopt legend(off)
        if "`labels'"=="legend" {
            local legendorder
            forvalues i=1/`n' {
                local legendorder `"`legendorder' `i' `"`caption`i''"'"'
            }
            local legendopt `"legend(on order(`legendorder') cols(`legendcols') position(6) size(`labelsize'))"'
        }
        local centering
        if `"`centertext'"'!="" local centering text(0 0 `"`centertext'"', size(`centersize') color(black) placement(c))
        twoway `plots' `labelplots', ///
            xscale(range(-`xbound' `xbound') off) yscale(range(-`bound' `bound') off) ///
            xlabel(none) ylabel(none) `legendopt' aspectratio(`ratio') ///
            title(`"`title'"') note(`"`note'"', size(vsmall)) ///
            graphregion(color(white)) plotregion(margin(zero)) `naming' `centering'
    }
    restore
    forvalues i=1/`n' {
        return local color`i' `"`hue`i''"'
        return local label`i' `"`caption`i''"'
    }
    return local colors "`colors'"
    return local colororder "`colororder'"
    return local title `"`title'"'
    return local centertext `"`centertext'"'
    return local labels "`labels'"
    return scalar N_legend = cond("`labels'"=="legend",`n',0)
    return scalar hole = `hole'
    return scalar N_tinypercent = `ntinypercent'
    return scalar pctdigits = `pctdigits'
    return local insidecontent "`insidecontent'"
    return local outsidecontent "`outsidecontent'"
    return scalar start = `start'
    return scalar clockwise = (`direction'==1)
    return local order "`ordering'"
    return local statistic "`statistic'"
    return scalar N_input = `ninput'
    return scalar N_used = `nused'
    return scalar N_shortened = `nshortened'
    return scalar N_outside = `noutside'
    return matrix layout = `layout'
    return scalar N = `n'
    return scalar total = `total'
    return scalar reference = cond("`type'"=="pie",.,`reference')
    return local type "`type'"
    return matrix geometry = `geometry'
end


mata:
void _radialchart_spread(real scalar gap)
{
    real colvector outside, side, y, idx, z, level, weight, first, last, fit
    real scalar s, n, i, k, j, lower, upper, bound
    outside = st_data(., "outside")
    side = st_data(., "side")
    y = st_data(., "ly")
    for (s=-1; s<=1; s=s+2) {
        idx = selectindex((outside:==1) :& (side:==s))
        n = length(idx)
        if (n==0) continue
        z = y[idx] :- (0::n-1)*gap
        level = weight = first = last = J(n,1,0)
        k = 0
        for (i=1; i<=n; i++) {
            k++
            level[k] = z[i]
            weight[k] = 1
            first[k] = last[k] = i
            while (k>1) {
                if (level[k-1]<=level[k]) break
                level[k-1] = (weight[k-1]*level[k-1]+weight[k]*level[k])/(weight[k-1]+weight[k])
                weight[k-1] = weight[k-1]+weight[k]
                last[k-1] = last[k]
                k--
            }
        }
        bound = max((1.15,(n-1)*gap/2))
        lower = -bound
        upper = bound-(n-1)*gap
        fit = J(n,1,.)
        for (j=1; j<=k; j++) {
            for (i=first[j]; i<=last[j]; i++) {
                fit[i] = min((upper,max((lower,level[j]))))+(i-1)*gap
            }
        }
        y[idx] = fit
    }
    st_store(., "ly", y)
}
end
