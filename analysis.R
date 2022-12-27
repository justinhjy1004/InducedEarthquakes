#===================================================================
# Author: Justin Ho
# Date: 12-27-2022
# 
# This is an exploration of human-induced earthquakes, relating
# the number of wells approved for fracking in Oklahoma and the
# occurrences of earthquakes.
# 
# Data Sources
# 1. https://www.fractracker.org/map/us/oklahoma/ (Fractracker)
# 2. https://earthquake.usgs.gov/earthquakes/map/ (US Geological Survey)
#===================================================================

# install.package("tidyverse")
library(tidyverse)

# unzip("data.zip")

#====================================================================
# 1. Read "wells_OK.csv" (Fracking Wells Data)
# 2. Subset Approved Wells since 2000-01-01
# 3. Count the number of wells approved by month
# 4. Plot
#====================================================================
wells <- read_csv("wells_OK.csv")

wells <- wells[wells$`Approval Date` > as.Date('2000-01-01'),]

wells$month <- format(as.Date(wells$`Approval Date`), "%Y-%m-01")

wells_monthly <- wells %>%
  mutate(count = 1) %>%
  group_by(month) %>%
  summarise(num_wells = sum(count))

ggplot(data = wells_monthly) +
  geom_point(mapping = aes(x=as.Date(month), y=num_wells))

#====================================================================
# 1. Read "earthquakes_OK.csv" (Earthquakes Data)
# 2. Count the number of earthquakes by month
# 3. Get the maximum earthquake magnitude and depth by month
# 4. Plot number of earthquakes maximum earthquake magnitude and 
#    depth by month
#====================================================================

eq <- read_csv("earthquakes_OK.csv")

eq$month <- format(as.Date(eq$time), "%Y-%m-01")

eq_monthly <- eq %>%
  mutate(count = 1) %>%
  group_by(month) %>%
  summarise(num_eq = sum(count), max_mag = max(mag), max_depth = max(depth))

ggplot(data = eq_monthly) +
  geom_point(mapping = aes(x=as.Date(month), y=num_eq))

ggplot(data = eq_monthly) +
  geom_point(mapping = aes(x=as.Date(month), y=max_mag))

ggplot(data = eq_monthly) +
  geom_point(mapping = aes(x=as.Date(month), y=max_depth))


#====================================================================
# 1. Read "oklahoma_polygon.csv"
# 2. Remove Well locations that are out of bounds
# 3. Plot wells on the map of Okhlahoma
#====================================================================

oklahoma_polygon <- read_csv("oklahoma_polygon.csv")

max_long <- max(oklahoma_polygon$long)
max_lat <- max(oklahoma_polygon$lat)
min_long <- min(oklahoma_polygon$long)
min_lat <- min(oklahoma_polygon$lat)

wells <- wells[(wells$LAT < max_lat) & (wells$LAT > min_lat) & !is.na(wells$LAT),]
wells <- wells[(wells$LONG < max_long) & (wells$LONG > min_long)& !is.na(wells$LAT),]

ggplot() +
    geom_polygon(data = oklahoma_polygon, 
             aes(x=long, y=lat, group=group, fill=subregion),
             alpha=.35) +
    geom_point(data = wells, aes(x=LONG, y=LAT),size=.1) +
    xlab("longitude") +
    ylab("latitude") +
    coord_equal() +
    ggtitle(label = "Location of Wells Approved") +
    theme(legend.position = "none",
          panel.border = element_blank(),
          panel.background = element_blank())

#====================================================================
# 1. Plot the number of wells approved over time
# 2. This is to help visualize the evolution of earthquakes
#    and wells over space and time
#====================================================================

months <- sort(unique(wells_monthly$month))

# dir.create("WellsLocation/")
for (m in months) {
  map <- ggplot() +
    geom_polygon(data = oklahoma_polygon, 
                 aes(x=long, y=lat, group=group, fill=subregion),
                 alpha=.35) +
    geom_point(data = wells[wells$`Approval Date` < as.Date(m, "%Y-%m-%d") &
                              wells$`Approval Date` > as.Date(m, "%Y-%m-%d") - 2400,], 
               aes(x=LONG, y=LAT,color = `Approval Date`),size=.1) +
    xlab("longitude") +
    ylab("latitude") +
    coord_equal() +
    ggtitle(label = "Location of Wells Approved",
            subtitle = substring(m, 1,4)) +
    theme(text = element_text(size=5),
        legend.position = "none",
          panel.border = element_blank(),
          panel.background = element_blank()) + 
    scale_colour_gradient(low = "white", high = "black")
  
  ggsave(paste("WellsLocation/",m,".png",sep=""),map)
}

# dir.create("EqLocations/")
for (m in months) {
  map <- ggplot() +
    geom_polygon(data = oklahoma_polygon, 
                 aes(x=long, y=lat, group=group, fill=subregion),
                 alpha=.35) +
    geom_point(data = eq[eq$time < as.Date(m, "%Y-%m-%d") & 
                        eq$time > as.Date(m, "%Y-%m-%d") - 1200,], 
               aes(x=longitude, y=latitude,color = time),size=.1) +
    xlab("longitude") +
    ylab("latitude") +
    coord_equal() +
    ggtitle(label = "Location of Earthquakes",
            subtitle = substring(m, 1,4)) +
    theme(text = element_text(size=5),
          legend.position = "none",
          panel.border = element_blank(),
          panel.background = element_blank()) + 
    scale_colour_gradient(low = "white", high = "black")

  ggsave(paste("EqLocations/",m,".png",sep=""),map)
}

#========================================================================
# 1. Join earthquake and wells data for plotting
# 2. Perform Regression
#========================================================================

eq_wells <- wells_monthly %>%
  left_join(eq_monthly, by = "month")

# To 'correct' the scale
coeff <- 6

ggplot(eq_wells, aes(x=as.Date(month))) +
  geom_line( aes(y=num_eq/coeff)) + 
  geom_line( aes(y=num_wells), color='blue') + 
  scale_y_continuous(
    # Features of the first axis
    name = "# Wells Approved",
    # Add a second axis and specify its features
    sec.axis = sec_axis(~.*coeff, name="# Earthquakes")
  ) + 
  xlab("Year") +
  ggtitle("Fracking Wells and Earthquakes") +
  theme_light()

summary(lm(num_eq ~ num_wells, data=eq_wells))

#========================================================================
# 1. Lag approval of wells by 30 months
# 2. Perform Regression with lagged variables
# 3. Plot the graph with Lagged Values
#========================================================================

lag_eq <- eq_wells %>%
  mutate(lag_num_wells = lag(num_wells, 30))

summary(lm(num_eq ~ lag_num_wells, data=lag_eq))
summary(lm(max_mag ~ lag_num_wells, data=lag_eq))
summary(lm(max_depth ~ lag_num_wells, data=lag_eq))

ggplot(lag_eq, aes(x=as.Date(month))) +
  geom_line( aes(y=num_eq/coeff)) + 
  geom_line( aes(y=lag_num_wells), color='blue') + 
  scale_y_continuous(
    # Features of the first axis
    name = "# Wells Approved (2.5 Years Prior)",
    # Add a second axis and specify its features
    sec.axis = sec_axis(~.*coeff, name="# Earthquakes")
  ) +
  xlab("Year") +
  ggtitle("Fracking Wells and Earthquakes") +
  theme_light()
