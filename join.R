source("join-fun.R")
lessons <- c("rr-logistics", "rr-logistics-2")
dest <- "output"
dest_repo <- "rr-logistics-combined.git"

unlink(dest, recursive=TRUE)
fetch_lessons(lessons, dest)

## Now, build a place for the gh-pages bits
copy_gh_pages(lessons, dest)

drop_lesson_git(lessons, dest)

merge_tests(lessons, dest)

combined_setup_root(dest)

## Add to git
combined_commit(dest)

## Create repo on github
##   (currently manual)

## Enable in travis and appveyor
##   (currently manual)

combined_push(dest, dest_repo)
