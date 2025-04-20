#PG Dip Data Science - University of Essex Online
#Visualising Data - Unit 4 Exercises

#Book: R for Data Science. Import, Tidy, Transform, Visualize, and Model Data (2nd edn)
#URL: https://r4ds.hadley.nz/data-visualize


#CHAPTER 7: Data Import---------------------------------------------------------


#7.1 Introduction---------------------------------------------------------------
#We will load flat files in R with the readr package in tidyverse
library(tidyverse)

#7.2 Reading data from a file---------------------------------------------------
#CSV was downloaded from: https://raw.githubusercontent.com/hadley/r4ds/main/data/students.csv

students <- read_csv("C:/Users/valen/Desktop/PG Dip Data Science/Visualising Data/Unit 4/students.csv")
students <- read_csv("https://pos.it/r4ds-students-csv")

students #tibble view

#By default, read_csv() only recognizes empty strings ("") in this dataset as NAs, 
#and we want it to also recognize the character string "N/A".
students <- read_csv("C:/Users/valen/Desktop/PG Dip Data Science/Visualising Data/Unit 4/students.csv", na = c("N/A", ""))
students


#Student ID and Full Name columns are surrounded by backticks. 
#That’s because they contain spaces, breaking R’s usual rules for variable names; 
#they’re non-syntactic names.
students <- students %>%
  rename(student_id = `Student ID`,
         full_name = `Full Name`)
students

#We can also use janitor::clean_names() to use some heuristics to turn them all 
#into snake case at once
#install.packages("janitor")
library(janitor)
students <- students %>%
  janitor::clean_names()
students

#Variable types: meal_plan is categorical. Hence, should be represented as a factor:
students <- students %>%
  janitor::clean_names() %>%
  mutate(meal_plan = factor(meal_plan))
students
unique(students$meal_plan) #meal_plan is set to levels
#Note that the type of variable denoted underneath the variable name has changed
#from character (<chr>) to factor (<fct>)

#Fixing the age column so we say 5 not five
students <- students %>%
  janitor::clean_names() %>%
  mutate(meal_plan = factor(meal_plan),
         age = parse_number(if_else(age == "five", "5", age)))
students


#read_csv() can read text strings that you’ve created and formatted like a CSV file:
read_csv(
  "a,b,c
  1,2,3
  4,5,6"
)
#First line is for column names here. We can change that by skipping lines.
#You can use skip = n to skip the first n lines or use comment = "#" to drop all lines that start with (e.g.) #
read_csv(
  "The first line of metadata
  The second line of metadata
  x,y,z
  1,2,3",
  skip = 2
)


read_csv(
  "# A comment I want to skip
  x,y,z
  1,2,3",
  comment = "#"
)


#If your data does not have column names:
read_csv(
  "1,2,3
  4,5,6",
  col_names = FALSE
)


#You can pass col_names a character vector to be used as column names:
read_csv(
  "1,2,3
  4,5,6",
  col_names = c("x", "y", "z")
)

#NOTES:
#read_csv2() reads semicolon-separated files (ie. ; instead of ,)
#read_tsv() reads tab-delimited files
#read_delim() reads in files with any delimiter, attempting to automatically guess the delimiter if you don’t specify it
#read_fwf() reads fixed-width files. You can specify fields by their widths with fwf_widths() or by their positions with fwf_positions()
#read_table() reads a common variation of fixed-width files where columns are separated by white space
#read_log() reads Apache-style log files

#Exercises----------------------------------------------------------------------

#1) What function would you use to read a file where fields were separated with “|”?
read_delim("file.txt", delim = "|")


#2) Apart from file, skip, and comment, what other arguments do read_csv() and read_tsv() have in common?
?read_csv
?read_tsv

#Here are some key arguments they have in common:
#col_names: Either TRUE (default, assumes the first row is headers), FALSE (no headers), or a character vector to specify column names.
#col_types: Lets you define the data types for each column (e.g., "c" for character, "i" for integer), or NULL to guess automatically.
#na: Specifies what values should be treated as NA (e.g., na = c("", "NA")).
#n_max: Limits the number of rows to read.
#progress: Shows a progress bar if TRUE (default is interactive).
#quote: Defines the quoting character (default is ").

#These overlap because both functions are tailored for delimited files, just with different default separators.



#3) What are the most important arguments to read_fwf()?
#The read_fwf() function reads fixed-width format files, where columns are defined by 
#their character positions rather than separators. Its most important arguments are:
  
#file: The path to the file you’re reading.

#col_positions: Specifies the widths or positions of each column. This is critical, 
#as it tells read_fwf() where each field starts and ends. 
#You can use fwf_widths(), fwf_positions(), or fwf_cols() to define this.

#col_types: Controls the data type of each column (e.g., "c" for character, "n"
#for numeric), or NULL to guess.

#na: Defines what strings represent missing values (e.g., na = c("", "NA")).


#4) Sometimes strings in a CSV file contain commas. To prevent them from causing problems,
#they need to be surrounded by a quoting character, like " or '. 
#By default, read_csv() assumes that the quoting character will be ". 
#To read the following text into a data frame, what argument to read_csv() do you 
#need to specify?

#"x,y\n1,'a,b'"

#You’re dealing with a CSV where the string 'a,b' contains a comma, which could confuse
#read_csv() into splitting it into two fields. By default, read_csv() uses " 
#as the quoting character, but here the string is quoted with '. You need to tell
#read_csv() to use ' as the quoting character by setting the quote argument:

read_csv("x,y\n1,'a,b'", quote = "'")

#This ensures 'a,b' is treated as a single value in the y column, resulting in a
#data frame with two columns (x and y) and one row.


#5) Identify what is wrong with each of the following inline CSV files. 
#What happens when you run the code?

#a. read_csv("a,b\n1,2,3\n4,5,6")
#b. read_csv("a,b,c\n1,2\n1,2,3,4")
#c. read_csv("a,b\n\"1")
#d. read_csv("a,b\n1,2\na,b")
#e. read_csv("a;b\n1;3")


#a. The first row (a,b) implies two columns, but the subsequent rows (1,2,3 and 4,5,6) have three values.
#   read_csv() will raise a warning about a parsing failure due to mismatched column counts.
#   1 goes into column a.
#   2,3 gets concatenated into a single value for column b.
#   4 goes into a.
#   5,6 becomes 56 in b.


#b. The header (a,b,c) defines three columns, but:
#   First data row (1,2) has two values (too few).
#   Second data row (1,2,3,4) has four values (too many).
#   read_csv() will try to fit the data into a three-column tibble (a, b, c):
#   1,2: 1 to a, 2 to b, c gets NA (padding the missing value).
#   1,2,3,4: 1 to a, 2 to b, 34 to c (similar to above question)


#c. The line "1 starts with a quote (") but doesn’t end with one.
#   Even if the quote were closed (e.g., "1"), there’s only one value provided for two columns (a and b).
#   Gives a tibble with 2 columns and 0 rows.


#d. Nothing technically wrong with the syntax.
#   1,2 are numeric and a,b are character. Hence, the column is assumed to be character.
#   Inconsistent data types.


#e. The file uses semicolons (;) instead of commas (,) as separators.
#   read_csv() treats semicolons as part of the data, not delimiters, resulting in a single-column tibble.



#6)Practice referring to non-syntactic names in the following data frame by:
#a. Extracting the variable called 1.
#b. Plotting a scatterplot of 1 vs. 2.
#c. Creating a new column called 3, which is 2 divided by 1.
#d. Renaming the columns to one, two, and three.
annoying <- tibble(
  `1` = 1:10,
  `2` = `1` * 2 + rnorm(length(`1`))
)

annoying

#a.
annoying$`1`

#b.
plot(annoying$`1`, annoying$`2`)
ggplot(annoying, aes(x = `1`, y = `2`)) + 
  geom_point()

#c.
annoying$`3` <- annoying$`2` / annoying$`1`
annoying

#d.
library(dplyr)
annoying <- annoying %>%
  rename(one = `1`, two = `2`, three = `3`)
annoying



#7.3 Controlling column types---------------------------------------------------
read_csv("
  logical,numeric,date,string
  TRUE,1,2021-01-15,abc
  false,4.5,2021-02-15,def
  T,Inf,2021-02-16,ghi
")
#The above is not realistic as in real life, data is messy


simple_csv <- "
  x
  10
  .
  20
  30"
read_csv(simple_csv) #x becomes a character column


#In this very small case above, you can easily see the missing value .
#But if you have thousands of rows with only a few missing values represented by .
#sprinkled among them, it would be impossible to spot all.
#For this reason, one approach is to tell readr that x is a numeric column, and then see where it fails
df <- read_csv(
  simple_csv, 
  col_types = list(x = col_double())
)
problems(df)

read_csv(simple_csv, na = ".")




#NOTE:
#col_logical() and col_double() read logicals and real numbers. 

#col_integer() reads integers. We seldom distinguish integers and doubles in this 
#book because they’re functionally equivalent, but reading integers explicitly 
#can occasionally be useful because they occupy half the memory of doubles.

#col_character() reads strings. 


#col_factor(), col_date(), and col_datetime() create factors, dates, 
#and date-times respectively

#col_number() is a permissive numeric parser that will ignore non-numeric 
#components, and is particularly useful for currencies.

#col_skip() skips a column so it’s not included in the result, which can be useful 
#for speeding up reading the data if you have a large CSV file and you only want 
#to use some of the columns.



#You can override the default column by switching from list() to cols() 
#and specifying .default:
another_csv <- "
x,y,z
1,2,3"

read_csv(
  another_csv, 
  col_types = cols(.default = col_character())
)


#Another useful helper is cols_only() which will read in only the columns you specify:
read_csv(
  another_csv,
  col_types = cols_only(x = col_character()))



#7.4 Reading data from multiple files-------------------------------------------
#Files available from:
#https://raw.githubusercontent.com/hadley/r4ds/main/data/01-sales.csv
#https://raw.githubusercontent.com/hadley/r4ds/main/data/02-sales.csv
#https://raw.githubusercontent.com/hadley/r4ds/main/data/03-sales.csv


sales_files <- c("C:/Users/valen/Desktop/PG Dip Data Science/Visualising Data/Unit 4/01-sales.csv",
                 "C:/Users/valen/Desktop/PG Dip Data Science/Visualising Data/Unit 4/02-sales.csv",
                 "C:/Users/valen/Desktop/PG Dip Data Science/Visualising Data/Unit 4/03-sales.csv")


read_csv(sales_files, id = "file")

#or

sales_files <- c(
  "https://pos.it/r4ds-01-sales",
  "https://pos.it/r4ds-02-sales",
  "https://pos.it/r4ds-03-sales"
)
read_csv(sales_files, id = "file")


#You can use the base list.files() function to find the files for you by matching a pattern in the file names.
sales_files <- list.files("data", pattern = "sales\\.csv$", full.names = TRUE)
sales_files
#> [1] "data/01-sales.csv" "data/02-sales.csv" "data/03-sales.csv"


#7.5 Writing to a file----------------------------------------------------------
write_csv(students, "students.csv")
students

write_csv(students, "students-2.csv")
read_csv("students-2.csv")


#This makes CSVs a little unreliable for caching interim results—you need to recreate the 
#column specification every time you load in. There are two main alternatives:
#1. write_rds() and read_rds() are uniform wrappers around the base functions readRDS() 
#   and saveRDS(). These store data in R’s custom binary format called RDS. 
#   This means that when you reload the object, you are loading the exact same R 
#   object that you stored.
write_rds(students, "students.rds")
read_rds("students.rds")

#2. The arrow package allows you to read and write parquet files, a fast binary 
#   file format that can be shared across programming languages. 
#install.packages("arrow")
library(arrow)
write_parquet(students, "students.parquet")
read_parquet("students.parquet")


#7.6 Data entry-----------------------------------------------------------------
tibble(
  x = c(1, 2, 5), 
  y = c("h", "m", "g"),
  z = c(0.08, 0.83, 0.60)
)


#transposed tibble = tribble
tribble(
  ~x, ~y, ~z,
  1, "h", 0.08,
  2, "m", 0.83,
  5, "g", 0.60
)



#CHAPTER 10: Tibbles (OLD BOOK)-------------------------------------------------
#Book: R for Data Science. Import, Tidy, Transform, Visualize, and Model Data (1st edn)
#URL: https://r4ds.had.co.nz/index.html

#10.1 Introduction--------------------------------------------------------------
vignette("tibble") #To learn more about tibbles

library(tidyverse) #tibble package is part of the core tidyverse

#10.2 Creating tibbles----------------------------------------------------------
#Coercing a data frame to a tibble
as_tibble(iris)


#Creating a new tibble from individual vectors
tibble(
  x = 1:5, 
  y = 1, 
  z = x ^ 2 + y
)


#data.frame() vs tibble()
#tibble never changes the type of the inputs (e.g. it never converts strings to factors!),
#it never changes the names of variables, 
#and it never creates row names.


#It’s possible for a tibble to have column names that are not valid R variable names, 
#aka non-syntactic names
tb <- tibble(
  `:)` = "smile", 
  ` ` = "space",
  `2000` = "number"
)
tb


#10.3 Tibbles vs data.frame-----------------------------------------------------

#Tibbles have a refined print method that shows only the first 10 rows, 
#and all the columns that fit on screen. 
#Also, each column reports its type.
tibble(
  a = lubridate::now() + runif(1e3) * 86400,
  b = lubridate::today() + runif(1e3) * 30,
  c = 1:1e3,
  d = runif(1e3),
  e = sample(letters, 1e3, replace = TRUE)
)


#If you need more output, do the following:
#install.packages("nycflights13")
library(nycflights13)
nycflights13::flights %>% 
  print(n = 10, width = Inf)
#This prints the first 10 rows and all columns

#You can also control the default print behaviour by setting options:
#options(tibble.print_max = n, tibble.print_min = m): if more than n rows, print only m rows. Use options(tibble.print_min = Inf) to always show all rows.
#Use options(tibble.width = Inf) to always print all columns, regardless of the width of the screen.


#A final option is to use RStudio’s built-in data viewer to get a scrollable view 
nycflights13::flights %>% 
  View()



#Subsetting
df <- tibble(
  x = runif(5),
  y = rnorm(5)
)

#Extract by name
df$x
df[["x"]]

#Extract by position
df[[1]]

#Extract using a pipe (you will need to use the special placeholder .)
df %>% .$x
df %>% .[["x"]]


#10.4 Interacting with older code-----------------------------------------------
#Some older functions don’t work with tibbles. If you encounter one of these functions, 
#use as.data.frame() to turn a tibble back to a data.frame:
class(as.data.frame(tb))



#10.5 Exercises-----------------------------------------------------------------
#1) How can you tell if an object is a tibble?
#   (Hint: try printing mtcars, which is a regular data frame).
print(mtcars) #regular data frame
print(as_tibble(mtcars)) #convert to tibble

#Data Frame: Shows all columns and rows (up to console limits), no fancy formatting, 
#just raw output.
#Tibble: Displays a compact summary—first few rows (default 10), column names with types 
#(e.g., <dbl>, <chr>), and a footer noting dimensions and hidden columns if any. 
#It’s cleaner and more informative.


#2) Compare and contrast the following operations on a data.frame and equivalent tibble. 
#   What is different? Why might the default data frame behaviours cause you frustration?
df <- data.frame(abc = 1, xyz = "a")
df$x
df[, "xyz"]
df[, c("abc", "xyz")]


#Trying tibble
tbl <- tibble(abc = 1, xyz = "a")


#Working
df$x #There is no column called x but still returns value for column xyz
tbl$x #NULL
#ie. Data frames allow for partial matching, tibbles do not since they are more strict
#   You can get an unexpected column or nothing - without a clear error

df[, "xyz"] #Extracts xyz column as a vector. Drops to a character vector, not a 1-column data frame.
tbl[, "xyz"] #Returns a 1-column tibble, preserving structure.
#ie. Data frames simplify to vectors (drop dimensions), while tibbles stay as data frames.
#   This data frame behavior can frustrate you when you expect a consistent structure 
#   for downstream operations (e.g., piping in tidyverse).

df[, c("abc", "xyz")] #Returns a data frame with both columns. Since it’s one row, it stays a data frame here.
tbl[, c("abc", "xyz")] #Returns a tibble with both columns, annotated with types.
#ie. Functionally similar, but tibbles add type info and better printing.



#3) If you have the name of a variable stored in an object, e.g. var <- "mpg",
#   how can you extract the reference variable from a tibble?

#Using [[]]
tbl <- as_tibble(mtcars)
var <- "mpg"
tbl[[var]]  # Extracts the mpg column as a vector

#We do not use $ here because $ requires a literal name (tbl$mpg), not a variable.

#Alternatively, we can also use pull() from dplyr
library(dplyr)
pull(tbl, var)  # Same result, tidyverse-style



#4) Practice referring to non-syntactic names in the following data frame by:
#a. Extracting the variable called 1.
#b. Plotting a scatterplot of 1 vs 2.
#c. Creating a new column called 3 which is 2 divided by 1.
#d. Renaming the columns to one, two and three.
annoying <- tibble(
  `1` = 1:10,
  `2` = `1` * 2 + rnorm(length(`1`))
)

#This exercise was done previously in CHAPTER 7: Data Import


#5) What does tibble::enframe() do? When might you use it?
#tibble::enframe() converts a named vector (or list) into a two-column tibble with 
#columns name (the original names) and value (the values).
x <- c(a = 1, b = 2, c = 3)
enframe(x)

#We might use it when we need to turn named results into a tidy data frame
#or to convert a list of key-value pairs into a format compatible with tidyverse tools


#6) What option controls how many additional column names are printed at the footer of a tibble?

#tibble.max_extra_cols
#This controls how many extra column names are shown in the footer when not all columns fit the display width.


#CHAPTER 5: Data tidying--------------------------------------------------------

#5.1 Introduction---------------------------------------------------------------
library(tidyverse)

#5.2 Tidy data------------------------------------------------------------------


#table1
#> # A tibble: 6 × 4
#>   country      year  cases population
#>   <chr>       <dbl>  <dbl>      <dbl>
#> 1 Afghanistan  1999    745   19987071
#> 2 Afghanistan  2000   2666   20595360
#> 3 Brazil       1999  37737  172006362
#> 4 Brazil       2000  80488  174504898
#> 5 China        1999 212258 1272915272
#> 6 China        2000 213766 1280428583



#table2
#> # A tibble: 12 × 4
#>   country      year type           count
#>   <chr>       <dbl> <chr>          <dbl>
#> 1 Afghanistan  1999 cases            745
#> 2 Afghanistan  1999 population  19987071
#> 3 Afghanistan  2000 cases           2666
#> 4 Afghanistan  2000 population  20595360
#> 5 Brazil       1999 cases          37737
#> 6 Brazil       1999 population 172006362
#> # ℹ 6 more rows



#table3
#> # A tibble: 6 × 3
#>   country      year rate             
#>   <chr>       <dbl> <chr>            
#> 1 Afghanistan  1999 745/19987071     
#> 2 Afghanistan  2000 2666/20595360    
#> 3 Brazil       1999 37737/172006362  
#> 4 Brazil       2000 80488/174504898  
#> 5 China        1999 212258/1272915272
#> 6 China        2000 213766/1280428583


#table1 is the easiest to work with because it's tidy


#There are three interrelated rules that make a dataset tidy:
#1. Each variable is a column; each column is a variable.
#2. Each observation is a row; each row is an observation.
#3. Each value is a cell; each cell is a single value.

#Here are a few small examples showing how you might work with table1:
#Compute rate per 10,000
table1.1 <- table1 %>%
  mutate(rate = cases/population * 10000)
table1.1

#Compute total cases per year
table1.2 <- table1 %>%
  group_by(year) %>%
  summarize(total_cases = sum(cases))
table1.2

#Visualise changes over time
ggplot(table1, aes(x = year, y = cases)) +
  geom_line(aes(group = country), color = "grey50") +
  geom_point(aes(color = country, shape = country)) +
  scale_x_continuous(breaks = c(1999, 2000)) #x-axis breaks at 1999 and 2000


#Exercises----------------------------------------------------------------------

#1) For each of the sample tables, describe what each observation and each column represents.
#table1
#Each row is one observation that corresponds to a unique combination of a country and a year.
#country: The name of the country.
#year: The year when the data were recorded.
#cases: The number of tuberculosis cases reported in that country for that year.
#population: The total population of the country in that year.
#table1 is “tidy” because every row is an independent observation and every column contains a single variable.


#table2
#Each row represents a single measurement for a given country and year. 
#In this format, a single country–year observation is split into two rows—one 
#for each type of measurement.
#country: The country name.
#year: The year of the measurement.
#type: A key variable that indicates what the measurement is (either "cases" or "population").
#count: The actual numeric value corresponding to the measurement type (i.e. the number of cases or the size of the population).
# Because the information for one country–year pair is divided over two rows (one for each type), 
#the data aren’t in “tidy” form by the principle that one observation should occupy one row.


#table3
#Like table 1, each row here represents data for one country in one specific year.
#rate: A string representing the ratio of cases to population for that country and year
#     This is not a calculated numeric rate but a character representation of the fraction.
#Although table 3 looks similar to table 1, including a derived variable like “rate” 
#(which can be calculated from cases and population) means that the table mixes raw 
#and computed data. This is sometimes seen as “less tidy” because ideally derived values 
#should be computed from the raw data rather than stored alongside them.



#2) Sketch out the process you’d use to calculate the rate for table2 and table3. 
#You will need to perform four operations:
#a. Extract the number of TB cases per country per year.
#b. Extract the matching population per country per year.
#c. Divide cases by population, and multiply by 10000.
#d. Store back in the appropriate place.


#table2
#Since table2 is long-format, we’ll need to pivot or join the cases and population rows
table2_cases <- table2 %>% filter(type == "cases")
table2_population <- table2 %>% filter(type == "population")

table2_joined <- table2_cases %>%
  select(country, year, cases = count) %>%
  left_join(select(table2_population, country, year, population = count),
            by = c("country", "year")) %>%
  mutate(rate = (cases / population) * 10000)
table2_joined


#table3
table3_split <- table3 %>%
  separate(rate, into = c("cases", "population"), sep = "/", convert = TRUE)
table3_split <- table3_split %>%
  mutate(rate = (cases / population) * 10000)
table3_split



#5.3 Lengthening data-----------------------------------------------------------
#pivot_longer to solve the common class of problems where values have ended up in column names.
billboard


#To tidy this data, we’ll use pivot_longer():
billboard1 <- billboard %>%
  pivot_longer(
    cols = starts_with("wk"), 
    names_to = "week", 
    values_to = "rank"
  )
billboard1

#What happens if a song is in the top 100 for less than 76 weeks?
#Take 2 Pac’s “Baby Don’t Cry”, for example.
#The above output suggests that it was only in the top 100 for 7 weeks,
#and all the remaining weeks are filled in with missing values.
#These NAs don’t really represent unknown observations; they were forced to exist 
#by the structure of the dataset
#We can ask pivot_longer() to get rid of them by setting values_drop_na = TRUE:
billboard2 <- billboard %>%
  pivot_longer(
    cols = starts_with("wk"), 
    names_to = "week", 
    values_to = "rank",
    values_drop_na = TRUE
  )
billboard2


#This data is now tidy, but we could make future computation a bit easier by 
#converting values of week from character strings to numbers
billboard3 <- billboard %>%
  pivot_longer(
    cols = starts_with("wk"), 
    names_to = "week", 
    values_to = "rank",
    values_drop_na = TRUE
  ) %>% 
  mutate(
    week = parse_number(week) #handy function that will extract the first number from a string, ignoring all other text
  )
billboard3


#Now we’re in a good position to visualise how song ranks vary over time:
billboard3 %>%  
  ggplot(aes(x = week, y = rank, group = track)) + 
  geom_line(alpha = 0.25) + 
  scale_y_reverse()




#How does pivoting work?
df <- tribble(
  ~id,  ~bp1, ~bp2,
  "A",  100,  120,
  "B",  140,  115,
  "C",  120,  125
)

df %>%
  pivot_longer(
    cols = bp1:bp2,
    names_to = "measurement",
    values_to = "value"
  )



who2
#To organize these six pieces of information in six separate columns, we use
#pivot_longer() with a vector of column names for names_to and instructors
#for splitting the original variable names into pieces for names_sep as well
#as a column name for values_to:
who2 %>%
  pivot_longer(
    cols = !(country:year),
    names_to = c("diagnosis", "gender", "age"),
    names_sep = "_",
    values_to = "count"
  )





household
#The new challenge in this dataset is that the column names contain the names of 
#two variables (dob, name) and the values of another (child, with values 1 or 2). 
household %>%
  pivot_longer(
    cols = !family, 
    names_to = c(".value", "child"),#.value is not a variable.
#uses the first component of the pivoted column name as a variable name in the output.
    names_sep = "_", 
    values_drop_na = TRUE
  )


#5.4 Widening data--------------------------------------------------------------
#pivot_wider() makes datasets wider by increasing columns and reducing rows and helps 
#when one observation is spread across multiple rows. 

cms_patient_experience

#We can see the complete set of values for measure_cd and measure_title by using distinct():
cms_patient_experience %>%
  distinct(measure_cd, measure_title)

#pivot_wider() has the opposite interface to pivot_longer(): instead of choosing new column names,
#we need to provide the existing columns that define the values (values_from) 
#and the column name (names_from):
cms_patient_experience %>%
  pivot_wider(
    names_from = measure_cd,
    values_from = prf_rate
  )

#The output doesn’t look quite right.
#We also need to tell pivot_wider() which column or columns have values that uniquely 
#identify each row; in this case those are the variables starting with "org":
cms_patient_experience %>%
  pivot_wider(
  id_cols = starts_with("org"),
  names_from = measure_cd,
  values_from = prf_rate
)

#How does pivot_wider() work?
df <- tribble(
  ~id, ~measurement, ~value,
  "A",        "bp1",    100,
  "B",        "bp1",    140,
  "B",        "bp2",    115, 
  "A",        "bp2",    120,
  "A",        "bp3",    105
)
df

df %>%
  pivot_wider(
    names_from = measurement,
    values_from = value
  )

df %>%
  distinct(measurement) %>% 
  pull()


df %>%
  select(-measurement, -value) %>% 
  distinct()


df %>%
  select(-measurement, -value) %>% 
  distinct() %>%
  mutate(x = NA, y = NA, z = NA)



df <- tribble(
  ~id, ~measurement, ~value,
  "A",        "bp1",    100,
  "A",        "bp1",    102,
  "A",        "bp2",    120,
  "B",        "bp1",    140, 
  "B",        "bp2",    115
)

df %>% 
  pivot_wider(
    names_from = measurement,
    values_from = value
  )


df %>%
  group_by(id, measurement)  %>% 
  summarize(n = n(), .groups = "drop")  %>% 
  filter(n > 1)






