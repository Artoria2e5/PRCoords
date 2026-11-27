file_arg <- grep("^--file=", commandArgs(), value = TRUE)
here <- if (length(file_arg)) dirname(sub("^--file=", "", file_arg)) else "."
source(file.path(here, "R", "prcoords.R"))

args <- commandArgs(trailingOnly = TRUE)
con <- if (length(args)) file(args[1], "r") else file("stdin")
p <- as.matrix(read.table(con, header = FALSE, skip = 1)[, 1:2])
if (length(args)) close(con)

w <- wgs_gcj(p[, 1], p[, 2])
g <- gcj_bd(p[, 1], p[, 2])
b <- wgs_bd(p[, 1], p[, 2])
M <- cbind(p, w, g, b)
fmt <- "%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g"
writeLines(apply(M, 1, function(r) sprintf(fmt, r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8])))
