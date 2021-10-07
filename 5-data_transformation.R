library(nycflights13)
library(tidyverse)

# The data is in a tibble, not a data frame.
flights

# The five key dplyr functions
?filter
?arrange
?select
?mutate
?summarise
?group_by # The D'Artagnan of those five functions

###############################################################################

# 5.2 Filter rows with `filter()`

# OBS: dplyr's functions never do things in place by default

# Select all flights from January 1st
(jan1 <- filter(flights, month == 1, day == 1)) # This assigns and prints

# Comparators: > < == <= >= != & | !
# To compare floating point numbers use near()
near(sqrt(2) ^ 2, 2)
near(1 / 49 * 49, 1)

# Flights that departed in November or December
filter(flights, month == 11 | month == 12)

# A shorthand for those operations is the %in% operator
nov_dec <- filter(flights, month %in% c(11, 12))

# Two different ways of saying the same thing using De Morgan's law
# De Morgan's law: !(x & y) == !x | !y ----- !(x | y) == !x & !y
# Select flights that weren't delayed by more than two hours
filter(flights, !(arr_delay > 120 | dep_delay > 120))
filter(flights, arr_delay <= 120, dep_delay <= 120)

# To determine if a value is missing
?is.na

# Filter excludes NA by default. To include missing values, be explicit
df <- tibble(x = c(1, NA, 3))
filter(df, x > 1)
filter(df, is.na(x) | x > 1) # Includes missing values

# 5.2.4 Exercises
# 1.
# 1.1
filter(flights, 
       arr_delay >= 120)
# 1.2
filter(flights,
       dest %in% c("IAH", "HOU"))
# 1.3
filter(flights,
       carrier %in% c("AA", "UA", "DL"))
# 1.4
filter(flights,
       month %in% c(7, 8, 9))
# 1.5
filter(flights,
       arr_delay > 120,
       dep_delay <= 0)
# 1.6
filter(flights,
       dep_delay >= 60,
       (dep_delay - arr_delay) > 30)
# 1.7
filter(flights,
       dep_time %in% c(1:600, 2400))
# 2.
# A: it calculates if a value is between two boundaries. It can be used
# to simplify some of the answers.
# NOTE: it is inclusive on both ends.
?between
# 3.
# A: those are probably cancelled flights.
missing_dep <- filter(flights, is.na(dep_time))
head(missing_dep)
nrow(missing_dep)
# 4.
# A: basically, logical or numerical operations that don't depend on the
# operand will "ignore" NA as a potential missing value of the expected
# type. Any number to the 0th is equal to 1, so NA doesn't matter; from
# boolean logic, any OR comparision to TRUE yields TRUE; and any AND
# comparision to FALSE yields FALSE, so NA doesn't matter there either.
?NA # the answer is here, under "Details"

# 5.3 Arrange rows with `arrange()`

# Basically orders a data frame based on the values of the specified columns.
?arrange
arrange(flights, year, month, day)

# desc() allows to use descending order.
arrange(flights, desc(dep_delay))

# Missing values always go to the end.
df <- tibble(x = c(5, 2, NA))
arrange(df, x)
arrange(df, desc(x))

# 5.3.1 Exercises
# 1.
arrange(flights, desc(is.na(dep_time))) # that's how
# 2.
arrange(flights, desc(dep_delay)) # most delayed
arrange(flights, dep_delay) # left earliest
# 3.
arrange(flights, distance / air_time) # speed = distance / time
# 4.
head(arrange(flights, desc(distance))) # travelled the farthest
head(arrange(flights, distance)) # travelled the shortest

# 5.4 Select columns with `select()`

# Used to... select a subset of the variables from a data frame.
?select
select(flights, year, month, day)
select(flights, year:day) # can use a range too, basically the same as above
select(flights, -(year:day)) # this excludes the specified variables or range

# We can use some helper functions with `select()`
?starts_with # matches names that begin with the specified string
?ends_with # matches names that end with the specified string
?contains # matches names that contain the specified string
?matches # matches names that match a regular expression
?num_range # matches names that contain the specified string + a numerical range

# `select()` can be used to rename variables, but it drops the non-selected ones
# so it might not be well suited to do that. Use `rename()` instead, which is
# a variant of select that doesn't drop any variables.
# The order is `new_name = old_name`.
rename(flights, tail_num = tailnum)

# A trick to reorder some columns (move them to the start of the df) is to
# use `select()` in conjunction with the `everything()` helper.
select(flights, time_hour, air_time, everything())

# 5.4.1 Exercises
# 1.
select(flights, dep_time, dep_delay, arr_time, arr_delay)
select(flights, c(dep_time, dep_delay, arr_time, arr_delay))
select(flights, starts_with("dep"), starts_with("arr"))
select(flights, ends_with("delay"), 
       starts_with("arr") & ends_with("time"),
       starts_with("dep") & ends_with("time"))
select(flights, matches("^(arr|dep)_(time|delay)"))
select(flights, contains(c("arr", "dep")) 
       & contains(c("time", "delay"))
       & !contains("sched"))
# 2.
# A: it ignores the duplicate.
select(flights, tailnum, tailnum)
# 3.
# A: It selects any of the existing variables specified in the input vector.
# It allows for missing values, so it doesn't throw an error if one of the
# variables in the input vector don't exist in the data frame.
vars <- c("year", "month", "day", "dep_delay", "arr_delay")
select(flights, any_of(vars))
?any_of
# 4.
# A: it ignores case by default. This behaviour can be controlled by specifying
# `ignore.case = FALSE`
select(flights, contains("TIME"))
select(flights, contains("TIME", ignore.case = FALSE))

# 5.5 Add new variables with `mutate()`

# Adds new columns to a data frame. It adds the new columns to the end of the
# existing dataset.
?mutate

# Reduce the size of the df so we can see the new columns.
flights_sml <-
  select(flights, year:day, ends_with("delay"), distance, air_time)
mutate(flights_sml,
       gain = dep_delay - arr_delay,
       speed = distance / air_time * 60)

# You can refer to columns while creating them.
mutate(flights_sml,
       gain = dep_delay - arr_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours) # referencing the new variables

# `transmute()` only keeps the new variables and drops the rest.
transmute(flights_sml,
          gain = dep_delay - arr_delay,
          hours = air_time / 60,
          gain_per_hour = gain / hours)

# Some useful creation functions
# Arithmetic operations are vectorized and the shortest argument is expanded.
# Very useful when doing basically scalar math like:
mutate(flights_sml,
       hours = air_time / 60) # Here, "60" is repeated for all "air_time"s
# Also useful when used with aggregation functions:
mutate(flights_sml,
       proportional_distance = distance / sum(distance)) # Proportion
mutate(flights_sml,
       error_distance = distance - mean(distance)) # Diff from the mean

# Modular arithmetic is useful to break integers into pieces.
# E.g., computing `hour` and `minute` from `dep_time`:
transmute(flights,
          dep_time,
          hour = dep_time %/% 100, # Integer division (int part of the result)
          minute = dep_time %% 100) # Remainder

# Logarithm, to convert deal with data over multiple orders of magnitude 
# and converting multiplicative relationships to additive.
?log
?log2
?log10

# Offsets, useful to compute running differences or to find when values change.
?lead
?lag

# Cumulative and rolling aggregates.
?cumsum
?cumprod
?cummin
?cummax
?cummean

# Logical comparisons. No example here, this one is very simple.

# Ranking.
?min_rank
?row_number
?dense_rank
?percent_rank
?cume_dist
?ntile

# 5.5.2 Exercises
# 1.
mutate(flights,
       dep_time = (dep_time %/% 100 * 60) + dep_time %% 100,
       sched_dep_time = (sched_dep_time %/% 100 * 60) + sched_dep_time %% 100)
# 2.
# A: the problem is that `air_time` is formatted in minutes and both `arr_time`
# and `dep_time` are formatted in HHMM, so we need to convert those to minutes
# before doing the math.
transmute(flights,
          air_time,
          calculated_air_time = ((arr_time %/% 100 * 60) + arr_time %% 100) - ((dep_time %/% 100 * 60) + dep_time %% 100),
          arr_time,
          dep_time)
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
# 1.
# A: Arrival delay because a flight might depart but be redirected or suffer
# an accident mid flight.
# 1.1
flights %>% 
  group_by(flight) %>%
  summarise(early.15 = sum(arr_delay <= -15, na.rm = TRUE)/n(),
            late.15 = sum(arr_delay >= 15, na.rm = TRUE)/n(),
            n = n()) %>% 
  ungroup() %>%
  filter(early.15 == .5, late.15 == .5)
# 1.2
flights %>% 
  group_by(flight) %>% 
  summarise(late.10 = sum(arr_delay >= 10, na.rm = TRUE)/n(),
            n = n()) %>% 
  ungroup() %>% 
  filter(late.10 == 1)
# 1.3
flights %>% 
  group_by(flight) %>%
  summarise(early.30 = sum(arr_delay <= -30, na.rm = TRUE)/n(),
            late.30 = sum(arr_delay >= 30, na.rm = TRUE)/n(),
            n = n()) %>% 
  ungroup() %>%
  filter(early.30 == .5, late.30 == .5)
# 1.4
flights %>% 
  group_by(flight) %>%
  summarise(on.time = sum(arr_delay <= 0, na.rm = TRUE)/n(),
            late.120 = sum(arr_delay >= 120, na.rm = TRUE)/n(),
            n = n()) %>% 
  ungroup() %>%
  filter(on.time >= .99, late.120 <= .01)
# 2.
not_cancelled %>% count(dest) # Q1
not_cancelled %>% group_by(dest) %>% summarise(n = n()) # A1
not_cancelled %>% count(tailnum, wt = distance) # Q2
not_cancelled %>% group_by(tailnum) %>% summarise(n = sum(distance)) # A2
# 3.
# A: only the `arr_delay` information is needed.
flights %>% filter(is.na(arr_delay))
# 4.
flights %>% 
  group_by(day) %>% 
  summarise(n = n(),
            cancelled = sum(is.na(arr_delay)),
            avg_delayed = mean(arr_delay, na.rm = TRUE),
            cancelled_perc = cancelled / n) %>% 
  ggplot(aes(x = day, y = cancelled_perc)) +
  geom_point() +
  geom_smooth(se = FALSE)
  
flights %>% 
  group_by(day) %>% 
  summarise(cancelled_prop = sum(is.na(arr_delay)) / n(),
            avg_delay = mean(arr_delay, na.rm = TRUE)) %>% 
  ggplot(mapping = aes(x = cancelled_prop, y = avg_delay)) +
  geom_point() +
  geom_smooth()
# 5.
flights %>% 
  group_by(carrier) %>% 
  summarise(mean_delay = mean(arr_delay, na.rm = TRUE),
            n = n()) %>%
  filter(n > 50) %>% 
  arrange(desc(mean_delay))

# 5.7 Grouped mutates (and filters)

# Aside from `summarise()`, it is also useful to use groupings together with
# `mutate()` and `filter()`

# Find the 9 worst arr_delays per day
flights_sml %>% 
  group_by(year, month, day) %>% 
  filter(rank(desc(arr_delay)) < 10)

# Find all destinations that receive > 365 flights
popular_dests <- flights %>% 
  group_by(dest) %>% 
  filter(n() > 365)
popular_dests

# Standardise to compute per group metrics
popular_dests %>% 
  filter(arr_delay > 0) %>% 
  mutate(prop_delay = arr_delay / sum(arr_delay)) %>% 
  select(year:day, dest, arr_delay, prop_delay)

# 5.7.1 Exercises
# 2.
flights %>%
  group_by(tailnum) %>%
  summarise(
    n_flights = n(),
    total_delay = sum(ifelse(arr_delay >= 0, arr_delay, 0), # this ternary sums only true delays (arr_delay >= 0)
                      na.rm = TRUE),
    on_time_count = sum(arr_delay <= 0, na.rm = TRUE),
    on_time_prop = on_time_count / n_flights
  ) %>%
  filter(n_flights > 100, !is.na(tailnum)) %>% # avoid flights with small sample number
  arrange(on_time_prop)
