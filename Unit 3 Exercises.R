#PG Dip Data Science - University of Essex Online
#Visualising Data - Unit 3 Exercises

#Book: R for Data Science. Import, Tidy, Transform, Visualize, and Model Data
#URL: https://r4ds.hadley.nz/data-visualize

#CHAPTER 1: Data Visualisation--------------------------------------------------
#1.1 Introduction---------------------------------------------------------------
#install.packages("tidyverse")
#install.packages("palmerpenguins")
#install.packages("ggthemes")

library(tidyverse)
library(palmerpenguins)
library(ggthemes)

#1.2 First steps----------------------------------------------------------------
penguins
glimpse(penguins)
?penguins

#With ggplot2, you being a plot with the function ggplot(), defining a plot object
#that you then add *layers* to.
ggplot(data = penguins)
#This creates and empty graph.

#The mapping argument is always defined in the aes() function, and the x and y
#arguments of aes() specify which variables to map to the x and y axes.
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
)
#The graph now has more structure but we need to add the penguins to it.

#We need to define geom: the geometrical object that a plot uses to represent
#data.
#geom_point() creates a scatterplot.
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point()
#The relationship between flipper length and body mass appears to be positive.
#ie. As flipper length increases, so does body mass.
#The relationship appears also fairly linear.
#ie. The points are clustered around a line instead of a curve.
#The relationship seems moderately strong.
#ie. There isn't too much scatter around such a line.

#Notice the warning message displayed.
#Two penguins in our dataset have missing body mass and/or flipper length values
#and ggplot2 has no way of representing them on the plot without both of these values.

#Incorporating species into our plot to see if this reveals any additional insights 
#into the apparent relationship between these variables. 
#We will do this by representing species with different colored points.
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point()
#When a categorical variable is mapped to an aesthetic, ggplot2 will automatically 
#assign a unique value of the aesthetic (here a unique color) to each unique level 
#of the variable (each of the three species), a process known as scaling.

#Let's add another layer: a smooth curve displaying the relationship.
#We will use geom_smooth() and we will specify that we want to draw the line
#of best fit based on a linear model with method = "lm".
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point() +
  geom_smooth(method = "lm")
#The lines are seperated out for each species. Let's fix that so that the mappings
#are defined at the global level rather than the local level.

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species)) +
  geom_smooth(method = "lm")
#Now let's add shapes to account for colour blindness.

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species, shape = species)) +
  geom_smooth(method = "lm")
#Finally, let's add labels and improve the colour palette to be colourblind safe.

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(aes(color = species, shape = species)) +
  geom_smooth(method = "lm") +
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)", y = "Body mass (g)",
    color = "Species", shape = "Species"
  ) +
  scale_color_colorblind()


#Exercises----------------------------------------------------------------------
#1) How many rows are in penguins? How many columns?
nrow(penguins)
ncol(penguins)
#344 rows, 8 columns



#2) What does the bill_depth_mm variable in the penguins dataframe describe?
#   Read the help for ?penguins to find out.
?penguins
#a number denoting bill depth (millimeters)



#3) Make a scatterplot of bill_depth_mm vs. bill_length_mm. That is, make a
#   scatterplot with bill_depth_mm on the y-axis and bill_length_mm on the
#   x-axis. Describe the relationship between these two variables.
ggplot(
  data = penguins,
  mapping = aes(x = bill_length_mm, y = bill_depth_mm)
) +
  geom_point(aes(color = species))
#The overall relationship between bill length and bill depth is species-dependent
#rather than showing a single, clear trend.
#While each species shows a positive correlation, the species clusters are distinct.
#Across species, there is no strong universal trend-Gentoo penguins have longer, 
#shallower bills, while Adelie penguins have shorter, deeper bills.



#4) What happens if you make a scatterplot of species vs bill_depth_mm?
#   What might be a better choice of geom?
ggplot(
  data = penguins,
  mapping = aes(x = species, y = bill_depth_mm)
) + 
  geom_point()
#The different measurements for bill depth are plotted for each type of species
#independently. This is because species is a categorical variable.
#A better choice would be geom_boxplot as this would show the min, max, upper and
#lower quartile, as well as the median and any outliers.
#This helps visualise the distribution of bill_depth_mm for each species.
ggplot(
  data = penguins,
  mapping = aes(x = species, y = bill_depth_mm)
) + 
  geom_boxplot()



#5) Why does the following give an error and how would you fix it?
# ggplot(data = penguins) + 
# geom_point()

#geom_point() needs aesthetic mappings (aes()) for x and y variables, but none were provided.
#FIX:
ggplot(data = penguins, 
       mapping = aes(x = bill_length_mm, y = bill_depth_mm)
) +
  geom_point()



#6) What does the na.rm argument do in geom_point()? What is the default value of the argument?
#   Create a scatterplot where you successfully use the arguemnt set to TRUE.

#na.rm = TRUE removes missing values before plotting.
#The default is FALSE, which may generate warnings about missing data.

ggplot(data = penguins, 
       mapping = aes(x = bill_length_mm, y = bill_depth_mm)) +
  geom_point(na.rm = TRUE)



#7) Add the following caption to the plot you made in the previous exercise:
#   "Data come from the palmerpenguins package". Hint: Take a look at the
#   documentation for labs().

?labs

ggplot(data = penguins, aes(x = bill_length_mm, y = bill_depth_mm)) +
  geom_point(na.rm = TRUE) +
  labs(title = "Scatterplot of Bill Depth vs. Bill Length",
       caption = "Data come from the palmerpenguins package.")



#8) Recreate the following visualisation. What aesthetic should bill_depth_mm be
#   mapped to? And should it be mapped at the global level or at the geom level?
ggplot(data = penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = bill_depth_mm)) +  # Map bill depth to color
  geom_smooth(se = TRUE) +   # Smooth curve WITH confidence interval
  labs(
    title = "Body Mass vs. Flipper Length",
    subtitle = "Colored by Bill Depth with Confidence Interval",
    x = "Flipper Length (mm)",
    y = "Body Mass (g)",
    color = "Bill Depth (mm)"
  )

#bill_depth_mm should be mapped to color at the geom level inside aes().



#9) Run this code in your head and predict what the output will look like.
#   Then, run the code in R and check your predictions.

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = island)
) +
  geom_point() +
  geom_smooth(se = FALSE)

#geom_point() colors points by island.
#geom_smooth() fits a line to the relationship between flipper_length_mm and body_mass_g without shading (se = FALSE).



#10) Will these two graphs look different? Why/why not?
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point() +
  geom_smooth()

ggplot() +
  geom_point(
    data = penguins,
    mapping = aes(x = flipper_length_mm, y = body_mass_g)
  ) +
  geom_smooth(
    data = penguins,
    mapping = aes(x = flipper_length_mm, y = body_mass_g)
  )

#Both plots will look the same.
#The first sets aesthetics globally (mapping = aes(...) inside ggplot()).
#The second assigns mappings separately inside geom_point() and geom_smooth(), 
#but the result is identical.



#1.3 ggplot2 calls--------------------------------------------------------------

#We will write code more concisely:
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) + 
  geom_point()

#Pipe operator %>% (new version of pipe operator is |> )
penguins %>% 
  ggplot(aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(na.rm = TRUE)



#1.4 Visualising distributions--------------------------------------------------

#CATEGORICAL VARIABLE
#To examine the distribution of a categorical variable, you can use a bar chart. 
ggplot(penguins, aes(x = species)) +
  geom_bar()

#It is often preferable to reorder the bars based on their frequencies.
#Doing so requires transforming the variable to a factor.
ggplot(penguins, aes(x = fct_infreq(species))) +
  geom_bar()



#NUMERICAL VARIABLE
#Numerical variables can be continuous or discrete.
#One commonly used visualisation for distributions of continuous variables is a histogram.
ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 200)
#A histogram divides the x-axis into equally spaced bins and then uses the height 
#of a bar to display the number of observations that fall in each bin. 

#You should always explore a variety of binwidths when working with histograms, 
#as different binwidths can reveal different patterns. 

#binwidth = 20
ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 20)
#Binwidth of 20 is too narrow, resulting in too many bars, making it difficult to 
#determine the shape of the distribution.


#binwidth = 2000
ggplot(penguins, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 2000)
#Similarly, a binwidth of 2,000 is too high, resulting in all data being binned into 
#only three bars, and also making it difficult to determine the shape of the distribution.


#An alternative visualisation for distributions of numerical variables is a density plot. 
#A density plot is a smoothed-out version of a histogram and a practical alternative, 
#particularly for continuous data that comes from an underlying smooth distribution.
ggplot(penguins, aes(x = body_mass_g)) +
  geom_density()



#Exercises----------------------------------------------------------------------
#1) Make a bar plot of species of penguins, where you assign species to the y aesthetic. 
#   How is this plot different?
ggplot(penguins, aes(y = species)) +
  geom_bar()
#The bars are horizontal instead of vertical because species is mapped to the y-axis instead of the x-axis.
#This format can be easier to read if there are long category names or many categories.



#2) How are the following two plots different? Which aesthetic, color or fill, 
#   is more useful for changing the color of bars?
ggplot(penguins, aes(x = species)) +
  geom_bar(color = "red")

ggplot(penguins, aes(x = species)) +
  geom_bar(fill = "red")

#Color only changes the outline of the bars, keeping the inside unfilled.
#Fill changes the entire inside of the bars.
#fill is more useful for coloring bars because it changes the inside color.
#color is mainly useful for adding outlines around bars.



#3) What does the bins argument in geom_histogram() do?
#The bins argument controls how many bins (bars) appear in the histogram.
#More bins = more detailed visualization, but too many bins can be noisy.
#Fewer bins = more general trends, but too few bins may oversimplify data.



#4) Make a histogram of the carat variable in the diamonds dataset that is available 
#when you load the tidyverse package. Experiment with different binwidths. 
#What binwidth reveals the most interesting patterns?
ggplot(diamonds, aes(x = carat)) +
  geom_histogram(binwidth = 0.1)  # Experiment with different values
#binwidth = 0.1 → Shows interesting peaks at common carat sizes (e.g., 0.5, 1.0, 1.5 carats).
#binwidth = 0.5 → General trends are clearer but some details are lost.
#binwidth = 0.01 → Very granular; can show small patterns but may be too noisy.
#A good balance is often around 0.1 or 0.2, as it reveals interesting groupings at specific carat sizes.



#1.5 Visualising relationships--------------------------------------------------
ggplot(penguins, aes(x = species, y = body_mass_g)) +
  geom_boxplot()


ggplot(penguins, aes(x = body_mass_g, color = species)) +
  geom_density(linewidth = 0.75)


ggplot(penguins, aes(x = body_mass_g, color = species, fill = species)) +
  geom_density(alpha = 0.5)
#The alpha aesthetic adds transparency to the filled density curves.
#0 is completely transparent, and 1 is completely opaque.



#TWO CATEGORICAL VARIABLES
#We can use stacked bar plots to visualize the relationship between 
#two categorical variables. 
ggplot(penguins, aes(x = island, fill = species)) +
  geom_bar()
#This plot shows the frequencies of each species of penguins on each island. 
#The plot of frequencies shows that there are equal numbers of Adelies on each island. 
#But we don’t have a good sense of the percentage balance within each island.


ggplot(penguins, aes(x = island, fill = species)) +
  geom_bar(position = "fill")
#This plot is more useful for comparing species distributions across islands since 
#it’s not affected by the unequal numbers of penguins across the islands. Using this 
#plot we can see that Gentoo penguins all live on Biscoe island and make up roughly 
#75% of the penguins on that island, Chinstrap all live on Dream island and make up 
#roughly 50% of the penguins on that island, and Adelie live on all three islands and 
#make up all of the penguins on Torgersen.



#TWO NUMERICAL VARIABLES
#So far you’ve learned about scatterplots (created with geom_point()) and 
#smooth curves (created with geom_smooth()) for visualising the relationship between 
#two numerical variables. A scatterplot is probably the most commonly used plot 
#for visualising the relationship between two numerical variables.

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point()




#THREE OR MORE VARIABLES
#We can incorporate more variables into a plot by mapping them to additional aesthetics.

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species, shape = island))
#However adding too many aesthetic mappings to a plot makes it cluttered and difficult to make sense of.

#Another way, which is particularly useful for categorical variables, is to split your plot into facets, 
#subplots that each display one subset of the data.
#The first argument of facet_wrap() is a formula, which you create with ~ followed by a variable name. 
#The variable that you pass to facet_wrap() should be categorical.

ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species, shape = species)) +
  facet_wrap(~island)



#Exercises----------------------------------------------------------------------
#1) The mpg data frame that is bundled with the ggplot2 package contains 234 observations
#collected by the US Environmental Protection Agency on 38 car models. Which variables
#in mpg are categorical? Which variables are numerical? 
#(Hint: Type ?mpg to read the documentation for the dataset.) 
#How can you see this information when you run mpg?

str(mpg)
?mpg

#Categorical Variables (Factors)
#manufacturer
#model
#trans (transmission)
#drv (drive type: 4, f, r)
#fl (fuel type)
#class (type of car)

#Numerical Variables
#displ (engine displacement)
#year
#cyl (number of cylinders)
#cty (city miles per gallon)
#hwy (highway miles per gallon)


#2) Make a scatterplot of hwy vs. displ using the mpg data frame. 
#Next, map a third, numerical variable to color, then size, then both color and size, 
#then shape. How do these aesthetics behave differently for categorical vs. numerical variables?

#Scatterplot of hwy vs displ
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point()

#Adding a Third Numerical Variable
#a) Mapped to color
ggplot(mpg, aes(x = displ, y = hwy, color = cty)) +
  geom_point()
#color shows a gradient from low to high values.

#b) Mapped to size
ggplot(mpg, aes(x = displ, y = hwy, size = cty)) +
  geom_point()
#Larger points indicate higher cty values.

#c) Mapped to color and size
ggplot(mpg, aes(x = displ, y = hwy, color = cty, size = cty)) +
  geom_point()
#Combines color gradient with size scaling.

#d) Mapped to shape
ggplot(mpg, aes(x = displ, y = hwy, shape = factor(cyl))) +
  geom_point()
#shape works only for categorical variables, so cyl is converted to a factor.


#color & size: Work well for numerical variables, creating gradients or scaled sizes.
#shape: Works only for categorical variables.



#3) In the scatterplot of hwy vs. displ, what happens if you map a third variable to linewidth?
ggplot(mpg, aes(x = displ, y = hwy, linewidth = cty)) +
  geom_point()
#This doesn't work well because linewidth is designed for lines (e.g., in geom_line(), geom_path()).



#4) What happens if you map the same variable to multiple aesthetics?
ggplot(mpg, aes(x = displ, y = hwy, color = cty, size = cty)) +
  geom_point()
#The variable cty affects both color and size, reinforcing the pattern.



#5) Make a scatterplot of bill_depth_mm vs. bill_length_mm and color the points 
#by species. What does adding coloring by species reveal about the relationship 
#between these two variables? What about faceting by species?
ggplot(penguins, aes(x = bill_length_mm, y = bill_depth_mm, color = species)) +
  geom_point()
#What does color reveal?
#Different species cluster separately.
#This shows species-specific differences in bill dimensions.

#Faceting by species
ggplot(penguins, aes(x = bill_length_mm, y = bill_depth_mm)) +
  geom_point() +
  facet_wrap(~ species)
#Faceting provides even clearer comparisons by separating species.



#6) Why does the following yield two separate legends? 
#How would you fix it to combine the two legends?

#ggplot(
#  data = penguins,
#  mapping = aes(
#    x = bill_length_mm, y = bill_depth_mm, 
#    color = species, shape = species
#  )
#) +
#  geom_point() +
#  labs(color = "Species")


ggplot(
  data = penguins,
  mapping = aes(
    x = bill_length_mm, y = bill_depth_mm, 
    color = species, shape = species
  )
) +
  geom_point() +
  labs(color = "Species", shape = "Species")
#Fix: Ensure both color and shape share the same label ("Species").
#Now, they appear in one legend instead of two.



#7) Create the two following stacked bar plots. 
#Which question can you answer with the first one? 
#Which question can you answer with the second one?

ggplot(penguins, aes(x = island, fill = species)) +
  geom_bar(position = "fill")
#Proportion of species on each island.
#Example: "Which island has the most even distribution of species?"

ggplot(penguins, aes(x = species, fill = island)) +
  geom_bar(position = "fill")
#Proportion of penguins from each island per species.
#Example: "Which species is most dominant on a specific island?"



#1.6 Saving your plots----------------------------------------------------------
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point()

ggsave(filename = "penguin-plot.png")
#This will save your plot to your working directory.

#NOTE: We recommend that you assemble your final reports using Quarto, 
#a reproducible authoring system that allows you to interleave your code 
#and your prose and automatically include your plots in your write-ups.


#Exercises----------------------------------------------------------------------
#1) Run the following lines of code. 
#Which of the two plots is saved as mpg-plot.png? Why?
ggplot(mpg, aes(x = class)) +
  geom_bar()

ggplot(mpg, aes(x = cty, y = hwy)) +
  geom_point()

ggsave("mpg-plot.png")

#The plot that gets saved is the last one displayed, which is the scatterplot of hwy vs. cty.
#ggsave("mpg-plot.png") automatically saves the last plotted ggplot.
#Since geom_point() is the last executed plot, it gets saved.
#The geom_bar() plot is replaced in memory when the geom_point() plot is run.



#2) What do you need to change in the code above to save the plot as a PDF instead of a PNG? 
#How could you find out what types of image files would work in ggsave()?
ggsave("mpg-plot.pdf")

?ggsave
ggsave("mpg-plot.jpg", dpi = 300)  # Higher resolution



#1.7 Common problems------------------------------------------------------------
#Check the left-hand of your console: if it’s a +, it means that R doesn’t think 
#you’ve typed a complete expression and it’s waiting for you to finish it. 
#In this case, it’s usually easy to start from scratch again by pressing ESCAPE 
#to abort processing the current command.

#One common problem when creating ggplot2 graphics is to put the + in the wrong place: 
#it has to come at the end of the line, not the start. In other words, make sure you 
#haven’t accidentally written code like this:

#ggplot(data = mpg) 
#+ geom_point(mapping = aes(x = displ, y = hwy))




#CHAPTER 2: Workflow: basics----------------------------------------------------

#2.1 Coding basics--------------------------------------------------------------
1 / 200 * 30
#> [1] 0.15
(59 + 73 + 2) / 3
#> [1] 44.66667
sin(pi / 2)
#> [1] 1

x <- 3 * 4
x

primes <- c(2, 3, 5, 7, 11, 13)


primes * 2
#> [1]  4  6 10 14 22 26
primes - 1
#> [1]  1  2  4  6 10 12


#2.2 Comments-------------------------------------------------------------------

# create vector of primes
primes <- c(2, 3, 5, 7, 11, 13)

# multiply primes by 2
primes * 2
#> [1]  4  6 10 14 22 26


#2.3 What’s in a name?----------------------------------------------------------

#i_use_snake_case
#otherPeopleUseCamelCase
#some.people.use.periods
#And_aFew.People_RENOUNCEconvention


#2.4 Calling functions----------------------------------------------------------
seq(from = 1, to = 10)
#>  [1]  1  2  3  4  5  6  7  8  9 10

seq(1, 10)
#>  [1]  1  2  3  4  5  6  7  8  9 10

x <- "hello world"
x


#2.5 Exercises------------------------------------------------------------------
#1) Why does this code not work?
#my_variable <- 10
#my_varıable
#> Error: object 'my_varıable' not found


#The issue is the letter "ı" (dotless 'i') in my_varıable.
#In my_variable, the "i" is a standard ASCII "i", but in my_varıable, it’s a Turkish dotless "ı" (Unicode issue).
#R treats these as different variable names, so my_varıable does not exist.



#2) Tweak each of the following R commands so that they run correctly:
#libary(todyverse)

#ggplot(dTA = mpg) + 
#  geom_point(maping = aes(x = displ y = hwy)) +
#  geom_smooth(method = "lm)


library(tidyverse)  # Correct spelling of 'library' and 'tidyverse'

ggplot(data = mpg) +  # Fix 'dTA' to 'data'
  geom_point(mapping = aes(x = displ, y = hwy)) +  # Fix 'maping' to 'mapping' and add a comma between 'displ' and 'hwy'
  geom_smooth(method = "lm")  # Fix missing closing quote



#3) Press Option + Shift + K / Alt + Shift + K. 
#What happens? How can you get to the same place using the menus?

#This opens the keyboard shortcut reference in RStudio.
#It shows a list of RStudio shortcuts for efficiency.

#Accessing via Menu:
# Go to Tools → Keyboard Shortcuts Help.



#4) Run the following lines of code. 
#Which of the two plots is saved as mpg-plot.png? Why?

#my_bar_plot <- ggplot(mpg, aes(x = class)) +
#  geom_bar()

#my_scatter_plot <- ggplot(mpg, aes(x = cty, y = hwy)) +
#  geom_point()

#ggsave(filename = "mpg-plot.png", plot = my_bar_plot)


#The bar plot (my_bar_plot) is saved because ggsave() explicitly sets plot = my_bar_plot
#In previous exercises, ggsave() saved the last plotted ggplot.
#Here, we explicitly specify plot = my_bar_plot, ensuring the bar plot is saved even though my_scatter_plot was the last plotted.











































