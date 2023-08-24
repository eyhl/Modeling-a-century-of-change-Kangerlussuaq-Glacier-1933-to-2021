# Modeling a century of change: Kangerlussuaq Glacier's mass loss from 1933 to 2021
*E. Y. H. Lippert*[^1^], *M. Morlighem*[^2^], *G. Cheng*[^2^], *S. A. Khan*[^1^]
[^1^]: DTU Space, Technical University of Denmark, Kongens Lyngby, Denmark
[^2^]: Department of Earth Sciences, Dartmouth College, Hanover, NH 03755, USA

**Repository Description:**

This GitHub repository contains the source code and data used to reproduce the results presented in our study, which will be published in Geophysical Research Letters. In our research, we investigate the mass balance of the Kangerlussuaq Glacier in central-eastern Greenland over the past century (1933-2021). We introduce a novel approach that combines numerical modeling and historical data and a reconstruction of the surface mass balance to understand the glacier's behavior on longer time scales.

**Key Findings:**
- Kangerlussuaq Glacier, a significant contributor to mass loss in central-eastern Greenland, has been primarily studied using remote sensing methods until now.
- We use a numerical model and climate data spanning from 1933 to 2021 to reconstruct the glacier's mass balance over the last century.
- The model's final state aligns remarkably well with present-day observations, validating our approach.
- Our findings reveal a total ice mass loss of 285 billion metric tons over the century, equivalent to 0.68 mm of global sea level rise.
- Notably, dynamic thinning from ice front retreat is responsible for 88% of mass change since 1933, with seasonal ice front variations having minimal impact on centennial mass loss.
- Importantly, our results suggest that Kangerlussuaq lost 301 billion metric tons (59%) less mass over the century than previously estimated in earlier studies.

# Repository Contents

This GitHub repository contains the source code and data used to reproduce the results presented in our forthcoming publication in Geophysical Research Letters. Our study focuses on investigating the mass balance of the Kangerlussuaq Glacier in central-eastern Greenland over the past century (1933-2021). We introduce a novel approach that combines numerical modeling and climate data to understand the glacier's behavior.

## Directory Structure

The repository is organized into the following directories:

- **Configs**: Configuration files for the modeling and analysis processes.
- **Exp**: Experimental scripts and notebooks for data analysis.
- **Functions**: Custom functions and utilities used in the research.
  - **archived**: Functions that are no longer in use but may be useful for reference.
  - **extrapolation**: Functions related to data extrapolation.
  - **interpolation**: Functions related to data interpolation.
  - **plotting**: Functions for generating plots and visualizations.
  - **steps**: Functions for modeling steps and procedures.
  - **transient**: Functions for handling transient data.
  - **utils**: General utility functions.
  - **validation**: Functions for model validation and evaluation.
- **ParameterFiles**: Parameter files used to configure the numerical model.

## Key Files

Inside the `Functions` directory, you will find various subdirectories and key files:

- **create_config.m**: Script for creating configuration files.
- **experiments.m**: Main script for conducting experiments.
- **recipe.m**: Recipe for the modeling process.
- **run_model.m**: Script for running the numerical model.
- **store_model.m**: Script for storing model outputs.
- **validate_model.m**: Script for validating the model.

**Recreating the Results:**
To recreate the results of our study, please follow the instructions in the provided code and documentation. The `recipe.m` script should do most of the work.
The neccessary data can be obtained by contacting respective autors listed in the Data Availability section in the paper and output from the model can be found at: [Model output](10.5281/zenodo.8268754)

**Citation:**
If you use or reference the results, code, or data from this repository in your work, please cite our forthcoming publication in Geophysical Research Letters.

We hope that this repository and its contents will contribute to a better understanding of the Kangerlussuaq Glacier's behavior and its impact on sea level rise. If you have any questions or need further assistance, please feel free to contact us.
