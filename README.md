# FlowSOM MST operator

##### Description

The FlowSOM MST operator represents Minimum Spanning Trees based on a fitted
FlowSOM model.

##### Usage

Input projection|.
---|---
`labels`        | factor, FlowSOM model ID (as output by the `flowsom_operator`)

Input parameters|.
---|---
`plot.width`    | numeric, plot width (pixels, default is 750)
`plot.height`   | numeric, plot height (pixels, default is 750)
`maxNodeSize`   | numeric, maximal node size for scaling
`plot.markers`  | shall individual marker plots be displayed? Default is FALSE.

Output relations|.
---|---
`Image`        | PNG of the plot in the computed tables.

##### Details

The computation is based on the `PlotStars` and `PlotMarker` functions
from the `FlowSOM` R package.
