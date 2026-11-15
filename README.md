# radialchart

Pie and donut charts with outside labels and connectors for small slices.
Also provides area, radius, spoke and radar displays.

**Author:** choonjoo lee · **Version:** 0.15.1 · **Requires:** Stata 16 or later

## Install

Install directly from GitHub in Stata:

```stata
net install radialchart, from("https://raw.githubusercontent.com/renegade68/piechart/main") replace
help radialchart
help radialchart_export
```

For a downloaded copy, keep all files together and install from its absolute
folder path (use forward slashes on Windows):

```stata
net install radialchart, from("C:/work/piechart") replace
```

On macOS, use the corresponding local folder path. No third-party ado is needed.
The `_radialchart_fit.ihlp` file is a required HTML template for browser export;
keep it with the ado files. It is not a standalone Stata command.

## Try it

Copy this complete example. It restores the dataset already in memory and
writes/replaces `chart.html` in the current working folder.

```stata
preserve
clear
input str40 category double value
"Main activity" 90
"Secondary activity" 7
"Small category A" 2
"Small category B" 1
end
radialchart value, over(category) labels(mixed) outsidepct(5) ///
    connectcolor(slice) anchors hole(.5) insidecontent(percent)
radialchart_export using chart.html, replace fontsize(14) wrapwidth(220)
restore
```

The native Stata graph places small-slice labels outside with connectors.
Remove `hole(.5)` for a pie without a hole. Use `labels(outside)` for all outside
labels or `labels(legend)` for a legend. Percentages describe the supplied total.

Open `chart.html` in a modern browser. This companion renderer places all
prepared captions outside, measures the actual fonts and checks layout.
Adjust font, size, gap and wrap width, then **Apply and verify**. After PASS:

- **Download verified SVG** saves the drawing.
- **Save adjusted HTML** retains the chart and settings and rechecks on reopening.
- **Download report** saves diagnostic JSON; this also works after failure.

Changing controls invalidates the previous verification. Unsaved changes are
lost on reload. Saving adjusted HTML creates a new file; it does not change
Stata data or overwrite the original HTML.

## Other inputs and options

```stata
* Count raw observations by category
radialchart, over(category)

* Sum a variable by category
radialchart amount, over(category) statistic(sum)
```

For one value per category, supply that value variable without `statistic()`.
Values must be nonnegative. See `help radialchart` for missing-data rules,
colors, sorting, orientation, label content and percentage precision.

`type(area)` encodes values by sector area; `type(radius)` encodes them by
radius. `type(spoke)` and `type(radar)` provide other radial displays. These
encodings are not interchangeable. Browser export supports pie/donut only.

## Scope and compatibility

Native .gph/PNG uses Stata styles and coordinate spacing. HTML/SVG is a separate
renderer with measured text, plain captions (not SMCL), its own connector style
and common Stata color mappings. It does not reproduce the full Stata scheme.

PASS applies to the current browser's measured text and connector geometry.
Fonts are not embedded; changing viewers, fonts or output size requires checking
again. Very small slices can be subpixel. Impossible layouts fail explicitly
rather than silently hiding labels. Earlier `labelmax()` shortening cannot be
undone by the exporter. Maximum 60 categories; no weights or multiple value
variables. See `help radialchart_export` for checks and failure codes.

Tested locally on macOS; Windows verification is pending. Stata 16 is the
minimum declared version, not certification of every Stata/browser combination.
For a problem report, include the version, `which radialchart` output, OS,
Stata/browser versions, a small reproducible example and the browser report.
Review reports and local paths before sharing; use nonconfidential example data.

## License

Copyright © 2026 choonjoo lee. Licensed under the
[Academic Free License 3.0](LICENSE). See [LICENSE_CODE.txt](LICENSE_CODE.txt)
for scope and attribution.
