#' plot_volcano
#'
#' Creates a volcano plot for the pathway analysis result. Every point represents one
#' pathway, the x-axis the log fold-change and the y-axis the adjusted p-value (-log10).
#'
#' This function is only available for GSA-based analysis results.
#'
#' @param x ReactomeAnalysisResult. The analysis result to plot the volcano plot for.
#' @param ... Additional parameters for specific implementations.
#'
#' @return A ggplot2 plot object representing the volcano plot.
#' @export
#' @importFrom ggplot2 ggplot aes geom_point geom_hline labs
#'
#' @family ReactomeAnalysisResult functions
#'
#' @examples
#' # load an example result
#' library(ReactomeGSA.data)
#' data(griss_melanoma_result)
#'
#' # create the volcano plot for the first dataset
#' plot_obj <- plot_volcano(griss_melanoma_result)
#'
#' # display the plot using `print(plot_obj)`
setGeneric("plot_volcano", function(x, ...) standardGeneric("plot_volcano"))

#' ReactomeAnalysisResult - plot_volcano
#'
#' @param dataset The name or index of the dataset to plot (first one by default).
#'
#' @inherit plot_volcano
setMethod("plot_volcano", c("x" = "ReactomeAnalysisResult"), function(x, dataset = 1, ...) {
  # convert numeric dataset indices to the name
  if (is.numeric(dataset)) {
    if (dataset > length(names(x@results))) {
      stop("Error: Dataset index ", dataset, " is out of bounds. Result object only contains ", length(names(x)), " datasets.")
    }

    if (dataset < 1) {
      stop("Error: Index must be 1-based")
    }

    dataset <- names(x)[dataset]
  }

  # make sure the dataset exists
  if (!dataset %in% names(x@results)) {
    stop("Error: Failed to find dataset '", dataset, "' in ReactomeAnalysisResult")
  }

  # make sure the pathways result exists
  if (!"pathways" %in% names(x@results[[dataset]])) {
    stop("Error: No pathway results available for dataset '", dataset, "'")
  }

  # make sure it's a GSA result
  if (!"av_foldchange" %in% colnames(x@results[[dataset]][["pathways"]])) {
    stop("Error: plot_volcano is only available for GSA-based results")
  }

  plot_obj <- ggplot2::ggplot(x@results[[dataset]][["pathways"]], ggplot2::aes(x = av_foldchange, y = -log10(FDR))) +
    ggplot2::geom_point() +
    ggplot2::geom_hline(yintercept = -log10(0.05), color = "#CC333F", linetype = 2) +
    ggplot2::geom_hline(yintercept = -log10(0.01), color = "#00A0B0", linetype = 2) +
    ggplot2::labs(x = "average log2 fold-change", y = "adjusted p-value (-log10)", title = dataset)

  return(plot_obj)
})

# plot_correlations --------------------------------------------------------

#' plot_correlations
#'
#' Plots correlations of the average fold-changes of all pathways between
#' the different datasets. This function is only available to GSA based
#' results (not GSVA ones).
#'
#' @param x ReactomeAnalysisResult. The result object to use as input
#' @param hide_non_sig If set, non-significant pathways are not shown.
#' @return A list of ggplot2 plot objects representing one plot per combination
#' @export
#'
#' @family ReactomeAnalysisResult functions
#'
#' @examples
#' # load an example result
#' library(ReactomeGSA.data)
#' data(griss_melanoma_result)
#'
#' # create the correlation plots
#' plot_objs <- plot_correlations(griss_melanoma_result)
#'
#' # only one plot created for this result as it contains two datasets
#' length(plot_objs)
#'
#' # show the plot using `print(plot_objs[[1]])`
setGeneric("plot_correlations", function(x, hide_non_sig = FALSE) standardGeneric("plot_correlations"))


#' plot_correlations - ReactomeAnalysisResult
#' @inherit plot_correlations
setMethod("plot_correlations", c("x" = "ReactomeAnalysisResult"), function(x, hide_non_sig = FALSE) {
  n_datasets <- length(names(x))

  # only works if the number of datasets > 1
  if (n_datasets < 2) {
    stop("Error: ReactomeAnalysisResult contains less than 2 datasets.")
  }

  pathway_result <- pathways(x)

  # only works if it's a GSA-based result
  if (length(grep("av_foldchange\\.", colnames(pathway_result))) < 1) {
    stop("Error: plot_correlations only applicable to GSA-based results")
  }

  plot_list <- list()

  for (dataset_index_1 in seq(to = n_datasets)) {
    for (dataset_index_2 in seq(from = dataset_index_1+1, to = n_datasets)) {
      # ignore any impossible combinations
      if (dataset_index_2 > n_datasets || dataset_index_1 == dataset_index_2) {
        next
      }

      message("Comparing ", dataset_index_1, " vs ", dataset_index_2)

      # get the dataset's name
      dataset_1 <- names(x)[dataset_index_1]
      dataset_2 <- names(x)[dataset_index_2]

      # get the fold-changes for all pathways
      fc_1 <- get_fc_for_dataset(dataset_1, pathway_result)
      fc_2 <- get_fc_for_dataset(dataset_2, pathway_result)

      # test whether they are significant
      is_sig_1 <- get_is_sig_dataset(dataset_1, pathway_result)
      is_sig_2 <- get_is_sig_dataset(dataset_2, pathway_result)

      # only plot shared pathways
      shared_p <- names(fc_1)[names(fc_1) %in% names(fc_2)]

      # save as a data.frame for ggplot2
      plot_data <- data.frame(
        fc_1 = fc_1[shared_p],
        fc_2 = fc_2[shared_p],
        sig_1 = is_sig_1[shared_p],
        sig_2 = is_sig_2[shared_p],
        comparison = paste0(dataset_1, " vs. ", dataset_2)
      )

      # add significance labels and alpha values
      plot_data$combined_sig <- apply(plot_data, 1, function(y) max(c(y["sig_1"], y["sig_2"])))
      plot_data$combined_sig <- factor(plot_data$combined_sig, levels = c(3, 2, 1), labels = c("non-sig.", "p <= 0.05", "p <= 0.01"))
      plot_data$alpha <- 0.05
      plot_data$alpha[plot_data$combined_sig != "non-sig."] <- 1
      point_colours <- c("#CCCCCC", "#CC333F", "#00A0B0")
      
      # remove non-significant if set
      if (hide_non_sig) {
        plot_data <- plot_data[plot_data$combined_sig != "non-sig.", ]
        point_colours <- c("#CC333F", "#00A0B0")
      }

      # create the plot obj
      plot_obj <- ggplot2::ggplot(plot_data, ggplot2::aes(x = fc_1, y = fc_2, color = combined_sig)) +
        ggplot2::geom_point(ggplot2::aes(alpha = alpha)) +
        ggplot2::scale_color_manual(values = point_colours) +
        ggplot2::geom_hline(yintercept = 0, color = "#666666", linetype = 2) +
        ggplot2::geom_vline(xintercept = 0, color = "#666666", linetype = 2) +
        ggplot2::labs(x = paste0("Av. foldchange ", dataset_1), y = paste0("Av. foldchange ", dataset_2), color = "Lowest significance",
                      title = paste0(dataset_1, " vs. ", dataset_2)) +
        ggplot2::guides(alpha = "none")

      plot_list[[length(plot_list)  + 1]] <- plot_obj
    }
  }

  return(plot_list)
})


#' get_fc_for_dataset
#'
#' Retrieve the fold-changes for all pathways of the defined dataset
#'
#' @param dataset Name of the dataset to retrieve the fold changes for.
#' @param pathway_result The data.frame created by the \code{pathways} function.
#'
#' @return A vector of fold-changes
get_fc_for_dataset <- function(dataset, pathway_result) {
  fc_values <- as.numeric(pathway_result[, paste0("av_foldchange.", dataset)])
  names(fc_values) <- rownames(pathway_result)

  return(fc_values)
}

#' get_is_sig_dataset
#'
#' Determines how significant a pathway is across the datasets. Returns the
#' lowest significance.
#'
#' @param dataset Name of the dataset
#' @param pathway_result data.frame created by the \code{pathways} function
#'
#' @return A vector with 3=non-significant, 2=p<=0.05, 1=p<0.01
get_is_sig_dataset <- function(dataset, pathway_result) {
  fdr_values <- as.numeric(pathway_result[, paste0("FDR.", dataset)])

  is_sig <- rep(3, length(fdr_values))

  is_sig[fdr_values <= 0.05] <- 2
  is_sig[fdr_values <= 0.01] <- 1

  names(is_sig) <- rownames(pathway_result)

  return(is_sig)
}

# plot_heatmap --------------------------------------------------------

#' plot_heatmap
#'
#' Creates a heatmap to show which pathways are up- and down-regulated
#' in different datasets
#'
#' @param x ReactomeAnalysisResult. The result object to use as input
#' 
#' @param fdr numeric. The minimum FDR to consider a pathways as significantly
#'        regulated. (Default 0.01)
#' @param max_pathways numeric. The maximum number of pathways to plot. Pathways
#'        are sorted based on in how many datasets they are significantly regulated.
#'        This has no effect if \code{return_data} is set to \code{TRUE}.
#' @param break_long_names logical. If set, long pathway names are broken into
#'        two lines.
#' @param return_data logical. If set, only the plotting data, but not the plot
#'        object itself is returned. This can be used to create customized plots
#'        that use the same data structure.
#' 
#' @return A ggplot2 plot object representing the heatmap of pathways
#'
#' @family ReactomeAnalysisResult functions
#' @export
#' 
#' @examples
#' # load an example result
#' library(ReactomeGSA.data)
#' data(griss_melanoma_result)
#'
#' # create the heatmap plot
#' plot_obj <- plot_heatmap(griss_melanoma_result)
#'
#' # show the plot
#' print(plot_obj)
setGeneric("plot_heatmap", function(x, fdr = 0.01, max_pathways = 30, break_long_names = TRUE, return_data = FALSE) standardGeneric("plot_heatmap"))

#' plot_heatmap - ReactomeAnalysisResult
#' 
#' @importFrom ggplot2 ggplot aes geom_point geom_hline labs
#' @importFrom dplyr select any_of
#' @importFrom tidyr pivot_longer
#' @inherit plot_heatmap
setMethod("plot_heatmap", c("x" = "ReactomeAnalysisResult"), function(x, fdr = 0.01, max_pathways = 30, break_long_names = TRUE, return_data = FALSE) {
  # get all pathways from the object
  all_pathways <- ReactomeGSA::pathways(x)
  
  # create the plot data
  all_pathways[["n_sig"]] <- 0
  
  for (dataset_name in names(x)) {
    pathway_fdr <- all_pathways[[paste0("FDR.", dataset_name)]]
    direction <- all_pathways[[paste0("Direction.", dataset_name)]]
    
    all_pathways[[dataset_name]] <- paste0(ifelse(pathway_fdr <= fdr, "sig", "non-sig"), " ", direction)
    
    all_pathways[["n_sig"]] <- all_pathways[["n_sig"]] + as.numeric(pathway_fdr <= fdr)
  }
  
  # filter the pathways if set
  if (!return_data) {
    all_pathways <- dplyr::arrange(all_pathways, desc(n_sig))
    all_pathways <- dplyr::slice_head(all_pathways, n = max_pathways)
  }
  
  # limit the data
  plot_data <- dplyr::select(all_pathways, "Name" | "n_sig" | dplyr::any_of(names(x)))
  plot_data <- tidyr::pivot_longer(plot_data, !c("Name", "n_sig"), names_to = "dataset", values_to = "direction")
  plot_data <- dplyr::mutate(plot_data, direction = factor(direction, levels = c("sig Down", "non-sig Down", "non-sig Up", "sig Up")))
  
  # short the names if set
  if (break_long_names) {
    plot_data$Name <- break_names(plot_data$Name)
  }
  
  # return the data if set
  if (return_data) {
    return(plot_data)
  }
  
  # create the plot
  plot_obj <- ggplot2::ggplot(plot_data, ggplot2::aes(x = dataset, y = Name, fill = direction)) +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_brewer(palette = "RdYlBu") +
    ggplot2::labs(x = "Dataset", fill = "Direction")
  
  return(plot_obj)
})

#' break_names
#' 
#' Introduce a line break in the middle of a long name.
#'
#' @param the_names A vector of names
#' @param long_name_limit The limit to define a long name (defautl 46 chars.)
#'
#' @return The list of adapted names
break_names <- function(the_names, long_name_limit = 46) {
  # add a line break to very long names
  is_long_name <- nchar(the_names) > long_name_limit
  
  for (name_index in which(is_long_name)) {
    the_name <- the_names[name_index]
    
    # get the words
    words <- strsplit(the_name, " ")[[1]]
    
    # merge the first half of the words
    middle <- ceiling(length(words) / 2)
    
    first_line <- paste0(words[1:middle], collapse = " ")
    second_line <- paste0(words[(middle+1):length(words)], collapse = " ")
    new_name <- paste0(c(first_line, second_line), collapse = "\n")
    
    # update the name
    the_names[name_index] <- new_name
  }
  
  return(the_names)
}