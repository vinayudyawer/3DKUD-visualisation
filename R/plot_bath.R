#'@title Plot bathymetry with transparency control
#'
#'@description Displays the shaded map in 3D with the `rgl` package. Altered version of the \code{\link{plot_3d}} function to allow adjustment of transparency
#'
#'@param hillshade Hillshade/image to be added to 3D surface map.
#'@param heightmap A two-dimensional matrix, where each entry in the matrix is the elevation at that point. All points are assumed to be evenly spaced.
#'@param zscale Default `1`. The ratio between the x and y spacing (which are assumed to be equal) and the z axis. For example, if the elevation levels are in units
#'of 1 meter and the grid values are separated by 10 meters, `zscale` would be 10. Adjust the zscale down to exaggerate elevation features.
#'@param baseshape Default `rectangle`. Shape of the base. Options are c("rectangle","circle","hex").
#'@param solid Default `TRUE`. If `FALSE`, just the surface is rendered.
#'@param soliddepth Default `auto`, which sets it to the lowest elevation in the matrix minus one unit (scaled by zscale). Depth of the solid base.
#'@param solidcolor Default `grey20`. Base color.
#'@param solidlinecolor Default `grey30`. Base edge line color.
#'@param shadow Default `TRUE`. If `FALSE`, no shadow is rendered.
#'@param shadowdepth Default `auto`, which sets it to `soliddepth - soliddepth/10`. Depth of the shadow layer.
#'@param shadowcolor Default `grey50`. Color of the shadow.
#'@param shadowwidth Default `auto`, which sizes it to 1/10th the smallest dimension of `heightmap`. Width of the shadow in units of the matrix.
#'@param water Default `FALSE`. If `TRUE`, a water layer is rendered.
#'@param waterdepth Default `0`. Water level.
#'@param watercolor Default `lightblue`. Color of the water.
#'@param wateralpha Default `0.5`. Water transparency.
#'@param waterlinecolor Default `NULL`. Color of the lines around the edges of the water layer.
#'@param waterlinealpha Default `1`. Water line tranparency.
#'@param linewidth Default `2`. Width of the edge lines in the scene.
#'@param lineantialias Default `FALSE`. Whether to anti-alias the lines in the scene.
#'@param theta Default `45`. Rotation around z-axis.
#'@param phi Default `45`. Azimuth angle.
#'@param fov Default `0`--isometric. Field-of-view angle.
#'@param zoom Default `1`. Zoom factor.
#'@param background Default `grey10`. Color of the background.
#'@param windowsize Default `c(600,600)`. Width and height of the `rgl` device displaying the plot.
#'@param ... Additional arguments to pass to the `rgl::par3d` function.
#'
#'@import rgl
#'@import rayshader
#'
#'@export plot_bath
#'
#'@examples
#'TBD
#'




plot_bath <- function (hillshade,
                       heightmap,
                       zscale = 1,
                       water = FALSE,
                       waterdepth = 0,
                       watercolor = "lightblue",
                       wateralpha = 0.5,
                       theta = 45,
                       phi = 45,
                       fov = 0,
                       zoom = 1,
                       background = "white",
                       windowsize = c(600, 600),
                       ...) {
  argnameschar = unlist(lapply(as.list(sys.call()), as.character))[-1]
  argnames = as.list(sys.call())
  if (!is.null(attr(heightmap, "rayshader_data"))) {
    if (!("zscale" %in% as.character(names(argnames)))) {
      if (length(argnames) <= 3) {
        zscale = 200
        message(
          "`montereybay` dataset used with no zscale--setting `zscale=200` for a realistic depiction. Lower zscale (i.e. to 50) in `plot_3d` to emphasize vertical features."
        )
      }
      else {
        if (!is.numeric(argnames[[4]]) || !is.null(names(argnames))) {
          if (names(argnames)[4] != "") {
            zscale = 200
            message(
              "`montereybay` dataset used with no zscale--setting `zscale=200` for a realistic depiction. Lower zscale (i.e. to 50) in `plot_3d` to emphasize vertical features."
            )
          }
        }
      }
    }
  }
  if (any(hillshade > 1 || hillshade < 0)) {
    stop("Argument `hillshade` must not contain any entries less than 0 or more than 1")
  }
  flipud = function(x) {
    x[nrow(x):1,]
  }
  if (class(hillshade) == "array") {
    hillshade[, , 1] = flipud(hillshade[, , 1])
    hillshade[, , 2] = flipud(hillshade[, , 2])
    hillshade[, , 3] = flipud(hillshade[, , 3])
  }
  if (class(hillshade) == "matrix") {
    hillshade = hillshade[, ncol(hillshade):1]
  }
  if (is.null(heightmap)) {
    stop(
      "heightmap argument missing--need to input both hillshade and original elevation matrix"
    )
  }

  if (water) {
    if (watercolor == "imhof1") {
      watercolor = "#defcf5"
    }
    else if (watercolor == "imhof2") {
      watercolor = "#337c73"
    }
    else if (watercolor == "imhof3") {
      watercolor = "#4e7982"
    }
    else if (watercolor == "imhof4") {
      watercolor = "#638d99"
    }
    else if (watercolor == "desert") {
      watercolor = "#caf0f7"
    }
    else if (watercolor == "bw") {
      watercolor = "#dddddd"
    }
    else if (watercolor == "unicorn") {
      watercolor = "#ff00ff"
    }
  }
  tempmap = tempfile()
  save_png(hillshade, tempmap)
  rgl.surface(
    1:nrow(heightmap),
    -(1:ncol(heightmap)),
    heightmap[, ncol(heightmap):1] / zscale,
    texture = paste0(tempmap, ".png"),
    lit = FALSE,
    ...
  )
  rgl.bg(color = background)
  rgl.viewpoint(
    zoom = zoom,
    phi = phi,
    theta = theta,
    fov = fov
  )
  par3d(windowRect = c(0, 0, windowsize))
  if (water) {
    triangles3d(
      matrix(
        c(
          nrow(heightmap),
          1,
          nrow(heightmap),
          waterdepth,
          waterdepth,
          waterdepth,
          -ncol(heightmap),-1,
          -1
        ),
        3,
        3
      ),
      color = watercolor,
      alpha = wateralpha,
      depth_mask = TRUE,
      front = "fill",
      back = "fill",
      depth_test = "lequal"
    )
    triangles3d(
      matrix(
        c(
          1,
          1,
          nrow(heightmap),
          waterdepth,
          waterdepth,
          waterdepth,
          -ncol(heightmap),
          -1,
          -ncol(heightmap)
        ),
        3,
        3
      ),
      color = watercolor,
      alpha = wateralpha,
      depth_mask = TRUE,
      front = "fill",
      back = "fill",
      depth_test = "lequal"
    )
  }
}
