# Script for graphing LD as an R2 heatmap

# Generate a R2 heatmap
library(vroom)
library(dplyr)
library(ggplot2)
setwd("/path/to/workdir")

#
# Functions
#

# Color gradient of R2 values
color_range <- colorRampPalette(c("dodgerblue4","khaki1","firebrick2"))
my_colors <- color_range(100)


# Return a height value for a triangle
# In the context of the plot, this is the Y coordinate, the height of the SNP given its middle distance between two SNP coordinates
#
#         |find h
#        /\
#     a / |\ b
#      /  h \
#     /___|__\
# snpA    c   snpB
#
# This is an isoceles right triangle, where the distance between SNPs is the hypothenuse (c). You are trying to find the height (h) if the triangle.
# First, calculate the length of one of the sides (a).
# Then, calculate h by creating a second right triangle, where a is the new hypothenuse, with c/2 and h as sides.
snp.height <- function(snp.distance) {
  c <- snp.distance
  a <- sqrt((c**2)/2)
  h <- sqrt(a**2 - ((c/2)**2))
  return(h)
}


#
# Other variables
# 

# Colors for scale
cols=c("darkorange","red3","midnightblue")

# Species to plot
#sp <- 'hybrid'
sp <- 'candei'
#sp <- 'vitellinus'

# Names of chromosomes to plot
chroms <- read.delim('./candei_v1_chrm_list.tsv', header=F)
chroms <- subset(chroms,V2>10E6)
names <- chroms$V1
lens  <- chroms$V2
lens  <- ceiling(lens/1e6)

# Load the big LD table
ld.tbl <- vroom(paste('./data/', sp, '.hap_ld.min_0.1.tsv.gz', sep = ''))

# Convert the basepairs to megabases
ld.tbl$bp.1 <- ld.tbl$POS1/1e6
ld.tbl$bp.2 <- ld.tbl$POS2/1e6
# Calculate the distance between snps
ld.tbl$dist <- (ld.tbl$bp.2 - ld.tbl$bp.1)
ld.tbl$mid  <- (ld.tbl$bp.1 + (ld.tbl$dist/2))
ld.tbl$hgt  <- snp.height(ld.tbl$dist)

#head(ld.tbl)

for (i in 1:length(lens)){

  name <- names[i]
  len  <- lens[i]
  
  # Subset the LD Table to get one chromosome at a time
  ld <- ld.tbl %>% group_by(CHR) %>% filter(CHR == name)

  # Sorts by R^2
  ld <- arrange(ld, `R^2`)

  ### Plotting LD matrix with  ggplot
  
  fig <- ggplot(data = ld, aes(x=mid, y=hgt, color=`R^2`))+ 
    geom_point(alpha = 0.20, size = .1) +
    
    # Set color gradient
    scale_colour_gradientn(colors = my_colors) +
    
    # Add titles
    labs(title=paste(name,sp),
         x='Position (Mbp)',
         y="") +
    
    # Set Themes
    theme_light(base_size=16) +
    theme(panel.grid = element_blank()) +
    theme(axis.text.y = element_blank()) +
    theme(axis.ticks.y = element_blank()) +
    
    # Centralize title
    theme(plot.title=element_text(hjust=0.5))
  
  # Save plot
  f = paste("./plots/",sp,"/LD_",name,"_",sp,".png", sep = "")
  ggsave(f, device = "png", units = "in", plot=fig, width=5.5, height=4)
  
}

