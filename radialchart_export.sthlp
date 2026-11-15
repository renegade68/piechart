{smcl}
{* *! version 0.15.1 15nov2026}{...}
{title:radialchart_export -- Browser-measured pie/donut HTML and SVG}

{title:Syntax}
{p 8 16 2}{cmd:radialchart_export using} {it:filename.html}
[{cmd:, replace fontface(}{it:font-family}{cmd:)}
{cmd:fontsize(}{it:pixels}{cmd:)} {cmd:gap(}{it:pixels}{cmd:)}
{cmd:wrapwidth(}{it:pixels}{cmd:)}]

{title:Quick start}
{pstd}Run this entire block, omitting the leading dots. It restores loaded data
and writes/replaces chart.html in the working folder.
{phang}{cmd:. preserve}
{phang}{cmd:. clear}
{phang}{cmd:. input str24 category double value}
{phang}{cmd:. "Main activity" 90}
{phang}{cmd:. "Secondary activity" 7}
{phang}{cmd:. "Small category A" 2}
{phang}{cmd:. "Small category B" 1}
{phang}{cmd:. end}
{phang}{cmd:. radialchart value, over(category) labels(outside) hole(.5)}
{phang}{cmd:. radialchart_export using chart.html, replace wrapwidth(220)}
{phang}{cmd:. restore}
{pstd}Run the exporter immediately after radialchart with type(pie), including
donuts. It reads r(geometry), prepared r(label#) captions, colors, title and
center text. Open the self-contained HTML in a modern browser. No server,
network library, Python or Node installation is required by the user.

{title:Options}
{phang}{cmd:replace} permits overwriting the specified HTML file.
{phang}{cmd:fontface()} sets a CSS font-family list. Default: Arial, sans-serif.
Actual installed fonts or fallbacks determine measurements; fonts are not embedded.
{phang}{cmd:fontsize()} is 6..72 pixels, default 14.
{phang}{cmd:gap()} is 2..100 pixels between labels, default 8.
{phang}{cmd:wrapwidth()} is 0..4000 pixels, default 0 (no automatic wrapping).
Breaks prefer spaces, otherwise grapheme boundaries with Intl.Segmenter, or
Unicode code points when that API is unavailable. Full text and whitespace
are preserved. Measured line heights determine multiline spacing.

{title:Interactive workflow}
{pstd}Adjust font family, size, gap or wrap width in HTML, then Apply and verify.
Editing immediately invalidates the previous report and disables SVG/HTML
saving. Only the latest completed PASS can enable saving. Measure again also
applies the current controls. Restore exported settings uses the values
embedded in the open file.
{phang}{bf:Download verified SVG} saves the current drawing after PASS.
{phang}{bf:Save adjusted HTML} saves applied settings and chart data into a new
self-contained file. It discards the old rendered chart and verification and
remeasures on reopening. Reset in that file uses its saved values.
{phang}{bf:Download report} saves JSON after PASS or FAIL.
{pstd}Controls do not change Stata data or overwrite the original HTML. Reload
without saving loses edits. Use Save adjusted HTML rather than browser Save
Page. Reports record font, fontSize, gap and wrapWidth for reproducing settings
with the corresponding Stata options.

{title:Layout and verification}
{pstd}The browser waits for document.fonts.ready and measures SVG getBBox().
All prepared captions move outside, including captions from mixed/legend mode.
For names and percentages, use labels(outside) outsidecontent(both) in the
preceding radialchart call. Earlier labelmax() shortening is retained.
{pstd}The canvas grows for measured widths and heights. If connectors are too
close, the circle/routing corridor grows within bounded attempts and a
16000-pixel canvas limit. Zero-value captions remain but have no connectors.
Center text can enlarge the ring so its bounding rectangle fits the hole.
{pstd}PASS requires unchanged caption text, compliance with wrapwidth, no
within-caption line overlap, no overlapping/clipped text boxes, no tested
connector crossings or contact with text/pie interior, and at least 1.5 pixels
between distinct connectors. Final measurements, not just input estimates,
control SVG and adjusted-HTML saving. Failure does not silently hide categories,
aggregate them or shrink the font.
{pstd}This contract concerns measured geometry in the current browser. It does
not certify all fonts, renderers or arbitrary inputs. Another viewer, changed
fonts or resized output requires rechecking. Antialiasing, semantic ambiguity
of repeated captions and readability of subpixel sectors are outside the checks.

{title:Diagnostics and failures}
{pstd}JSON reports include dimensions, font settings, expansion attempts and
connector-contact category indices (1-based chart order). Successful rendering
reports also include lineCounts, graphemeSegmentation, labelBoxes,
captionChanges, wrapOverflows, lineOverlaps, zeroLabels, subpixelSlices and
colorFallbacks. labelBoxes.id is zero-based. Subpixel/color warnings alone do
not invalidate layout PASS. Early failures may contain only error details.
{phang}{bf:CANVAS_LIMIT}: required canvas exceeds the supported size. For
nearly coincident tiny slices consider native labels(legend).
{phang}{bf:WRAP_TOO_NARROW}: one glyph cannot fit; increase wrapwidth or reduce
fontsize explicitly.
{phang}{bf:INVALID_SETTINGS}: HTML controls contain blank/invalid values.
Use the ranges above, or restore settings.
{phang}{bf:RENDER_ERROR}: retain the report and browser/version details for
review. Do not treat the displayed drawing as verified.
{pstd}For a completed FAIL without an error code, inspect nonzero check counts
and suggestions. Correct the input/settings and remeasure before exporting.

{title:Style and compatibility}
{pstd}This is a companion renderer, not native .gph/PNG automatic layout.
Non-pie types are unsupported. It uses plaintext (not SMCL), its own connector
style, common Stata color names and gs0..gs16 mappings. Other color styles use
a reported fallback palette; full Stata scheme/color parity is not claimed.
The default heading is Category composition when title() is empty.
{pstd}If native Stata rejects special caption text, use labels(none) in the
preceding call. Prepared r(label#) captions remain available. Unicode, quotes
and script-like text are escaped as data rather than evaluated as markup.
The installed _radialchart_fit.ihlp is an internal HTML template, not a command.

{title:Example and compatibility}
{pstd}The repository README includes an embedded-data example. After radialchart,
run radialchart_export and open the generated HTML in a browser. Local macOS
Chrome checks cover geometry, Unicode, whitespace, controls and saved-HTML
reopening. Windows validation remains pending. Inspect the current browser
report before saving; HTML generation alone does not establish layout PASS.

{title:Author and license}
{pstd}choonjoo lee. Copyright (c) 2026 choonjoo lee.
Licensed under the Academic Free License version 3.0 (AFL-3.0).
See LICENSE for the complete terms and LICENSE_CODE.txt for scope/attribution.
