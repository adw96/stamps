# Solution to the exercises of Option B
# Note that these are not the only possible solutions! 
# Developing your own style is strongly encouraged!

# Differentially colour by january abundance
subset_data_frame <- data.frame("January"=abundances$JPA_Jan, 
                                "February"=abundances$JPA_Feb, 
                                "highabundance"=abundances$JPA_Jan > 4000)
names(subset_data_frame)
ggplot(subset_data_frame, aes(x = January, y = February, col = highabundance)) +
  geom_point()

# use a for loop to find which tax was most abundant
tax <- rep(NA, dim(abundances)[1])
for (taxon in 1:dim(abundances)[1]) {
  tax[taxon] <- sum(abundances[taxon, ])
}
rownames(abundances)[which(tax == max(tax))]
# Ralstonia!

# Use a loop to loop through all of the samples, 
# creating a list of the information corresponding to that sample.
# (name, location, month, relative abundance table, abundance table)
all_information <- list()
for (i in 1:dim(covariates)[1]) {
  all_information[[i]] <- list()
  for (j in 1:dim(covariates)[2]) {
    all_information[[i]][[j]] <- covariates[i, j]
  }
  names(all_information[[i]]) <- colnames(covariates)
  all_information[[i]]$abundances <- abundances[, i]
  all_information[[i]]$relative <- relative_abundances[, i]
  all_information[[i]]$taxonomy <- row.names(abundances)
}
names(all_information) <- covariates$SampleName
all_information$LOP_Jan

# Write a function that takes in an OTU table and covariate data
# and the relative abundance table

# TODO