require(pryr)

# clean up all the memory first

mem_used()
rm(list=ls())
invisible(gc())
mem_used()


dataset1 <- read_csv(\"subn_part1.csv\")
dataset2 <- read_csv(\"lgb_submission_part2.csv\")

sub <- data.table(click_id = ds1$click_id, 
               is_attributed = (ds1$is_attributed + ds2$is_attributed + ds3$is_attributed + ds4$is_attributed)/4) 
fwrite(sub, \"lgb_submission_combined.csv\")
head(sub, 10)

invisible(gc())
mem_used()
# lastly write the final set"

