% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analysis_result.R
\name{pathways,ReactomeAnalysisResult-method}
\alias{pathways,ReactomeAnalysisResult-method}
\title{ReactomeAnalysisResult - pathways}
\usage{
\S4method{pathways}{ReactomeAnalysisResult}(x, p = 0.01, order_by = NULL, ...)
}
\arguments{
\item{x}{ReactomeAnalysisResult.}

\item{p}{Minimum p-value to accept a pathway as significantly regulated. Default is 0.01.}

\item{order_by}{Name of the dataset to sort the result list by. By default, the
results are sorted based on the first dataset.}

\item{...}{Additional parameters for specific implementations.}
}
\value{
A \code{data.frame} containing all merged pathways.
}
\description{
Combines and returns the pathways of all analysed datasets.
}
\examples{
# load an example result
library(ReactomeGSA.data)
data(griss_melanoma_result)

# get the combined pathway result
pathway_result <- pathways(griss_melanoma_result)

head(pathway_result)
}
\seealso{
Other ReactomeAnalysisResult functions: 
\code{\link{get_result}()},
\code{\link{names,ReactomeAnalysisResult-method}},
\code{\link{open_reactome}()},
\code{\link{plot_correlations}()},
\code{\link{plot_gsva_heatmap}()},
\code{\link{plot_gsva_pathway}()},
\code{\link{plot_heatmap}()},
\code{\link{plot_volcano}()},
\code{\link{reactome_links}()},
\code{\link{result_types}()}
}
