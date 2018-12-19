#' Add axes to 3D rayshader plot
#'
#' @description Helper function to add axes to a 3D rayshader plot
#'
#' @param ras raster object with bathymetry. This is the raster used to create the hillshade nad heightmap of the rayshader 3D plot
#'   tag detection data, metadata and station information
#' @param zscale scaling factor for the depth, indicating depth exaggeration
#' @param axis.col color of axis and axis text, defaulted to 1
#' @param ... additional arguments for \code{\link{bbox3d}} function
#'
#' @return Adds axes to an existing 3D rayshader plot
#'
#' @importFrom raster coordinates
#' @importFrom raster projectRaster
#' @importFrom raster values
#' @importFrom sp CRS
#' @importFrom rgl bbox3d
#'
#' @examples
#' ## Import detection data
#' data(IMOSdata)
#' data(taginfo)
#' data(statinfo)
#'
#' ## Setup data
#' ATTdata<- setupData(Tag.Detections = tagdata, Tag.Metadata = taginfo, Station.Information = statinfo, source="IMOS")
#'
#' ## Estimate Short-term Center of Activities for all individuals
#' COAdata<- COA(ATTdata)
#'
#'

add_axes <- function(ras, zscale, axis.col = 1, ...){

  ## define axis labs (ll and utm)
  llabx <-
    pretty(range(coordinates(projectRaster(
      ras, crs = CRS("+proj=longlat +datum=WGS84")
    ))[, 1]))
  llaby <-
    pretty(range(coordinates(projectRaster(
      ras, crs = CRS("+proj=longlat +datum=WGS84")
    ))[, 2]))

  labz <- pretty(c(0, min(values(ras))))

  ## estimate positions for labels
  atx <- seq(-ncol(ras), 0, len=length(llabx))
  aty <- seq(0, nrow(ras), len=length(llaby))
  atz <- labz / zscale

  ## add axes
  bbox3d(xat = aty, xlab = llaby,
         yat = atz, ylab = labz,
         zat = atx, zlab = llabx,
         col = axis.col, marklen = 30, ...)
}
