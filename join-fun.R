url_prefix <- function() {
  "https://github.com/Reproducible-Science-Curriculum"
}

fetch_lessons <- function(lessons, dest) {
  if (file.exists(dest)) {
    stop("Destination already exists")
  }
  dir.create(dest, FALSE, TRUE)
  system(paste("git init", dest))

  url_prefix <- url_prefix()
  for (i in lessons) {
    system(sprintf("git clone --branch gh-pages %s/%s.git %s/%s", url_prefix, i, dest, i))
    system(sprintf("cd %s/%s; git checkout -b master origin/master", dest, i))
  }
}

copy_gh_pages <- function(lessons, dest) {
  writeLines("www", file.path(dest, ".gitignore"))
  system(sprintf("git clone %s %s/www", dest, dest))
  system(sprintf("cd %s/www; git checkout --orphan gh-pages", dest))
  system(sprintf("cd %s/www; git remote rm origin", dest))
  for (i in lessons) {
    system(sprintf("cd %s/www; git clone --branch gh-pages ../%s", dest, i))
  }  
}

drop_lesson_git <- function(lessons, dest) {
  for (i in lessons) {
    unlink(sprintf("%s/www/%s/.git", dest, i), recursive=TRUE)
    unlink(sprintf("%s/%s/.git", dest, i), recursive=TRUE)
  }
}

merge_tests <- function(lessons, dest) {
  ## Continuous integration
  dat <- do.call("rbind",
                 lapply(file.path(dest, lessons, ".description"), read.dcf))
  depends <- paste(unique(unlist(strsplit(dat[,"Depends"], ",\\s*"))),
                   collapse=", ")
  writeLines(paste("Depends: ", depends),
             file.path(dest, ".description"))
  file.copy("ci/appveyor.yml", dest)
  file.copy("ci/.travis.yml", dest)

  ## Now, write an R file that will run each test.
  library(whisker)
  lessons_str <- paste(sprintf('"%s"', lessons), collapse=", ")
  writeLines(whisker.render(readLines("ci/ci_tests.R.whisker"),
                            list(lessons=lessons_str)),
             file.path(dest, ".ci_tests.R"))
}

combined_setup_root <- function(dest) {
  files <- dir("content/gh-pages", full.names=TRUE)
  file.copy(files, file.path(dest, "www"), recursive=TRUE)

  files <- dir("content/master", full.names=TRUE)
  file.copy(files, file.path(dest), recursive=TRUE)
}

combined_commit <- function(dest) {
  system(sprintf("cd %s/www; git add .; git commit -m 'merge repos'", dest))
  system(sprintf("cd %s; git add .; git commit -m 'merge repos'", dest))
}

combined_push <- function(dest, name) {
  url_prefix <- "git@github.com:Reproducible-Science-Curriculum/"
  url <- paste0(url_prefix, name)
  system(sprintf("cd %s; git remote add origin %s", dest, url))
  system(sprintf("cd %s; git push -f -u origin master", dest))

  system(sprintf("cd %s/www; git remote add origin %s", dest, url))
  system(sprintf("cd %s/www; git push -f -u origin gh-pages", dest))
}

## Explorations for creating github repo:
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
