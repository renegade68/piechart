{smcl}
{* *! version 0.15.1 15nov2026}{...}
{title:radialchart -- Five radial displays of nonnegative category values}

{title:Syntax}
{p 8 16 2}
{cmd:radialchart} [{it:value}] {ifin}, {cmd:over(}{it:category}{cmd:)}
[{cmd:type(pie|area|radius|spoke|radar)} {cmd:start(}{it:degrees}{cmd:)}
{cmd:counterclockwise} {cmd:scale(}{it:maximum}{cmd:)}
{cmd:labels(outside|mixed|legend|none)} {cmd:format(}{it:format}{cmd:)}
{cmd:title(}{it:text}{cmd:)} {cmd:name(}{it:name}{cmd:)} {cmd:replace} {cmd:outsidepct(}{it:percent}{cmd:)}
{cmd:labelgap(}{it:distance}{cmd:)} {cmd:labelsize(}{it:size}{cmd:)}
{cmd:labelcontent(both|name|value|percent)}
{cmd:insidecontent(both|name|value|percent)}
{cmd:outsidecontent(both|name|value|percent)} {cmd:pctdigits(}{it:0..6}{cmd:)} {cmd:noconnect} {cmd:connector(routed|direct)}
{cmd:labelmax(}{it:characters}{cmd:)} {cmd:labelspace(}{it:distance}{cmd:)} {cmd:connectcolor(gray|slice)} {cmd:anchors} {cmd:statistic(asis|sum|count)} {cmd:missing} {cmd:angle0(}{it:degrees}{cmd:)} {cmd:noclockwise}
{cmd:sort} {cmd:descending} {cmd:colors(}{it:colorlist}{cmd:)}
{cmd:colorvar(}{it:slotvar}{cmd:)} {cmd:colororder(category|slice)} {cmd:hole(}{it:fraction}{cmd:)}
{cmd:centertext(}{it:text}{cmd:)} {cmd:centersize(}{it:size}{cmd:)} {cmd:legendcols(}{it:1..6}{cmd:)}]

{title:Description}
{pstd}Requires Stata 16 or later; no additional packages. The default with
a value variable is statistic(asis): one selected row per category, input order
retained, nonmissing nonnegative values required. Without a value variable,
the default is statistic(count): count selected observations by category.
statistic(sum) explicitly sums a supplied value variable by category.
Count and sum output categories in numeric-code or string sort order.

{pstd}Count excludes missing categories by default. Sum excludes missing
categories and missing values by default; categories with no nonmissing values
are omitted. The missing option includes missing categories, but never imputes
missing values. In asis mode missing categories are errors unless missing is
specified, and missing values remain errors. Negative values are rejected
before aggregation. The resulting values must have a finite positive total.
Count does not accept a value variable; use if to restrict observations.
No weights or multiple value variables are supported in this version.

{pstd}Numeric category identity is distinct from its displayed value label.
Different codes with identical labels remain distinct categories. Identical
labels may be visually ambiguous; use distinct value labels when possible.
Original data, order and labels are preserved, including on drawing errors.

{pstd}{cmd:type(pie)} (default) fixes radius and assigns angles proportional
to values. Default labels show percentages of the selected total, not of an assumed
population total. No residual category is added. Zero values occupy zero angle.

{pstd}{cmd:type(area)} gives each category equal angle and makes sector area
proportional to its value: radius = sqrt(value/reference).
{cmd:type(radius)} instead uses radius = value/reference; its area therefore
varies with value squared. Do not interpret its areas as proportional values.

{pstd}{cmd:type(spoke)} draws radial segments and endpoint markers.
{cmd:type(radar)} also joins the endpoints in chart order and closes the line;
at least three categories are required. These use radius = value/reference.
There is one series only. The command does not standardize different units.

{title:Options}
{pstd}{cmd:start()} defaults to zero (12 o'clock); positive degrees move
clockwise. {cmd:counterclockwise} reverses traversal from that starting direction.
Sectors start at this direction; spoke/radar place their first axis there.

{pstd}{cmd:scale()} sets the reference value for unit radius in non-pie types.
It must be at least the observed maximum. Default zero chooses that maximum.
Set the same scale across charts when comparing magnitudes. Pie rejects this option.

{pstd}{cmd:labels(outside)} (default) places all labels outside.
{cmd:labels(mixed)} is available for pie only: slices at or below
{cmd:outsidepct()} percent of the selected total go outside with connectors;
the rest are labeled inside (65% of radius for pie; adjusted for a donut hole). The default threshold is 5
percentage points (enter 5, not .05). Zero slices also satisfy this threshold,
but have no visible sector. This is a share threshold, not a text-fit detector.
{cmd:labels(none)} omits labels and their connectors.

{pstd}{cmd:labelcontent(both)} shows category and percentage for pie, category
and value otherwise. {cmd:name}, {cmd:value}, and {cmd:percent} select category
only, raw value only, and percentage of selected total only, respectively.
{cmd:labelgap()} defaults to .16 unit-radius coordinate units and controls the
minimum vertical separation on each side for outside labels only.
{cmd:labelsize()} defaults to small. Increase gap when increasing text size.
{cmd:noconnect} suppresses label connectors, not the spokes of spoke/radar charts.
Long names inside a slice can exceed its boundary; use labelcontent(percent),
a larger outsidepct(), or labels(outside) in that case.
{cmd:format()} defaults to %9.3g for raw value labels.
Percentages default to one decimal place; pctdigits() controls precision.
Rounded labels need not sum to exactly 100.

{title:Limits of this initial release}
{pstd}At most 60 categories; the default eight-color palette cycles. Sectors use 180 straight
segments to approximate circular arcs. Labels use a configurable vertical gap,
not measured text extents. Long labels, dense categories, zero-value connectors
and crossings may require labels(none), fewer categories or a different display.
This is not a general collision-avoidance algorithm. Radial grids, multiple series and negative values are not supported. Value sorting is available via sort.

{title:Examples}
{pstd}Run each complete block, omitting the leading dots. Each block restores
the dataset previously in memory.
{phang}{cmd:. preserve}
{phang}{cmd:. sysuse auto, clear}
{phang}{cmd:. collapse (count) count=price, by(rep78)}
{phang}{cmd:. drop if missing(rep78)}
{phang}{cmd:. radialchart count, over(rep78) type(pie)}
{phang}{cmd:. radialchart count, over(rep78) type(area)}
{phang}{cmd:. radialchart count, over(rep78) type(radius)}
{phang}{cmd:. restore}

{title:Saved results}
{pstd}{cmd:r(N)} categories; {cmd:r(total)} selected total;
{cmd:r(reference)} unit-radius value (missing for pie); {cmd:r(type)} chart type.
{cmd:r(geometry)} contains one row per category in final chart order, with columns
{cmd:v share width radius mid category_id colorid}. Width and mid are radians. Coordinates use
x = radius*sin(mid), y = radius*cos(mid); width is the positive angular span,
while mid includes the chosen start and direction. Spoke/radar width records
axis spacing. Radii are normalized plotting coordinates.

{title:Small-slice example}
{phang}{cmd:. preserve}
{phang}{cmd:. clear}
{phang}{cmd:. input str24 category double value}
{phang}{cmd:. "Main activity" 90}
{phang}{cmd:. "Secondary activity" 7}
{phang}{cmd:. "Small category A" 2}
{phang}{cmd:. "Small category B" 1}
{phang}{cmd:. end}
{phang}{cmd:. radialchart value, over(category) type(pie) labels(mixed) outsidepct(5) insidecontent(percent)}
{phang}{cmd:. radialchart value, over(category) labels(outside) labelgap(.20)}
{phang}{cmd:. restore}

{title:Additional saved results}
{pstd}{cmd:r(N_outside)} is the count of outside labels.
{cmd:r(layout)} has one row per category in final chart order, with columns
{cmd:outside side ax ay ex tx ly ix iy rx}. The first column marks outside labels;
side is -1 or 1; ax/ay is the connector anchor, ex/ly the elbow, tx/ly the text
position, and ix/iy the inside text position. Coordinates for inactive label
positions are retained for diagnostics; labels(none) draws none of them.

{title:Routing and long labels}
{pstd}{cmd:connector(routed)} is the default. It draws a horizontal segment
from each anchor to x=+/-1.08, a segment to the elbow at x=+/-1.25,
and a horizontal segment to the label at x=+/-1.45. For a unit-radius pie,
these segments stay outside its interior. This does not guarantee that every
pair of connectors is distinguishable, especially near the top/bottom or
zero-size slices. {cmd:connector(direct)} uses the earlier two-segment path.
The added {cmd:rx} column in r(layout) records the routing corridor coordinate.

{pstd}{cmd:labelmax()} defaults to 0 (no shortening). A value of at least 4
limits category text to that many Unicode characters, including a final
ellipsis. Numeric label content is retained. Data are never shortened.
Shortened categories may become visually indistinguishable; use full labels
when that matters. r(N_shortened) counts category strings shortened internally.

{pstd}{cmd:labelspace()} reserves horizontal coordinate space beyond each
label anchor (default 1.1). For long labels try labelspace(3), labelmax(24),
and labelgap(.20), then inspect the exported graph. More space shrinks the
pie within a fixed graph size; adjust labelgap() and labelsize() accordingly.
This is explicit layout control, not automatic font-metric measurement.

{title:Dense connectors and label spacing}
{pstd}{cmd:connectcolor(slice)} matches the connector hue to its sector
(pie, area, radius only). Default {cmd:connectcolor(gray)} retains neutral
connectors. {cmd:anchors} adds small dots at outside-label connector anchors.
Anchors can also be shown with noconnect. Colors cycle after the palette length;
color alone is not a unique category key.

{pstd}Outside labels on each side retain their vertical order. A pooled
adjacent-violators calculation minimizes the sum of squared displacements
from their target heights subject to labelgap() and the available vertical
bounds. If the requested spacing cannot fit, the bounds expand symmetrically.
This optimizes coordinate positions only; it does not measure font extents.
For positive unit-radius pie slices, ordered heights also keep the diagonal
segments within each routing corridor in order. Coincident zero-slice anchors,
very small differences and variable-radius charts need separate inspection.
No universal pixel-level overlap or crossing guarantee is made.

{title:Raw-data examples and input accounting}
{phang}{cmd:. preserve}
{phang}{cmd:. sysuse auto, clear}
{phang}{cmd:. radialchart, over(rep78) labels(mixed)}
{phang}{cmd:. radialchart price, over(rep78) statistic(sum) labels(outside)}
{phang}{cmd:. radialchart, over(rep78) missing}
{phang}{cmd:. restore}
{pstd}r(statistic) reports the input mode; r(N_input) counts rows selected by
if/in before missing exclusions; r(N_used) counts rows actually used before
aggregation. r(N) remains the number of chart categories. category_id in
r(geometry) is an internally generated group ID, not the original numeric code.
Rows in saved matrices follow chart order (input order for asis, category order
for count/sum, unless sort or descending changes it). This command is not a drop-in replacement for graph pie:
notably the default with a value variable is asis, not sum.

{title:Stata-style orientation and ordering}
{pstd}{cmd:angle0()} uses mathematical degrees: 0 is right, 90 is up,
180 is left and 270 is down. It maps to start = 90 - angle0.
Specify either angle0() or start(), never both. Finite angles are normalized
modulo 360. Default is start(0), equivalent to angle0(90).
{cmd:noclockwise} is an alias for counterclockwise. Default traversal is clockwise.

{pstd}{cmd:sort} orders categories from smallest to largest plotted value.
{cmd:sort descending} orders largest first. Ties retain the pre-sort order.
{cmd:descending} alone reverses the default input/category order.
Unlike graph pie, sort(varname) is not supported. Colors default to category order in the full dataset, independent of chart
sorting; colororder(slice) restores the older chart-order mapping. Radar ordering
changes its profile; choose an order meaningful for the categories.

{pstd}Additional results: r(start) is the normalized clockwise angle from
12 o'clock; r(clockwise) is 1 for clockwise and 0 for counterclockwise;
r(order) describes the applied ordering. Labels, thresholds, anchors and
matrix rows all refer to the final chart order.

{title:Separate label content and percentage precision}
{pstd}{cmd:insidecontent()} and {cmd:outsidecontent()} independently override
{cmd:labelcontent()} for inside and outside positions. Both inherit labelcontent
when omitted, retaining existing behavior. For mixed pie labels, try
insidecontent(percent) outsidecontent(both) to avoid long names inside wedges.
The options change text, not the share threshold or geometry. In non-pie types,
both means name plus raw value; percent explicitly requests share of total.

{pstd}{cmd:pctdigits()} accepts integers 0 through 6 (default 1). Positive
shares rounding to zero are displayed as less than one unit of that precision,
for example <0.1%. Shares below 100% that round to 100% display >99.9% at one
decimal. These are bounds, not exact values. Actual zero and full shares retain
0.0% and 100.0%. With pctdigits(2), 0.04% is displayed as 0.04%.
Percent digits apply to percentage content; format() still controls raw values.

{pstd}r(label1) through r(labelN) return prepared captions in final chart order,
including when labels(none) suppresses drawing. r(insidecontent),
r(outsidecontent), and r(pctdigits) report the resolved settings.
r(N_tinypercent) counts positive shares that round to zero at the chosen
precision, regardless of whether percentage labels are drawn.

{title:Stable category colors}
{pstd}{cmd:colors()} supplies 1 to 20 space-separated Stata color styles,
for example colors(navy teal cranberry orange) or colors(gs3 gs6 gs9 gs12).
Use named styles/modifiers; compound RGB specifications are not part of the
validated interface. The default palette remains eight colors. Colors cycle
when there are more categories than palette entries. Stroke hue matches the
selected palette entry with connectcolor(slice); fills use 75% intensity.
For very pale colors use connectcolor(gray) to keep lines visible.

{pstd}{cmd:colororder(category)} is the new default. Palette slots are assigned
using the category order of the entire loaded dataset BEFORE if/in or missing
exclusions. Consequently sorting or if/in filtering preserves category colors.
Missing and excluded categories can reserve slots. Physically dropping/adding
categories, loading another dataset, or changing palette length can change
this automatic mapping. Numeric codes, not their display labels, identify groups.

{pstd}{cmd:colorvar()} gives explicit integer slots between 1 and the palette
length. All used rows of a category must have the same slot; different categories
may intentionally share a slot. Store the slot with the data for consistent
colors across datasets or physical subsets. colororder(slice) instead cycles
colors in plotted order for compatibility with earlier versions, and cannot
be combined with colorvar(). Color options affect sector charts and their
matching connectors; spoke/radar retain their single-series styling.

{pstd}The appended colorid column in r(geometry) records palette slots.
r(color1)...r(colorN) return resolved color styles in plotted order;
r(colors) and r(colororder) record palette and mapping policy.

{title:Donut charts}
{pstd}{cmd:hole()} specifies the inner radius as a fraction of unit outer
radius, from 0 (ordinary pie, default) to .9. Positive hole() requires type(pie).
All slices have the same inner radius, retaining their angle and ring-area
proportions. Each ring sector is drawn as an annular polygon, not a white disk
placed over a pie. Inner and outer arcs use 180 segments each. Polygon areas
approximate exact circular areas; very small slices can be subpixel at export.

{pstd}{cmd:centertext()} places a user-supplied string at the center and requires
a positive hole(). It does not calculate a total or infer units.
{cmd:centersize()} defaults to medium. Keep text short or reduce its size;
there is no automatic fit-to-hole measurement. With mixed labels, internal
text is placed at radius hole + .65*(1-hole). For thin rings use labels(outside).
Anchors and connectors still touch the outer edge. r(hole) returns the fraction.
Zero values draw no sector; their label policy is unchanged. A full-circle
single sector has no artificial radial outline seam.

{title:Explicit legend alternative for crowded or long labels}
{pstd}{cmd:labels(legend)} moves all category captions to a legend below the
chart, suppressing outside/inside labels, label connectors and anchor dots.
Available for pie (including donut), area and radius. It preserves all
categories including zero-valued categories, which have a legend entry but
no drawn sector. The command never silently switches modes, hides categories
or combines small slices into Other.

{pstd}{cmd:legendcols()} controls columns from 1 to 6 (default 1).
{cmd:outsidecontent()} controls legend text and inherits labelcontent() when
omitted. labelsize(), labelmax() and pctdigits() apply to legend captions.
For complete category names omit labelmax(). The legend follows chart order,
with keys matching sector colors. r(N_legend) reports entry count;
r(N_outside) is zero in this mode, and r(labels) reports the chosen label mode.

{pstd}Legend mode is an explicit alternative, not an automatic overflow detector.
It still consumes space: many entries or exceptionally long text may require
smaller labelsize(), more columns, shorter names or a larger exported graph.
No font-fit or universal no-clipping guarantee is made.

{title:Browser-measured export}
{pstd}After a pie/donut call, {help radialchart_export} creates self-contained
HTML that measures actual text bounds, refits all captions outside and checks
collisions before enabling SVG download. This optional renderer leaves native
Stata graphs unchanged. See its help for the bounded verification contract,
style differences and browser-dependent font behavior.

{title:Author and license}
{pstd}choonjoo lee. Copyright (c) 2026 choonjoo lee.
Licensed under the Academic Free License version 3.0 (AFL-3.0).
See LICENSE for the complete terms and LICENSE_CODE.txt for scope/attribution.
