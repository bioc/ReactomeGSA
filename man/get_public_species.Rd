% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/public_data.R
\name{get_public_species}
\alias{get_public_species}
\title{get_public_species}
\usage{
get_public_species(reactome_url = NULL)
}
\arguments{
\item{reactome_url}{URL of the Reactome API Server. Overwrites the URL set in the 'reactome_gsa.url' option.
Specific ports can be set using the standard URL specification (for example http://your.service:1234)}
}
\value{
A vector of species strings.
}
\description{
Return the list of found species labels in the
supported public data resources
}
\examples{

# get the available species
available_species <- get_public_species()

# inspect the first 1 - 3 entries
available_species[1:3]
}
