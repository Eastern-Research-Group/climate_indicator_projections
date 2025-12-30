# Climate Change Indicator Projections Explorer

**Live App:** https://erg-shiny.shinyapps.io/climate_indicator_projections/  

A R **{shiny}** application built with the **{golem}** framework for exploring a selection of the [Environmental Protection Agency's Climate Change Indicators](https://19january2025snapshot.epa.gov/climate-indicators/index.html) with data from the most recent global climate model comparison effort, showing how these indicators could evolve under continued climate change.

## Basic Startup

To run this app locally:

```r
# Install devtools if needed
install.packages("devtools")

# Install the app as a package
devtools::install_github("Eastern-Research-Group/climate_indicator_projections")

# Load the app
library(ClimateIndicatorProjections)

# Run the app
run_app()
```
## License 

This project is licensed under the MIT License.
See the ```LICENSE.md``` file for details.

## Citation

Please use the recommended citation below.

Eastern Research Group, Inc. (2025). Climate Change Indicators Projections Explorer. https://github.com/Eastern-Research-Group/climate_indicator_projections
