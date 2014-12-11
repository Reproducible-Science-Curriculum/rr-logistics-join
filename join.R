fetch_lessons_github <- function(lessons, dest) {
  url_prefix <- "https://github.com/Reproducible-Science-Curriculum"
  for (i in lessons) {
    system(sprintf("git clone --branch gh-pages %s/%s.git %s/%s", url_prefix, i, dest, i))
    system(sprintf("cd %s/%s; git checkout -b master origin/master", dest, i))
  }
}

fetch_lessons <- function(lessons, dest) {
  if (file.exists(dest)) {
    stop("Destination already exists")
  }
  dir.create(dest, FALSE, TRUE)
  system(paste("git init", dest))
  fetch_lessons_github(lessons, dest)
}

lessons <- c("rr-logistics", "rr-logistics-2")
dest <- "output"
unlink(dest, recursive=TRUE)
fetch_lessons(lessons, "output")

## Now, build a place for the gh-pages bits
writeLines("www", file.path(dest, ".gitignore"))
system(sprintf("git clone %s %s/www", dest, dest))
system(sprintf("cd %s/www; git checkout --orphan gh-pages", dest))

for (i in lessons) {
  system(sprintf("cd %s/www; git clone --branch gh-pages ../%s", dest, i))
  unlink(sprintf("%s/www/%s/.git", dest, i), recursive=TRUE)
  unlink(sprintf("%s/%s/.git", dest, i), recursive=TRUE)
}

system(sprintf("cd %s/www; git add .; git commit -m 'merge repos'", dest))
system(sprintf("cd %s; git add .; git commit -m 'merge repos'", dest))

## ## Install cscheid/rgithub
## ## devtools::install_github("cscheid/rgithub")
## ## Follow instructions.
## library(github)
## library(httpuv)

## id <- "d1274f47e4c33dccb9f3"
## secret <- "0f82b55b52eea4cb589b4fbcedc6d96c6d8b440f"
## name <- "Reproducible-Science-Curriculum/rr-logistics-combined"
## ctx <- interactive.login(id, secret)
## me <- get.myself(ctx)
## github:::create.repository(name=name, ctx=ctx)

## .api.post.request(ctx, c("gists"), body = content)

url_combined <- "git@github.com:Reproducible-Science-Curriculum/rr-logistics-combined.git"
system(sprintf("cd %s; git remote add origin %s", dest, url_combined))
system(sprintf("cd %s; git push -f -u origin master", dest))

system(sprintf("cd %s/www; git remote rm origin", dest))
system(sprintf("cd %s/www; git remote add origin %s", dest, url_combined))
system(sprintf("cd %s/www; git push -f -u origin gh-pages", dest))
