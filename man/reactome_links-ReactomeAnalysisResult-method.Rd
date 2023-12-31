% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analysis_result.R
\name{reactome_links,ReactomeAnalysisResult-method}
\alias{reactome_links,ReactomeAnalysisResult-method}
\title{ReactomeAnalysisResult - reactome_links}
\usage{
\S4method{reactome_links}{ReactomeAnalysisResult}(x, print_result = TRUE, return_result = FALSE)
}
\arguments{
\item{x}{ReactomeAnalysisResult.}

\item{print_result}{If set to \code{FALSE} the links are not printed to the console.}

\item{return_result}{If \code{TRUE} the available visualizations are returned as a list containing
named vectors for every visualization. These vectors' have a \code{url}, \code{name},
and optionally a \code{description} slot.}
}
\value{
If \code{return_result} is set to \code{TRUE}, a vector of the available visualizations.
}
\description{
Displays detailed information about the result visualizations in Reactome.
}
\examples{
# Note: This function only works with a newly created result
# since the visualization links only stay active for 7 days

# load an example result
library(ReactomeGSA.data)
data(griss_melanoma_result)

# get the reactome link - this does only work
# with new results
reactome_links(griss_melanoma_result)
}
\seealso{
Other ReactomeAnalysisResult functions: 
\code{\link{get_result}()},
\code{\link{names,ReactomeAnalysisResult-method}},
\code{\link{open_reactome}()},
\code{\link{pathways}()},
\code{\link{plot_correlations}()},
\code{\link{plot_gsva_heatmap}()},
\code{\link{plot_gsva_pathway}()},
\code{\link{plot_heatmap}()},
\code{\link{plot_volcano}()},
\code{\link{result_types}()}
}
