{smcl}
{* *! version 0.15.1 15nov2026}{...}
{title:radialchart_export -- Browser-measured pie/donut HTML and SVG}

{title:Syntax}
{p 8 16 2}{cmd:radialchart_export using} {it:filename.html}
[{cmd:, replace fontface(}{it:font-family}{cmd:)}
{cmd:fontsize(}{it:pixels}{cmd:)} {cmd:gap(}{it:pixels}{cmd:)}
{cmd:wrapwidth(}{it:pixels}{cmd:)}]{p_end}

{title:Quick start}
{pstd}Run this entire block, omitting the leading dots. It restores loaded data
and writes/replaces chart.html in the working folder.{p_end}

{phang}{cmd:. preserve}{p_end}
{phang}{cmd:. clear}{p_end}
{phang}{cmd:. input str24 category double value}{p_end}
{phang}{cmd:. "Main activity" 90}{p_end}
{phang}{cmd:. "Secondary activity" 7}{p_end}
{phang}{cmd:. "Small category A" 2}{p_end}
{phang}{cmd:. "Small category B" 1}{p_end}
{phang}{cmd:. end}{p_end}
{phang}{cmd:. radialchart value, over(category) labels(outside) hole(.5)}{p_end}
{phang}{cmd:. radialchart_export using chart.html, replace wrapwidth(220)}{p_end}
{phang}{cmd:. restore}{p_end}

{pstd}Run the exporter immediately after radialchart with type(pie), including
donuts. It reads r(geometry), prepared r(label#) captions, colors, title and
center text. Open the self-contained HTML in a modern browser. No server,
network library, Python or Node installation is required by the user.{p_end}

{title:Options}
{phang}{cmd:replace} permits overwriting the specified HTML file.{p_end}

{phang}{cmd:fontface()} sets a CSS font-family list. Default: Arial, sans-serif.
Actual installed fonts or fallbacks determine measurements; fonts are not embedded.{p_end}

{phang}{cmd:fontsize()} is 6..72 pixels, default 14.{p_end}

{phang}{cmd:gap()} is 2..100 pixels between labels, default 8.{p_end}

{phang}{cmd:wrapwidth()} is 0..4000 pixels, default 0 (no automatic wrapping).
Breaks prefer spaces, otherwise grapheme boundaries with Intl.Segmenter, or
Unicode code points when that API is unavailable. Full text and whitespace
are preserved. Measured line heights determine multiline spacing.{p_end}

{title:Interactive workflow}
{pstd}Adjust font family, size, gap or wrap width in HTML, then Apply and verify.
Editing immediately invalidates the previous report and disables SVG/HTML
saving. Only the latest completed PASS can enable saving. Measure again also
applies the current controls. Restore exported settings uses the values
embedded in the open file.{p_end}

{phang}{bf:Download verified SVG} saves the current drawing after PASS.{p_end}

{phang}{bf:Save adjusted HTML} saves applied settings and chart data into a new
self-contained file. It discards the old rendered chart and verification and
remeasures on reopening. Reset in that file uses its saved values.{p_end}

{phang}{bf:Download report} saves JSON after PASS or FAIL.{p_end}

{pstd}Controls do not change Stata data or overwrite the original HTML. Reload
without saving loses edits. Use Save adjusted HTML rather than browser Save
Page. Reports record font, fontSize, gap and wrapWidth for reproducing settings
with the corresponding Stata options.{p_end}

{title:Layout and verification}
{pstd}The browser waits for document.fonts.ready and measures SVG getBBox().
All prepared captions move outside, including captions from mixed/legend mode.
For names and percentages, use labels(outside) outsidecontent(both) in the
preceding radialchart call. Earlier labelmax() shortening is retained.{p_end}

{pstd}The canvas grows for measured widths and heights. If connectors are too
close, the circle/routing corridor grows within bounded attempts and a
16000-pixel canvas limit. Zero-value captions remain but have no connectors.
Center text can enlarge the ring so its bounding rectangle fits the hole.{p_end}

{pstd}PASS requires unchanged caption text, compliance with wrapwidth, no
within-caption line overlap, no overlapping/clipped text boxes, no tested
connector crossings or contact with text/pie interior, and at least 1.5 pixels
between distinct connectors. Final measurements, not just input estimates,
control SVG and adjusted-HTML saving. Failure does not silently hide categories,
aggregate them or shrink the font.{p_end}

{pstd}This contract concerns measured geometry in the current browser. It does
not certify all fonts, renderers or arbitrary inputs. Another viewer, changed
fonts or resized output requires rechecking. Antialiasing, semantic ambiguity
of repeated captions and readability of subpixel sectors are outside the checks.{p_end}

{title:Diagnostics and failures}
{pstd}JSON reports include dimensions, font settings, expansion attempts and
connector-contact category indices (1-based chart order). Successful rendering
reports also include lineCounts, graphemeSegmentation, labelBoxes,
captionChanges, wrapOverflows, lineOverlaps, zeroLabels, subpixelSlices and
colorFallbacks. labelBoxes.id is zero-based. Subpixel/color warnings alone do
not invalidate layout PASS. Early failures may contain only error details.{p_end}

{phang}{bf:CANVAS_LIMIT}: required canvas exceeds the supported size. For
nearly coincident tiny slices consider native labels(legend).{p_end}

{phang}{bf:WRAP_TOO_NARROW}: one glyph cannot fit; increase wrapwidth or reduce
fontsize explicitly.{p_end}

{phang}{bf:INVALID_SETTINGS}: HTML controls contain blank/invalid values.
Use the ranges above, or restore settings.{p_end}

{phang}{bf:RENDER_ERROR}: retain the report and browser/version details for
review. Do not treat the displayed drawing as verified.{p_end}

{pstd}For a completed FAIL without an error code, inspect nonzero check counts
and suggestions. Correct the input/settings and remeasure before exporting.{p_end}

{title:Style and compatibility}
{pstd}This is a companion renderer, not native .gph/PNG automatic layout.
Non-pie types are unsupported. It uses plaintext (not SMCL), its own connector
style, common Stata color names and gs0..gs16 mappings. Other color styles use
a reported fallback palette; full Stata scheme/color parity is not claimed.
The default heading is Category composition when title() is empty.{p_end}

{pstd}If native Stata rejects special caption text, use labels(none) in the
preceding call. Prepared r(label#) captions remain available. Unicode, quotes
and script-like text are escaped as data rather than evaluated as markup.
The installed _radialchart_fit.ihlp is an internal HTML template, not a command.{p_end}

{title:Example and compatibility}
{pstd}The repository README includes an embedded-data example. After radialchart,
run radialchart_export and open the generated HTML in a browser. Local macOS
Chrome checks cover geometry, Unicode, whitespace, controls and saved-HTML
reopening. Windows validation remains pending. Inspect the current browser
report before saving; HTML generation alone does not establish layout PASS.{p_end}

{title:Author and license}
{pstd}choonjoo lee. Copyright (c) 2026 choonjoo lee.
Licensed under the Academic Free License version 3.0 (AFL-3.0).
See LICENSE for the complete terms and LICENSE_CODE.txt for scope/attribution.{p_end}
