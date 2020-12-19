library(Human1Parser)
library(RUnit)
library(RCyjs)
library(EnsDb.Hsapiens.v79)
library(later)
#------------------------------------------------------------------------------------------------------------------------
filename <- "../extdata/nons.xml"
filename <- "../extdata/Human-GEM-noNamespaces.xml"
hp <- Human1Parser$new(filename)

#------------------------------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_ctor()
   test_counts()

} # runTests
#------------------------------------------------------------------------------------------------------------------------
test_ctor <- function()
{
   message(sprintf("--- test_ctor"))
   printf("class of object: %s", class(hp))

} # test_ctor
#------------------------------------------------------------------------------------------------------------------------
test_counts <- function()
{
   message(sprintf("--- test_counts"))
   print(hp$getCounts())

} # test_ctor
#------------------------------------------------------------------------------------------------------------------------
if(!interactive())
    runTests()
