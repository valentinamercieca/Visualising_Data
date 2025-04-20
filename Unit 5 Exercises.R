#PG Dip Data Science - University of Essex Online
#Visualising Data - Unit 5 Exercises

#Book: R for Data Science. Import, Tidy, Transform, Visualize, and Model Data (2nd edn)
#URL: https://r4ds.hadley.nz/data-visualize



#CHAPTER 3: Data Transformation-------------------------------------------------


#3.1 Introduction---------------------------------------------------------------
#dplyr package
#dataset on flights that departed from NYC in 2013

library(nycflights13)
library(tidyverse)

flights

flights %>%
  filter(dest == "IAH") %>%
  group_by(year, month, day) %>%
  summarize(
    arr_delay = mean(arr_delay, na.rm = TRUE)
  )


#3.2 Rows-----------------------------------------------------------------------
#filter() allows you to keep rows based on the values of the columns

#all flights that departed more than 120 minutes (two hours) late:
flights %>%
  filter(dep_delay > 120)

#flights that departed on Jan 1
flights %>%
  filter(month == 1 & day == 1)

#flights that departed in Jan or Feb
flights %>%
  filter(month == 1 | month == 2)


#we use %in% when we combine | and ==
#keeps rows where the variable equals one of the values on the right
flights %>%
  filter(month %in% c(1,2))


#to save results
jan1 <- flights %>%
  filter(month == 1 & day == 1)


#changing the order of the columns
flights %>%
  arrange(year, month, day, dep_time)


#use desc() on a column inside of arrange() to re-order the data frame based on that
#column in descending order
flights %>%
  arrange(desc(dep_delay))



#finding all the unique rows in a dataset using distinct()
flights %>%
  distinct() #removing duplicate rows, if any

#finding all unique origin and destination pairs
flights %>%
  distinct(origin, dest)

#alternatively, if you want to keep other columns when filtering for unique rows,
#use the .keep_all = TRUE
flights %>%
  distinct(origin, dest, .keep_all = TRUE)



#It’s not a coincidence that all of these distinct flights are on January 1: 
#distinct() will find the first occurrence of a unique row in the dataset 
#and discard the rest.


#If you want to find the number of occurences instead, swap distinct() for count()
#With the sort = TRUE, you can arrange them in descending order of the number
#of occurences
flights %>%
  count(origin, dest, sort = TRUE)



#Exercises----------------------------------------------------------------------
#1) In a single pipeline for each condition, find all flights that meet the condition:
#a. Had an arrival delay of two or more hours
#b. Flew to Houston (IAH or HOU)
#c. Were operated by United, American, or Delta
#d. Departed in summer (July, August, and September)
#e. Arrived more than two hours late but didn’t leave late
#f. Were delayed by at least an hour, but made up over 30 minutes in flight


#a.
flights %>%
  filter(arr_delay >= 120)

#b.
flights %>%
  filter(dest %in% c("IAH", "HOU"))

#c.
flights %>%
  filter(carrier %in% c("UA", "AA", "DL"))

#d.
flights %>%
  filter(month %in% c(7,8,9))

#e.
flights %>%
  filter(arr_delay > 120, dep_delay <= 0)

#f.
flights %>%
  filter(dep_delay >= 60, dep_delay - arr_delay > 30)




#2) Sort flights to find the flights with the longest departure delays.
#   Find the flights that left earliest in the morning.


flights %>%
  arrange(desc(dep_delay))


flights %>%
  arrange(dep_time)



#3) Sort flights to find the fastest flights.
#   (Hint: Try including a math calculation inside of your function.)

flights %>%
  mutate(speed = distance / air_time) %>%
  arrange(desc(speed))



#4) Was there a flight on every day of 2013?
flights %>%
  group_by(year, month, day) %>%
  summarise(n_flights = n(), .groups = "drop") %>%
  summarise(all_days_covered = n() == 365)



#5) Which flights traveled the farthest distance? Which traveled the least distance?

flights %>%
  arrange(desc(distance)) %>%
  head(1)

flights %>%
  arrange(distance) %>%
  head(1)


#6) Does it matter what order you used filter() and arrange() if you’re using both? 
#   Why/why not? 
#   Think about the results and how much work the functions would have to do.


#Yes, filtering first reduces the dataset before sorting, improving efficiency


#3.3 Columns--------------------------------------------------------------------
#mutate() creates new columns that are derived from the existing columns
#select() changes which columns are present
#rename() changes the names of the columns
#relocate() changes the positions of the columns


flights %>%
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60
  )


flights %>%
  mutate(
  gain = dep_delay - arr_delay,
  speed = distance / air_time * 60,
  .before = 1  #adding the new variables in front instead
)


flights %>%
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60,
    .after = day #adding new variables after day
  )


flights %>%
  mutate(
    gain = dep_delay - arr_delay,
    hours = air_time / 60,
    gain_per_hour = gain / hours,
    .keep = "used" #keeps only variables that are used
  )


#Select columns by name
flights %>%
  select(year, month, day)


#Select all columns between year and day (inclusive)
flights %>%
  select(year:day)


#Select all columns except those from year and day (inclusive)
flights %>%
  select(!year:day)

#Select all columns that are characters
flights %>%
  select(where(is.character))



#There are a number of helper functions you can use within select():
#starts_with("abc"): matches names that begin with “abc”.
#ends_with("xyz"): matches names that end with “xyz”.
#contains("ijk"): matches names that contain “ijk”.
#num_range("x", 1:3): matches x1, x2 and x3.



#renaming variables using select and =
#new name is on the left hand side, old variable on the right hand side
flights %>%
  select(tail_num = tailnum)


#if you want to keep all variable while renaming, use rename instead of select
flights %>%
  rename(tail_num = tailnum)


#If you have a bunch of inconsistently named columns and it would be painful to 
#fix them all by hand, check out janitor::clean_names() which provides some 
#useful automated cleaning.


#By default relocate() moves variables to the front
flights %>%
  relocate(time_hour, air_time)


flights %>%
  relocate(year:dep_time, .after = time_hour)


flights %>%
  relocate(starts_with("arr"), .before = dep_time)



#Exercises----------------------------------------------------------------------
#1) Compare dep_time, sched_dep_time, and dep_delay. 
#   How would you expect those three numbers to be related?
  
#dep_time: The actual departure time of the flight.
#sched_dep_time: The scheduled departure time.
#dep_delay: The difference between actual and scheduled departure times.

#Expected Relationship:
#dep_delay=dep_time−sched_dep_time
#A negative dep_delay means an early departure, while a positive value indicates a delay.

flights %>%
  select(dep_time, sched_dep_time, dep_delay) %>%
  mutate(expected_delay = dep_time - sched_dep_time)



#2) Brainstorm as many ways as possible to select dep_time, dep_delay, arr_time, 
#   and arr_delay from flights.

flights %>%
  select(dep_time, dep_delay, arr_time, arr_delay)

flights %>%
  select(starts_with("dep"), starts_with("arr"))

flights %>%
  select(ends_with("time"), ends_with("delay"))

flights %>%
  select(matches("^(dep|arr)_(time|delay)$"))



#3) What happens if you specify the name of the same variable multiple times 
#   in a select() call?

#R will only return one instance of the column, ignoring duplicates.
flights %>%
  select(dep_time, dep_time, dep_delay)


  
#4) What does the any_of() function do? Why might it be helpful in conjunction 
#   with this vector?
#   variables <- c("year", "month", "day", "dep_delay", "arr_delay")


#any_of() selects variables that exist in the dataset, preventing errors if some variables are missing.
#Helps when selecting variables dynamically.
#Prevents errors when some columns may or may not be present.

variables <- c("year", "month", "day", "dep_delay", "arr_delay", "non_existent")

flights %>%
  select(any_of(variables))  # Won’t throw an error even if "non_existent" is not in flights



#5) Does the result of running the following code surprise you? How do the select 
#   helpers deal with upper and lower case by default? How can you change that default?
#   flights |> select(contains("TIME"))


#By default, contains() is case-sensitive, and flights uses lowercase (dep_time, arr_time)

flights %>%
  select(contains("TIME"))  # Returns nothing

flights %>%
  select(contains("time"))  # Returns matching columns

# To make `contains()` case-insensitive:
flights %>%
  select(contains("TIME", ignore.case = TRUE))


#Note that the above is suppoed to be the answer but in our case, it does return
#the matching columns



#6) Rename air_time to air_time_min to indicate units of measurement and move it 
#   to the beginning of the data frame.

flights %>%
  rename(air_time_min = air_time) %>%
  relocate(air_time_min)


#7) Why doesn’t the following work, and what does the error mean?
#  flights |> 
#  select(tailnum) |> 
#  arrange(arr_delay)
#> Error in `arrange()`:
#> ℹ In argument: `..1 = arr_delay`.
#> Caused by error:
#> ! object 'arr_delay' not found


#select(tailnum) removes all other columns, including arr_delay
#arrange(arr_delay) then fails because arr_delay no longer exists

#To work, we need to keep arr_delay in the dataset
flights %>%
  select(tailnum, arr_delay) %>%
  arrange(arr_delay)


#The pipe-----------------------------------------------------------------------
flights %>%
  filter(dest == "IAH") %>%
  mutate(speed = distance / air_time * 60) %>%
  select(year:day, dep_time, carrier, flight, speed) %>%
  arrange(desc(speed))



#if we didnt have the pipe, we would have
arrange(
  select(
    mutate(
      filter(
        flights, 
        dest == "IAH"
      ),
      speed = distance / air_time * 60
    ),
    year:day, dep_time, carrier, flight, speed
  ),
  desc(speed)
)

#or
flights1 <- filter(flights, dest == "IAH")
flights2 <- mutate(flights1, speed = distance / air_time * 60)
flights3 <- select(flights2, year:day, dep_time, carrier, flight, speed)
arrange(flights3, desc(speed))



#3.5 Groups---------------------------------------------------------------------
flights %>%
  group_by(month)

flights %>%
  group_by(month) %>%
  summarize(
    avg_delay = mean(dep_delay)
  )


flights %>%
  group_by(month) %>%
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE) #ignores the missing values
  )


flights %>%
  group_by(month) %>%
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    n = n() #Returns the number of rows in each group
  )




#df %>% slice_head(n = 1) takes the first row from each group.
#df %>% slice_tail(n = 1) takes the last row in each group.
#df %>% slice_min(x, n = 1) takes the row with the smallest value of column x.
#df %>% slice_max(x, n = 1) takes the row with the largest value of column x.
#df %>% slice_sample(n = 1) takes one random row.



#You can vary n to select more than one row, or instead of n =, you can use prop = 0.1
#to select (e.g.) 10% of the rows in each group. For example, the following code finds 
#the flights that are most delayed upon arrival at each destination:
flights %>% 
  group_by(dest)  %>%  
  slice_max(arr_delay, n = 1) %>% 
  relocate(dest)

#Note that there are 105 destinations but we get 108 rows here. What’s up? slice_min()
#and slice_max() keep tied values so n = 1 means give us all rows with the highest 
#value. If you want exactly one row per group you can set with_ties = FALSE.


#Grouping by multiple variables
daily <- flights %>%  
  group_by(year, month, day)

#When you summarize a tibble grouped by more than one variable, each summary 
#peels off the last group.
daily_flights <- daily %>% 
  summarize(n = n())

daily_flights <- daily %>% 
  summarize(
    n = n(), 
    .groups = "drop_last"
  )

#Alternatively, change the default behavior by setting a different value, e.g., 
#"drop" to drop all grouping or "keep" to preserve the same groups.


daily %>%
  ungroup()

daily %>%
  ungroup()  %>%
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE), 
    flights = n()
  )


#.by
flights  %>% 
  summarize(
    delay = mean(dep_delay, na.rm = TRUE), 
    n = n(),
    .by = month
  )


flights   %>% 
  summarize(
    delay = mean(dep_delay, na.rm = TRUE), 
    n = n(),
    .by = c(origin, dest)
  )


#Exercises----------------------------------------------------------------------
#1) Which carrier has the worst average delays? Challenge: can you disentangle the 
#effects of bad airports vs. bad carriers? Why/why not? 
#(Hint: think about flights |> group_by(carrier, dest) |> summarize(n()))

#calculating the average departure or arrival delay for each carrier 
flights %>%
  group_by(carrier) %>%
  summarize(avg_delay = mean(arr_delay, na.rm = TRUE)) %>%
  arrange(desc(avg_delay))


#The delays could be due to bad airlines (poor scheduling, mechanical issues).
#They could also be due to bad airports (weather, congestion).
#To investigate, group by both carrier and dest:
flights %>%
  group_by(carrier, dest) %>%
  summarize(avg_delay = mean(arr_delay, na.rm = TRUE), n = n()) %>%
  arrange(desc(avg_delay))


#This is challenging because a carrier may have worse delays at some airports but not others,
#and airports with high congestion or bad weather may affect multiple carriers similarly




#2) Find the flights that are most delayed upon departure from each destination.

flights %>%
  group_by(dest) %>%
  slice_max(order_by = dep_delay, n = 1, with_ties = FALSE)




#3) How do delays vary over the course of the day? Illustrate your answer with a plot.
flights %>%
  group_by(hour) %>%
  summarize(avg_delay = mean(dep_delay, na.rm = TRUE)) %>%
  ggplot(aes(x = hour, y = avg_delay)) +
  geom_line() +
  labs(title = "Average Departure Delay by Hour", x = "Hour", y = "Average Delay (minutes)")

#Early morning flights have the least delay.
#Delays accumulate throughout the day due to congestion and disruptions



#4) What happens if you supply a negative n to slice_min() and friends?

#When using a negative n, it behaves like slice_max()



#5) Explain what count() does in terms of the dplyr verbs you just learned. 
#   What does the sort argument to count() do?

#count() is a shortcut for group_by() + summarize(n = n())
#Adding sort = TRUE orders the results in descending order



#6) Suppose we have the following tiny data frame:
#    df <- tibble(
#    x = 1:5,
#    y = c("a", "b", "a", "a", "b"),
#    z = c("K", "K", "L", "L", "K")
#   )

#a. Write down what you think the output will look like, then check if you were correct,
#   and describe what group_by() does.
#df |>
#  group_by(y)

#Groups the data but does not change how it looks.
#Adds a "grouping structure."




#b. Write down what you think the output will look like, then check if you were correct, 
#and describe what arrange() does. Also, comment on how it’s different
#from the group_by() in part (a).
#df |>
#  arrange(y)

#Arranges rows in order of y (all "a" first, then "b").
#Unlike group_by(), it does not change grouping behavior.




#c. Write down what you think the output will look like, then check if you were correct, 
#and describe what the pipeline does.
#df |>
#  group_by(y) |>
#  summarize(mean_x = mean(x))

#Computes the mean of x within each y group.



#d. Write down what you think the output will look like, then check if you were correct, 
#and describe what the pipeline does. Then, comment on what the message says.
#df |>
#  group_by(y, z) |>
#  summarize(mean_x = mean(x))

#Groups by y and z, then computes mean x within each subgroup
#Since group_by(y, z) creates multiple groups, summarize() keeps one grouping level by default



#e. Write down what you think the output will look like, then check if you were correct, 
#and describe what the pipeline does. How is the output different from the one 
#in part (d)?
#df |>
#  group_by(y, z) |>
#  summarize(mean_x = mean(x), .groups = "drop")

#Removes all grouping, returning a regular tibble




#f. Write down what you think the outputs will look like, then check if you were correct,
#and describe what each pipeline does. How are the outputs of the two pipelines different?
#df |>
#  group_by(y, z) |>
#  summarize(mean_x = mean(x))

#df |>
#  group_by(y, z) |>
#  mutate(mean_x = mean(x))


#The first one returns one row per (y, z) group
#The second one adds a new column mean_x, but keeps all original rows
#summarize() reduces the number of rows
#mutate() keeps all rows and adds a computed column


#3.6 Case study: aggregates and sample size-------------------------------------
#install.packages("Lahman")
batters <- Lahman::Batting %>% 
  group_by(playerID)  %>% 
  summarize(
    performance = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    n = sum(AB, na.rm = TRUE)
  )
batters


batters %>%
  filter(n > 100) %>%
  ggplot(aes(x = n, y = performance)) +
  geom_point(alpha = 1 / 10) + 
  geom_smooth(se = FALSE)

batters  %>% 
  arrange(desc(performance))


#CHAPTER 10: Exploratory data analysis------------------------------------------
#10.1 Introduction--------------------------------------------------------------
#EDA is an iterative cycle
#1. You generate questions about your data
#2. Search for answers by visualising, transforming, and modelling your data
#3. Use what you learn to refine your questions and/or generate new questions

library(tidyverse)


#10.2 Questions-----------------------------------------------------------------
#1. What type of variation occurs within my variables?
#2. What type of covariation occurs between my variables?

#10.3 Variation-----------------------------------------------------------------
#Variation is the tendency of the values of a variable to change from measurement to measurement.

#Exploring the distribution first
ggplot(diamonds, aes(x = carat)) +
  geom_histogram(binwidth = 0.5)


#To turn this information into useful questions, look for anything unexpected:
#Which values are the most common? Why?
#Which values are rare? Why? Does that match your expectations?
#Can you see any unusual patterns? What might explain them?

#Let’s take a look at the distribution of carat for smaller diamonds.
smaller <- diamonds %>%
  filter(carat < 3)

ggplot(smaller, aes(x = carat)) +
  geom_histogram(binwidth = 0.01)

#This histogram suggests several interesting questions:
#Why are there more diamonds at whole carats and common fractions of carats?
#Why are there more diamonds slightly to the right of each peak than there are slightly to the left of each peak?

#Visualizations can also reveal clusters, which suggest that subgroups exist in your data. To understand the subgroups, ask:
#How are the observations within each subgroup similar to each other?
#How are the observations in separate clusters different from each other?
#How can you explain or describe the clusters?
#Why might the appearance of clusters be misleading?
  
#When you have a lot of data, outliers are sometimes difficult to see in a histogram. 
#For example, take the distribution of the y variable from the diamonds dataset. 
#The only evidence of outliers is the unusually wide limits on the x-axis. 
ggplot(diamonds, aes(x = y)) + 
  geom_histogram(binwidth = 0.5)

#To make it easy to see the unusual values, we need to zoom to small values of the y-axis with coord_cartesian():
ggplot(diamonds, aes(x = y)) + 
  geom_histogram(binwidth = 0.5) +
  coord_cartesian(ylim = c(0, 50))

#This allows us to see that there are three unusual values: 0, ~30, and ~60. We pluck them out with dplyr:
unusual <- diamonds %>% 
  filter(y < 3 | y > 20) %>%
  select(price, x, y, z) %>%
  arrange(y)
unusual

#The y variable measures one of the three dimensions of these diamonds, in mm. We 
#know that diamonds can’t have a width of 0mm, so these values must be incorrect. 
#By doing EDA, we have discovered missing data that was coded as 0, which we never 
#would have found by simply searching for NAs. Going forward we might choose to re-code 
#these values as NAs in order to prevent misleading calculations. We might also suspect 
#that measurements of 32mm and 59mm are implausible: those diamonds are over an inch long,
#but don’t cost hundreds of thousands of dollars!



#Exercises----------------------------------------------------------------------

#1) Explore the distribution of each of the x, y, and z variables in diamonds. 
#   What do you learn? Think about a diamond and how you might decide which dimension 
#   is the length, width, and depth.


#Histograms for x, y, and z dimensions
ggplot(diamonds, aes(x)) + geom_histogram(binwidth = 0.1) + ggtitle("Distribution of x")
ggplot(diamonds, aes(y)) + geom_histogram(binwidth = 0.1) + ggtitle("Distribution of y")
ggplot(diamonds, aes(z)) + geom_histogram(binwidth = 0.1) + ggtitle("Distribution of z")

#Summary statistics
summary(diamonds[, c("x", "y", "z")])

#x and y likely represent the length and width.
#z (depth) is much smaller than x and y, as expected.
#There are some zero values, which might be errors.




#2) Explore the distribution of price. Do you discover anything unusual or surprising? 
#   (Hint: Carefully think about the binwidth and make sure you try a wide range of values.)

# Histogram with different binwidths
ggplot(diamonds, aes(price)) + geom_histogram(binwidth = 500) + ggtitle("Price Distribution")

# Zoom in on lower range
ggplot(diamonds, aes(price)) + geom_histogram(binwidth = 100) + coord_cartesian(xlim = c(0, 5000))


#The price distribution is right-skewed, meaning most diamonds are cheaper.
#There may be price gaps or spikes at common pricing levels.
#Choosing an appropriate binwidth is important to avoid misleading conclusions.





#3) How many diamonds are 0.99 carat? How many are 1 carat? What do you think is the 
#   cause of the difference?
  
table(diamonds$carat)

sum(diamonds$carat == 0.99)
sum(diamonds$carat == 1.00)


#More diamonds at 1.00 carat than 0.99 due to price psychology—consumers prefer round numbers, leading to a higher demand for 1.00 carat diamonds.
#Jewelers may cut diamonds to reach this exact weight for better marketability.



#4) Compare and contrast coord_cartesian() vs. xlim() or ylim() when zooming in on a 
#   histogram. What happens if you leave binwidth unset? What happens if you try and 
#   zoom so only half a bar shows?

#Using coord_cartesian (keeps all bins)
ggplot(diamonds, aes(price)) + geom_histogram(binwidth = 100) + coord_cartesian(xlim = c(500, 2000))

#Using xlim (removes data outside limits)
ggplot(diamonds, aes(price)) + geom_histogram(binwidth = 100) + xlim(500, 2000)


#coord_cartesian() zooms in but retains all data points.
#xlim() filters out data outside the range, which can distort bin heights.

#If binwidth is unset and zoom cuts a bar:
#coord_cartesian() still shows partial bars.
#xlim() removes bins entirely, leading to unexpected gaps.




#10.4 Unusual values------------------------------------------------------------

#If you’ve encountered unusual values in your dataset, and simply want to move on to
#the rest of your analysis, you have two options.
#1. Drop the entire row with the strange values:

diamonds2 <- diamonds %>% 
  filter(between(y, 3, 20))
#not recommended since one invalid value doesn’t imply that all the other values 
#for that observation are also invalid
#also, if you have low quality data, by the time that you’ve applied this approach to 
#every variable you might find that you don’t have any data left


#2. Instead, we recommend replacing the unusual values with missing values.
diamonds2 <- diamonds %>%
  mutate(y = if_else(y < 3 | y > 20, NA, y))

ggplot(diamonds2, aes(x = x, y = y)) + 
  geom_point()




#Other times you want to understand what makes observations with missing values 
#different to observations with recorded values. For example, in
#nycflights13::flights1, missing values in the dep_time variable indicate that the 
#flight was cancelled. So you might want to compare the scheduled departure times for
#cancelled and non-cancelled times. You can do this by making a new variable, using
#is.na() to check if dep_time is missing.
nycflights13::flights %>%
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + (sched_min / 60)
  ) %>%
  ggplot(aes(x = sched_dep_time)) + 
  geom_freqpoly(aes(color = cancelled), binwidth = 1/4)

#However this plot isn’t great because there are many more non-cancelled flights than cancelled flights. 
#In the next section we’ll explore some techniques for improving this comparison.


#Exercises----------------------------------------------------------------------
#1) What happens to missing values in a histogram? What happens to missing values
#   in a bar chart? Why is there a difference in how missing values are handled in
#   histograms and bar charts?
  

#Histogram (for continuous data)
#Creating example data with missing values
df <- data.frame(value = c(1, 2, 3, 4, 5, NA, NA, 6, 7, 8))

#Histogram
ggplot(df, aes(value)) + 
  geom_histogram(binwidth = 1) +
  ggtitle("Histogram with Missing Values")

#In a histogram, missing values are ignored because histograms are designed for continuous numerical data.
#The NA values don’t appear as a separate bin.


#Bar Chart (for categorical data)
df2 <- data.frame(category = c("A", "B", "C", "A", "B", NA, NA, "C", "A"))

# Bar chart
ggplot(df2, aes(category)) + 
  geom_bar() +
  ggtitle("Bar Chart with Missing Values")


#In a bar chart, missing values may appear as an empty category or be removed, 
#depending on the settings.
#Bar charts work with discrete data, so NA can be treated as a category.

#Histograms ignore missing values because they require numerical bins.
#Bar charts can count missing values since they represent distinct groups.





#2) What does na.rm = TRUE do in mean() and sum()?
  
#Example data with NA
values <- c(1, 2, 3, NA, 5, 6)

#Mean without na.rm (returns NA)
mean(values)

#Mean with na.rm = TRUE (ignores NAs)
mean(values, na.rm = TRUE)

#Sum without na.rm (returns NA)
sum(values)

#Sum with na.rm = TRUE (ignores NAs)
sum(values, na.rm = TRUE)

#na.rm = TRUE removes missing values before calculation.
#If you don’t use na.rm = TRUE, functions like mean() and sum() return NA if 
#there are missing values.





#3) Recreate the frequency plot of scheduled_dep_time colored by whether the flight
#   was cancelled or not. Also facet by the cancelled variable. Experiment with different
#   values of the scales variable in the faceting function to mitigate the effect of more
#   non-cancelled flights than cancelled flights.

flights %>%
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + (sched_min / 60)
  ) %>% 
  ggplot(aes(x = sched_dep_time)) + 
  geom_freqpoly(aes(color = cancelled), binwidth = 1/4) + 
  facet_wrap(~cancelled, scales = "free_y") +  # Adjust y-scales for better comparison
  labs(x = "Scheduled Departure Time (Decimal Hours)", 
       y = "Count", 
       title = "Frequency of Scheduled Departures by Cancellation Status") +
  theme_minimal()


#10.5 Covariation---------------------------------------------------------------
#If variation describes the behavior within a variable, covariation describes the behavior
#between variables. Covariation is the tendency for the values of two or more variables to
#vary together in a related way. 


#let’s explore how the price of a diamond varies with its quality
ggplot(diamonds, aes(x = price)) + 
  geom_freqpoly(aes(color = cut), binwidth = 500, linewidth = 0.75)

#The default appearance of geom_freqpoly() is not that useful here because the height, 
#determined by the overall count, differs so much across cuts, making it hard to see 
#the differences in the shapes of their distributions.

#To make the comparison easier we need to swap what is displayed on the y-axis. 
#Instead of displaying count, we’ll display the density, which is the count
#standardized so that the area under each frequency polygon is one.

ggplot(diamonds, aes(x = price, y = after_stat(density))) + 
  geom_freqpoly(aes(color = cut), binwidth = 500, linewidth = 0.75)
#we use after_stat to compute density since it is not a variable in the dataset


#A visually simpler plot for exploring this relationship is using side-by-side boxplots.
ggplot(diamonds, aes(x = cut, y = price)) +
  geom_boxplot()
#supports the counter-intuitive finding that better quality diamonds are typically cheaper



#You might be interested to know how highway mileage varies across classes:
ggplot(mpg, aes(x = class, y = hwy)) +
  geom_boxplot()


#To make the trend easier to see, we can reorder 
ggplot(mpg, aes(x = fct_reorder(class, hwy, median), y = hwy)) +
  geom_boxplot()


#If you have long variable names, you can flip 90 degrees
ggplot(mpg, aes(x = hwy, y = fct_reorder(class, hwy, median))) +
  geom_boxplot()



#Exercises----------------------------------------------------------------------
#1) Use what you’ve learned to improve the visualization of the departure times of
#cancelled vs. non-cancelled flights.

#2) Based on EDA, what variable in the diamonds dataset appears to be most 
#important for predicting the price of a diamond? How is that variable correlated
#with cut? Why does the combination of those two relationships lead to lower 
#quality diamonds being more expensive?
  
#3) Instead of exchanging the x and y variables, add coord_flip() as a new
#layer to the vertical boxplot to create a horizontal one. How does this compare
#to exchanging the variables?
  
#4) One problem with boxplots is that they were developed in an era of much smaller
#datasets and tend to display a prohibitively large number of “outlying values”. 
#One approach to remedy this problem is the letter value plot. Install the lvplot
#package, and try using geom_lv() to display the distribution of price vs. cut.
#What do you learn? How do you interpret the plots?
  
#5) Create a visualization of diamond prices vs. a categorical variable from the
#diamonds dataset using geom_violin(), then a faceted geom_histogram(), then a 
#colored geom_freqpoly(), and then a colored geom_density(). Compare and contrast
#the four plots. What are the pros and cons of each method of visualizing the
#distribution of a numerical variable based on the levels of a categorical variable?
  
#6) If you have a small dataset, it’s sometimes useful to use geom_jitter() to avoid 
#overplotting to more easily see the relationship between a continuous and categorical
#variable. The ggbeeswarm package provides a number of methods similar to geom_jitter().
#List them and briefly describe what each one does.

#Continued 10.5-----------------------------------------------------------------

#Two categorical variables
ggplot(diamonds, aes(x = cut, y = color)) +
  geom_count()

diamonds %>% 
  count(color, cut)

diamonds %>% 
  count(color, cut) %>%
  ggplot(aes(x = color, y = cut)) +
  geom_tile(aes(fill = n))


#Exercises----------------------------------------------------------------------
#1) How could you rescale the count dataset above to more clearly show the distribution 
#   of cut within color, or color within cut?
  
#2) What different data insights do you get with a segmented bar chart if color is
#   mapped to the x aesthetic and cut is mapped to the fill aesthetic? Calculate the
#   counts that fall into each of the segments.

#3) Use geom_tile() together with dplyr to explore how average flight departure
#   delays vary by destination and month of year. What makes the plot difficult to read?
#   How could you improve it?

#Continued 10.5-----------------------------------------------------------------
#Two numerical variables

ggplot(smaller, aes(x = carat, y = price)) +
  geom_point()


ggplot(smaller, aes(x = carat, y = price)) + 
  geom_point(alpha = 1 / 100)



ggplot(smaller, aes(x = carat, y = price)) +
  geom_bin2d()

#install.packages("hexbin")
ggplot(smaller, aes(x = carat, y = price)) +
  geom_hex()


ggplot(smaller, aes(x = carat, y = price)) + 
  geom_boxplot(aes(group = cut_width(carat, 0.1)))



#Exercises----------------------------------------------------------------------
#1) Instead of summarizing the conditional distribution with a boxplot, you could use
#a frequency polygon. What do you need to consider when using cut_width() vs. cut_number()?
#How does that impact a visualization of the 2d distribution of carat and price?
  
#2) Visualize the distribution of carat, partitioned by price.

#3) How does the price distribution of very large diamonds compare to small diamonds? 
#Is it as you expect, or does it surprise you?
  
#4) Combine two of the techniques you’ve learned to visualize the combined distribution 
#of cut, carat, and price.

#5) Two dimensional plots reveal outliers that are not visible in one dimensional plots.
#For example, some points in the following plot have an unusual combination of x and y 
#values, which makes the points outliers even though their x and y values appear normal
#when examined separately. Why is a scatterplot a better display than a binned plot for
#this case?

#diamonds |> 
#  filter(x >= 4) |> 
#  ggplot(aes(x = x, y = y)) +
#  geom_point() +
#  coord_cartesian(xlim = c(4, 11), ylim = c(4, 11))

#6) Instead of creating boxes of equal width with cut_width(), we could create boxes that
#contain roughly equal number of points with cut_number(). What are the advantages
#and disadvantages of this approach?
#ggplot(smaller, aes(x = carat, y = price)) + 
#  geom_boxplot(aes(group = cut_number(carat, 20)))


#10.6 Patterns and models-------------------------------------------------------

#If a systematic relationship exists between two variables it will appear as 
#a pattern in the data. If you spot a pattern, ask yourself:
#Could this pattern be due to coincidence (i.e. random chance)?
#How can you describe the relationship implied by the pattern?
#How strong is the relationship implied by the pattern?
#What other variables might affect the relationship?
#Does the relationship change if you look at individual subgroups of the data?


#Patterns in your data provide clues about relationships, i.e., they reveal covariation.
#If you think of variation as a phenomenon that creates uncertainty, covariation is a 
#phenomenon that reduces it. If two variables covary, you can use the values of one 
#variable to make better predictions about the values of the second. If the covariation 
#is due to a causal relationship (a special case), then you can use the value of one 
#variable to control the value of the second.


#The following code fits a model that predicts price from carat and then computes
#the residuals (the difference between the predicted value and the actual value). 
#The residuals give us a view of the price of the diamond, once the effect of carat
#has been removed. Note that instead of using the raw values of price and carat, we
#log transform them first, and fit a model to the log-transformed values. Then, we
#exponentiate the residuals to put them back in the scale of raw prices.

#install.packages("tidymodels")
library(tidymodels)

diamonds <- diamonds %>%
  mutate(
    log_price = log(price),
    log_carat = log(carat)
  )

diamonds_fit <- linear_reg() %>%
  fit(log_price ~ log_carat, data = diamonds)

diamonds_aug <- augment(diamonds_fit, new_data = diamonds) %>%
  mutate(.resid = exp(.resid))

ggplot(diamonds_aug, aes(x = carat, y = .resid)) + 
  geom_point()


#Once you’ve removed the strong relationship between carat and price, 
#you can see what you expect in the relationship between cut and price: 
#relative to their size, better quality diamonds are more expensive.
ggplot(diamonds_aug, aes(x = cut, y = .resid)) + 
  geom_boxplot()




