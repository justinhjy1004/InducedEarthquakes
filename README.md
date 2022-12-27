# Human Induced Earthquakes

This is an exercise on visualizing and relating human-induced earthquakes
and the presence of oil wells in Oklahoma. <br>

While there are many misconceptions and nuances involved in the relationship
between fracking (hydraulic fracturing) and human-induced earthquakes, it is
widely accecpted that disposal of waste fluids that are a byproduct of oil production is the primary cause of the recent increase in earthquakes in the central United States. Learn more at https://www.usgs.gov/programs/earthquake-hazards/myths-and-misconceptions-about-induced-earthquakes 

## Relating Earthquakes in Oklahoma and Well Production
![](https://github.com/justinhjy1004/InducedEarthquakes/blob/main/Optimized.gif)

The GIF above shows the wells approved for drilling as well as the occurrences
of earthquakes over time and space in the state of Oklahoma. Note that prior to 2010s,
earthquakes are extremely rare. However, the proliferation of oil wells was
followed by occurrences of earthquakes at northern and central Oklahoma.

![](https://github.com/justinhjy1004/InducedEarthquakes/blob/main/wells_eq.png)

The graph above shows the number of earthquakes (in black) and approval of oil wells (in blue). Note the lag between the two variables, which is required when considering 
the relationship between earthquakes and oil wells.
```
===========================================================
                 # Earthquakes  Max Magnitude  Max Depth   
                  ----------     ----------    ----------  
                    num_eq        max_mag      max_depth   
-----------------------------------------------------------
  (Intercept)     -51.527***       3.032***      5.740***  
                  (10.840)        (0.092)       (0.973)    
  lag_num_wells     5.121***       0.028***      0.187***  
                   (0.496)        (0.004)       (0.044)    
-----------------------------------------------------------
  R-squared         0.361          0.193         0.086     
  F               106.621         45.211        17.713     
  p                 0.000          0.000         0.000     
  N                 191            191           191         
===========================================================
  Significance: *** = p < 0.001; ** = p < 0.01;   
                * = p < 0.05  
===========================================================
```

The regression table above shows the relationship between the number of approved wells
30 months ago and the number of occurrences of earthquakes, the maximum magnitude and
the maximum depth.

## Replication
analysis.R is the main file for the replication of the visualizations and analysis.

## Data Sources
A subset of the dataset can be found in data.zip. The sources of data that
data.zip contains is from the following two links below.

https://www.fractracker.org/map/us/oklahoma/

https://earthquake.usgs.gov/earthquakes/map/?extent=15.28419,-138.95508&extent=55.92459,-51.06445