% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generate_pseudo_bulk_data.R
\name{split_subclustering_sce}
\alias{split_subclustering_sce}
\title{split SCE Object with random pooling}
\usage{
split_subclustering_sce(
  sce_object,
  group_by,
  resolution,
  subcluster_ref,
  subcluster_comp
)
}
\arguments{
\item{sce_object}{The SingleCellExperiment object to analyse.}

\item{group_by}{entry in metadata table, based on these 
cluster annotation pseudo bulk is performed}

\item{resolution}{resolution}

\item{subcluster_ref}{cluster to subcluster as areference}

\item{subcluster_comp}{cluster to subcluster for comparison}
}
\value{
returns pseudo bulk generated data
}
\description{
split SCE Object with random pooling
}
