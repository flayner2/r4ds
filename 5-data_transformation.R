library(nycflights13)
library(tidyverse)

# The data is in a tibble, not a data frame.
flights

###################################
## 5.1 Filter rows with filter() ##
###################################

# filter() allows you to subset observations based on their values
# The filtering conditions are expression using the variable names,
# without quotes.
filter(flights, month == 1, day == 1)

# dplyr's functions are never in place by default, but return a new
# data frame.
jan1 <- filter(flights, month == 1, day == 1)

# Wrapping an assignment in parenthesis also prints the result while doing
# the assignment.
(dec25 <- filter(flights, month == 12, day == 25))

# TIP: use near() when comparing floats.
near(sqrt(2) ^ 2, 2)
near(1/49 * 49, 1)

# Comparison operators are allowed.
filter(flights, month  == 11 | month == 12)

# A shorthand to many "or" operations is the %in% operator.
nov_dec <- filter(flights, month %in% c(11, 12))

# To compare with missing values, use is.na().
is.na(NA)

# 5.5.2 Exercises
# 3.
transmute(flights, dep_time, sched_dep_time, dep_delay)
# 4.
mutate(flights, rank = min_rank(flights$dep_delay)) %>% arrange(desc(rank), arr_delay)
# 5.
# A: it returns a new vector the size of the largest one, but added with the
# elements on the shortest one by a sliding window. It also returns a warning
# since the largest range's length is not a multiple of the shortest one's.
1:3 + 1:10
# 6.
?cos
?sin
?tan
?acos
?asin
?atan
?cospi
?sinpi
?tanpi

# 5.6 Grouped summaries with `summarise()` 

# `summarise()` collapses a data frame into a single row.
# `na.rm` removes missing values prior to the computation.
summarise(flights, delay = mean(dep_delay, na.rm = TRUE))

# It's not that useful unless we combine it with `group_by()`
by_day <- group_by(flights, year, month, day)
summarise(by_day, delay = mean(dep_delay, na.rm = TRUE))

# If you don't want to deal with missing values later, you can remove them
# first.
not_cancelled <-
  flights %>% filter(!is.na(dep_delay), !is.na(arr_delay))
not_cancelled %>% group_by(year, month, day) %>% summarise(mean = mean(dep_delay))

# Is always a good idea to include counts when doing aggregations, to make sure
# the number of observations isn't too small.
# For example, this is misleading.
delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay)
  )
ggplot(data = delays, mapping = aes(x = delay)) +
  geom_freqpoly(binwidth = 10)
# If we instead evaluate this...
delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )
# This plot shows a common pattern when plotting averages vs counts: as the
# number of observations increases, the variation in the average decreases. It
# also shows that a very small number of observations can generate misleading
# insights since the variation is larger.
ggplot(data = delays, mapping = aes(x = n, y = delay)) +
  geom_point(alpha = 1/10)
# To correct that, we can filter out the groups with the smallest numbers of
# observations.
delays %>%
  filter(n > 40) %>%
  ggplot(mapping = aes(x = n, y = delay)) +
  geom_point(alpha = 1 / 10)

# We can explore the batting average from the package `Lahman` to show another
# common variation of this pattern.
batting <- as.tibble(Lahman::Batting)

batters <- batting %>% 
  group_by(playerID) %>% 
  summarise(
    ba = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    ab = sum(AB, na.rm = TRUE)
  )

# Variation reduces as sample size (`ab` = at bat) increases, and players with
# more chances to be at bat are usually the most skilled ones, so there is
# a positive association between the mean number of hits (`ba` = batting average) 
# and at bats.
batters %>% 
  filter(ab > 100) %>% 
  ggplot(mapping = aes(x = ab, y = ba)) +
  geom_point() +
  geom_smooth(se = FALSE)

# This shows the effect of small sample sizes over analyses like the one above:
# batters with a very high `ba` like 1 aren't skilled, just lucky.
batters %>% 
  arrange(desc(ba))

# Some other useful summary functions.
# Measures of location: `mean()` and `median()`.
not_cancelled %>%
  group_by(year, month, day) %>%
  summarise(
    avg_delay1 = mean(arr_delay),
    avg_delay2 = mean(arr_delay[arr_delay > 0]) # Average positive delay.
  ) 

# Measures of spread:
?sd
?IQR # This and...
?mad # ...this may be more robust if you have many outliers.
not_cancelled %>%
  group_by(dest) %>% 
  summarise(distance_sd = sd(distance)) %>% 
  arrange(desc(distance_sd))

# Measures of rank:
?min
?quantile
?max
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    first = min(dep_time),
    last = max(dep_time)
  )

# Measures of position:
?first
?nth
?last
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    first_dep = first(dep_time),
    last_dep = last(dep_time)
  )

# Counts:
?n
?n_distinct
sum(!is.na(x)) # Count of non-missing values.
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(carriers = n_distinct(carrier)) %>% 
  arrange(desc(carriers))
# If all you want is a count, `dplyr` provides a helper:
not_cancelled %>% 
  count(dest)
# You can also use a weight variable, for example to "count" the number of
# miles an airplane flew:
not_cancelled %>% 
  count(tailnum, wt = distance)

# Counts and proportions of logical values:
sum(x > 10)
mean(y == 0)
# Since bools are converted to 1s and 0s, we can get the sum and the proportion
# of observations that meet a criterion based on a numerical operation:
# How many flights departed before 5am?
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(n_earyl = sum(dep_time < 500))
# What proportion of flights are delayed by more than one hour?
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(hour_prop = mean(arr_delay > 60))

# When grouping by multiple variables, each summary peels off one level of the
# grouping:
daily <- group_by(flights, year, month, day)
(per_day <- summarise(daily, flights = n()))
(per_month <- summarise(per_day, flights = sum(flights)))
(per_year <- summarise(per_month, flights = sum(flights)))

# If you need to remove grouping, use `ungroup()`:
daily %>% 
  ungroup() %>% # No longer grouped by date.
  summarise(flights = n()) # All flights.

# 5.6.7 Exercises
# 2.
not_cancelled %>% count(dest) # Q1
not_cancelled %>% group_by(dest) %>% summarise(n = n()) # A1
not_cancelled %>% count(tailnum, wt = distance) # Q2
not_cancelled %>% group_by(tailnum) %>% summarise(n = sum(distance)) # A2
# 3.
# A: Because the flights may not have information about their delay time, which
# could also be an indicative of no delay if, for example, in the process of
# data collection, flights without delay were given no information instead of
# a value of 0. The variable `dep_time` should be more informative of cancelled
# flights since flights with no departure time probably didn't depart.
flights %>% filter(is.na(dep_time))
# 4.
flights %>% 
  group_by(year, month, day) %>% 
  filter(is.na(dep_time)) %>% 
  count()
flights %>% 
  group_by(year, month, day) %>% 
  summarise(cancelled_prop = mean(is.na(dep_time)),
            avg_delay = mean(arr_delay, na.rm = TRUE)) %>% 
  ggplot(mapping = aes(y = cancelled_prop, x = avg_delay)) +
  geom_point() +
  geom_smooth(se = FALSE)
# 5.
flights %>% 
  group_by(carrier, dest) %>% 
  summarise(mean_delay = mean(arr_delay, na.rm = TRUE),
            worst_delay = max(arr_delay, na.rm = TRUE),
            n = n()) %>%
  filter(n > 50) %>% 
  arrange(desc(worst_delay))
