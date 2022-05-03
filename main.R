library(tercen)
library(tercenApi)
library(dplyr, warn.conflicts = FALSE)
library(base64enc)
library(png)
library(ggplot2)
library(uuid)
library(tim)
library(FlowSOM)

ctx <- tercenCtx()
schema <- find_schema_by_factor_name(ctx, ctx$labels[[1]])

table <- ctx$client$tableSchemaService$select(
  schema$id,
  Map(function(x) x$name, schema$columns),
  offset = 0,
  limit = schema$nRows
)

fsom = lapply(as_tibble(table)[[".base64.serialized.r.model"]], deserialize_from_string)[[1]]

input.par <- list(
  plot.width   = ctx$op.value("plot.width", type = as.double, default = 750),
  plot.height  = ctx$op.value("plot.height", type = as.double, default = 750),
  maxNodeSize  = ctx$op.value("maxNodeSize", type = as.double, default = 1.2),
  plot.markers = ctx$op.value("plot.markers", type = as.logical, default = TRUE)
)

## Make plot
plotFlowSOM <- function(fsom_object, input.par, filename, marker_name = NULL) {
  tmp <- tempfile(fileext = ".png")
  png(tmp, width = input.par$plot.width, height = input.par$plot.height, unit = "px")
  
  if(is.null(marker_name)) {
    p <- PlotStars(fsom = fsom_object, maxNodeSize = input.par$maxNodeSize, backgroundValues = fsom_object$metaclustering)
  } else {
    p <- PlotMarker(fsom = fsom_object, maxNodeSize = input.par$maxNodeSize, marker = marker_name, backgroundValues = fsom_object$metaclustering)
  }
  plot(p)
  dev.off()
  
  checksum <- as.vector(tools::md5sum(tmp))

  print(tmp)
  output_string <- base64enc::base64encode(
    readBin(tmp, "raw", file.info(tmp)[1, "size"]),
    "txt"
  )
  out <- tibble::tibble(
    filename = filename,
    mimetype = "image/png",
    checksum = checksum,
    .content = output_string
  )
  return(out)
}

df_out <- plotFlowSOM(fsom_object = fsom, input.par = input.par, filename = "FlowSOM_Stars.png")

if(input.par$plot.markers) {
  df_markers <- do.call(rbind, lapply(colnames(fsom$map$medianValues), function(marker) {
    plotFlowSOM(fsom_object = fsom, input.par = input.par, filename = paste0(marker, ".png"), marker_name = marker)
  }))
  df_out <- rbind(df_out, df_markers)
}

df_out %>%
  ctx$addNamespace() %>%
  as_relation() %>%
  as_join_operator(list(), list()) %>%
  save_relation(ctx)
