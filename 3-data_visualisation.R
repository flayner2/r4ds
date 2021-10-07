library(tidyverse)

# CREATING FACETS (useful for categorical data)

# One variable
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_wrap(~ class, nrow = 2) # this creates a facet for class, with 2 rows

# Two variables
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ cyl) # this creates a facet for drv and cyl

# A facet grid without the row facet
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl) # this creates a facet for cyl

# Exercises
# 1. facet on a continuous variable
# A: too many facets bro
ggplot(data = mpg) +
  geom_point(mapping = aes(x = cyl, y = hwy)) +
  facet_wrap(~ displ, nrow = 2) # this creates a facet for cyl

# 2. empty cells
# A: there are no intersections between some classes, so there's no data for
# those cells to show
ggplot(data = mpg) +
  geom_point(mapping = aes(x = drv, y = cyl))

# 3. what the plots do? what "." does?
# A: the "." means "nothing here"
# this first plot creates facets on the x axis by "drv"
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)

# this second one creates facets on the y axis by "cyl"
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)

# 4. facets v colors
# A: faceting is better if your points overlap too much for different classes
# or if you want to understand the behaviour of each class independently. On
# the other hand, colors scale better with more data.
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_wrap(~ class, nrow = 2)

# 5. read the help
# A: nrow and ncol specify the number of rows and columns for the facet. Other
# arguments that control the facets are "as.table" and "dir". For the facet_grid
# question, it is because the number of classes of the chosen variables are the
# determinants for the number of rows and columns.
? facet_wrap

# 6. more values = column. why?
# A: so the individual facets don't get stretched out int the x axis and
# shrinked down in the y axis.
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(cyl ~ drv)

################################################################################

# GEOMETRIC OBJECTS
# Scatter
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy))

# Smooth
ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy))

# Smooth linetypes
ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv))

# Scatter + smooth with colors and linetypes
ggplot(data = mpg,
       mapping = aes(
         x = displ,
         y = hwy,
         color = drv,
         linetype = drv
       )) +
  geom_point() +
  geom_smooth()

# Showing groupings (does not add legends)
ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, group = drv))

# Mapping aesthetics to discrete variables does the same but adds a legend
ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, color = drv),
              show.legend = F)

# Multiple geoms on the same plot
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth()

# Local mappings allow for better control over aesthetics...
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  # Here color will only map to the point geom
  geom_point(mapping = aes(color = class)) +
  geom_smooth()

# ...or even data (like subsetting the data)
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  # Here color will only map to the point geom
  geom_point(mapping = aes(color = class)) +
  # And the line will only show data for the "subcompact" class
  geom_smooth(data = filter(mpg, class == "subcompact"), se = F)

# Exercises
# 1. what geom for linechart? boxplot? histogram? area chart?
# A: geom_line, geom_boxplot, geom_histogram, geom_area
? geom_line
? geom_boxplot
? geom_histogram
? geom_area

# 2. predict the outcome of the code
# A: it will create a plot with layered geoms, a scatterplot (points) and a
# smooth line, where the x axis is "displ" and the y axis is "hwy" for both, and
# color is mapped to the "drv" variable (also for both). Confidence interval
# for the smooth line plot is hidden.
ggplot(data = mpg,
       mapping = aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  geom_smooth(se = FALSE)

# 3. show.legend = FALSE?
# A: it removes the automatic legend added by some aesthetics. If you remove it
# then the legend will be shown. It was probably used earlier to allow the
# layout of the 3 graphs presented so all 3 graphs had the same size.

# 4. se on geom_smooth?
# A: it controls whether the confidence interval for the smooth line should be
# shown or hidden.

# 5. different?
# A: no because when you assign data and map aesthetics on the ggplot function,
# those mappings will be applied globally to all geoms that can display them.
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth()

ggplot() +
  geom_point(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_smooth(data = mpg, mapping = aes(x = displ, y = hwy))

# 6. recreate the graphs
# p1
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth(se = F)

# p2
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth(se = F, mapping = aes(group = drv))

# p3
ggplot(data = mpg,
       mapping = aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  geom_smooth(se = F, mapping = aes(group = drv))

# p4
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(mapping = aes(color = drv)) +
  geom_smooth(se = F)

# p5
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(mapping = aes(color = drv)) +
  geom_smooth(se = F, mapping = aes(linetype = drv))

# p6
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, fill = drv)) +
  geom_point(shape = 21,
             color = "white",
             stroke = 2)

################################################################################

# STATISTICAL TRANSFORMATIONS

# See how the bar chart calculates a new value called "count"
ggplot(data = diamonds) + # "count" is not a variable inside `diamonds`
  geom_bar(mapping = aes(x = cut))

# You can usually interchange geoms with their respective stat
ggplot(data = diamonds) +
  stat_count(mapping = aes(x = cut))

# Changing the default stat of a geom
demo <- tribble(
  ~cut,         ~freq,
  "Fair",       1610,
  "Good",       4906,
  "Very Good",  12082,
  "Premium",    13791,
  "Ideal",      21551
)
ggplot(data = demo) +
  geom_bar(mapping = aes(x = cut, y = freq), stat = "identity")

# Overriding the default mapping for transformed variables to aesthetics
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, y = stat(prop), group = 1))

# Draw more attention to the statistical transformations
ggplot(data = diamonds) +
  stat_summary(
    mapping = aes(x = cut, y = depth),
    fun.min = min,
    fun.max = max,
    fun = median
  )

# Exercises
# 1: geom for stat_summary?
# A: geom_pointrange. Rewriting:
ggplot(data = diamonds) +
  geom_pointrange(
    mapping = aes(x = cut,
                  y = depth),
    stat = "summary",
    fun.min = min,
    fun.max = max,
    fun = median
  )

# 2: what is geom_col? how's it different from geom_bar?
# A: geom_col is a bar plot, similar to geom_bar. The difference is that bar
# computes stat_count to be the y axis (which counts the occurences of each x)
# and geom_col uses the identity stat, which leaves the data as is (so you have)
# to provide the continuous data for the y axis
ggplot(data = diamonds) +
  geom_col(mapping = aes(x = cut, y = price))

# 3: skipped, too boring

# 4: what stat_smooth computes? what paramters control that?
# A: it computes `y`, the predicted value; `ymin`, the lower confidence interval
# around the mean; `ymax`, the upper convidence interval around the mean; and
# se, the standard error. The parameter `se` controls whether to display the
# confidence interval or not, `level` controls the level of confidence, `ymax`
# and `ymin` do something I don't quite understand and `formula` controls the
# smoothing function, which in turn probably influences the computed values.
?stat_smooth

# 5: what is the problem with those 2? (has to deal with group = 1)
# A: `group = 1` probably means that the sum of the proportions of all groups
# must amount to 1. These two plots don't have that, so the proportion is
# calculated groupwise, which means every group will have a proportion == 1.
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, y = after_stat(prop)))
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = color, y = after_stat(prop)))

################################################################################

# POSITION ADJUSTMENTS

# Showing cut data by outline color
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, color = cut))

# Showing cut data by fill color
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = cut))

# Automatic stacking with position = "stack"
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = clarity))

# Position "identity" puts each object where it "belongs" in the graph
# Removing the stacking and positioning by identity
# This is not useful for bars since they will be overlapping
# In that case, we have to make them slightly transparent or remove the fill
ggplot(data = diamonds, mapping = aes(x = cut, fill = clarity)) +
  geom_bar(alpha = 1 / 5, position = "identity") # transparent

ggplot(data = diamonds, mapping = aes(x = cut, color = clarity)) +
  geom_bar(fill = NA, position = "identity") # no fill

# Position "fill" stacks but makes sure everything has the same height
# It is useful to compare proportions between groups
ggplot(data = diamonds, mapping = aes(x = cut, fill = clarity)) +
  geom_bar(position = "fill")

# Position "dodge" buts bars alongside each other
# Makes it easier to compare individual values
ggplot(data = diamonds, mapping = aes(x = cut, fill = clarity)) +
  geom_bar(position = "dodge")

# Position "jitter" adds a little bit of noise to the position of each object
# It isn't useful for bars but very useful for points like scatterplots
# Because there can be a lot of overlapping for point plots
# With a little noise, you can see basically every data point with less overlap
# Theres a shorthand for this: geom_jitter
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy), position = "jitter")

?geom_jitter

# Exercises
# 1: what is the issue with the plot? How can you improve it?
# A: the plot has a lot of overlapping points due to rounding, so it looks like
# there's less data than there actually is. The way to solve this is to add a
# little bit of noise to the plot with position = "jitter", or just change the
# geom to geom_jitter
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_jitter()

# 2: what parameters in geom_jitter control the ammount of noise?
# A: "width" (horizontal jitter) and "height" (vertical jitter)
?geom_jitter

# 3: compare geom_jitter and geom_count
# A: geom_count has a similar effect to geom_jitter, but through a different
# method and for different data (usually discrete data)
?geom_jitter
?geom_count

# 4: default position for boxplot? visualize mpg with it
# A: it uses "dodge2", which does the same as dodge but also lets you control
# the padding between elements with "padding" and whether the stacking order
# should be reversed with "reverse"
?geom_boxplot

ggplot(data = mpg, mapping = aes(x = class, y = hwy, fill = drv)) +
  geom_boxplot()

################################################################################

# COORDINATE SYSTEMS

# coord_flip() flips the positions of the x and y axes
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot()
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot() +
  coord_flip()

# coord_quickmap() fixes the aspect ratio for maps on spacial data
library(maps)
nz <- map_data("nz")

ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", color = "black")

ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", color = "black") +
  coord_quickmap()

# coord_polar() switches to polar coordinates
bar <- ggplot(data = diamonds) +
  geom_bar(
    mapping = aes(x = cut, fill = cut),
    show.legend = FALSE,
    width = 1
  ) +
  theme(aspect.ratio = 1) +
  labs(x = NULL, y = NULL)

bar + coord_flip() # as a bar chart
bar + coord_polar() # polar coordinates makes it a "pie" chart

# Excercises
# 1. turn a stacked bar chart into pie with coord_polar()
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = clarity)) +
  coord_polar()

# 2. what does labs() do?
# A: it allows the user to change the various plot labels, namely the title,
# subtitle, caption, tag and the axes labels
?labs

# 3. difference between coord_quickmap() and coord_map()?
# A: coord_map() projects a spherical map into a 2d plane withou preserving
# straight lines and may take extra computation to be done, while 
# coord_quickmap() tries to approximate the projectio, preserving straight
# lines and being faster
?coord_quickmap

# 4. what does the plot tell you about cty and hwy? why is coord_fixed()
# important? what does geom_abline() do?
# A: hwy and cty seem to have a positive linear correlation, so when one grows
# the other also does. coord_fixed() fixes the aspect ratio of the chart to
# make so that the visual units between both axes are equivalent. geom_abline()
# plots a reference line to the chart to make it easier to verify the
# correlation between the data
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point() + 
  geom_abline() +
  coord_fixed()
