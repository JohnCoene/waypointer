#' Waypoints dependencies
#' 
#' Sources waypointer dependencies.
#' 
#' @details Place anywhere in your shiny UI. 
#' 
#' @import shiny
#' 
#' @seealso \code{\link{waypoints}}
#' 
#' @export
use_waypointer <- function() {
	singleton(
		tags$head(
			tags$script("window.wps = [];"),
      tags$script("window.trg = [];"),
      tags$link(href = "animate-assets/animate.min.css", rel = "stylesheet", type = "text/css"),
			tags$script(src = "waypointer-assets/scrolly.min.js"),
			tags$script(src = "waypointer-assets/custom.js")
		)
	)
}

#' Waypoint
#' 
#' A waypoint object to track.
#' 
#' @field up,down Whether waypoint has been passed on the up or down.
#' @field direction Direction in which waypoint is going.
#' 
#' @examples
#' library(shiny)
#' 
#' 
#' ui <- fluidPage(
#' 	use_waypointer(),
#' 	div(
#' 		h1("Scroll down"), 
#' 		style = "min-height:90vh"
#' 	),
#' 	verbatimTextOutput("result"),
#' 	plotOutput("plot"),
#' 	div(style = "min-height:90vh")
#' )
#' 
#' server <- function(input, output, session) {
#' 
#' 	w <- Waypoint$
#' 		new("plot", offset = "20%")$
#' 		start()
#' 
#' 	output$result <- renderPrint({
#' 		w$get_direction()
#' 	})
#' 
#' 	output$plot <- renderPlot({
#' 
#' 		req(w$get_direction())
#' 
#' 		if(w$get_direction() == "down")
#' 			hist(runif(100))
#' 		else
#' 			""
#' 	})
#' 
#' }
#' 
#' if(interactive()) shinyApp(ui, server)
#' @aliases waypointer Waypointer Waypoint
#' @name waypoints
#' @export
Waypoint <- R6::R6Class(
	"Waypoint",
#' @details Initialise
#' 
#' @param id Id of element to use as waypoint.
#' @param animate Whether to animate element when the waypoint is triggered.
#' @param animation Animation to use if \code{animate} is set.
#' @param offset Offset relative to viewport to trigger the waypoint.
#' @param horizontal Set to \code{TRUE} if using horizontally.
#' @param waypoint_id Id of waypoint, useful to get the input value.
#' @param start Whether to automatically start watching the waypoint.
	public = list(
    up = FALSE,
    down = FALSE,
    direction = NULL,
		initialize = function(id, animate = FALSE, animation = "shake", offset = NULL, horizontal = FALSE, waypoint_id = NULL, start = TRUE){

      if(!is.null(waypoint_id)){
        session <- .get_session()
        waypoint_id <- session$ns(waypoint_id)
      }

			.init(self, id, animate, animation, offset, horizontal, waypoint_id)

      if(start)
        self$start()

      invisible(self)

		},
#' @details Start watching the waypoint.
		start = function(){
			
			session <- .get_session()

			opts <- list(
				id = private$.id,
				dom_id = private$.dom_id,
				offset = private$.offset,
        animate = private$.must_animate,
        animation = private$.animation
			)
			session$sendCustomMessage("waypoint-start", opts)
			invisible(self)
		},
#' @details Destroy the waypoint.
		destroy = function(){
			session <- .get_session()
			session$sendCustomMessage("waypoint-destroy", list(id = private$.id))
			invisible(self)
		},
#' @details Enable the waypoint.
		enable = function(){
			session <- .get_session()
			session$sendCustomMessage("waypoint-enable", list(id = private$.id))
			invisible(self)
		},
#' @details Disable the waypoint.
		disable = function(){
			session <- .get_session()
			session$sendCustomMessage("waypoint-disable", list(id = private$.id))
			invisible(self)
		},
#' @details Animate the waypoint.
#' @param animation Animation to use.
		animate = function(animation = NULL){

      opts <- list(dom_id = private$.dom_id, animation = private$.animation)

      if(!is.null(animation))
        opts$animation <- animation

			session <- .get_session()
			session$sendCustomMessage("waypoint-animate", opts)
			invisible(self)
		},
#' @details Get direction in which user is scrolling past the waypoint
		get_direction = function(){
			direction <- .get_callback(private$.id, "direction")
      self$direction <- direction
      return(direction)
		},
#' @details Whether user is scrolling up past the waypoint.
		going_up = function(){
			direction <- .get_callback(private$.id, "direction")

      if(is.null(direction))
        direction <- NULL

      direction <- direction == "up"
      self$up <- direction
      
      return(direction)
		},
#' @details Whether user is scrolling down past the waypoint.
		going_down = function(){
			direction <- .get_callback(private$.id, "direction")

      if(is.null(direction))
        direction <- FALSE

      direction <- direction == "down"
      self$down <- direction
      
      return(direction)
		},
#' @details Whether waypoint has been triggered.
		get_triggered = function(){
      .get_callback(private$.id, "triggered")
		}
	),
	active = list(
		id = function(id){
			if(missing(id))
				stop("missing id")
			else
				private$.id <- id
		},
		dom_id = function(dom_id){
			if(missing(dom_id))
				stop("missing dom_id")
			else
				private$.dom_id <- dom_id
		},
		offset = function(offset){
			if(missing(offset))
				stop("missing offset")
			else
				private$.offset <- offset
		},
		horizontal = function(horizontal){
			if(missing(horizontal))
				stop("missing horizontal")
			else
				private$.horizontal <- horizontal
		},
		must_animate = function(must_animate = FALSE){
			if(!is.logical(must_animate))
				stop("must_animate is not logical")
			else
				private$.must_animate <- must_animate
		},
		animation = function(animation){
			if(missing(animation))
				stop("missing animation")
			else
				private$.animation <- animation
		}
	),
	private = list(
		.id = NULL,
		.dom_id = NULL,
		.offset = 0L,
		.horizontal = FALSE,
    .must_animate = FALSE,
    .animation = "shake"
	)
)
