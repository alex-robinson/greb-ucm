
## GREB-UCM

Welcome to the Globally Resolved Energy Balance (GREB) Climate Model,
also known as the Monash Climate Model. This version has been
customized for the Universidad Complutense of Madrid (GREB-UCM).

For more information about the model, please visit:   
http://users.monash.edu.au/~dietmard/content/GREB/GREB_model.html   
http://maths-simpleclimatemodel-dev.maths.monash.edu/   
https://blogs.monash.edu/climate/2012/12/13/the-monash-simple-climate-model/

And see the reference publication in Climate Dynamics here:   
http://users.monash.edu.au/~dietmard/papers/dommenget.and.floeter.greb.paper.cdym2011.pdf

Please cite the model as follows:   
Dommenget, D. and Flöter, J.: Conceptual understanding of climate change with a globally resolved energy balance model, Clim. Dyn., 37 (11-12), 2143–2165, doi:10.1007/s00382-011-1026-0, 2011.

## Prerequisites

To compile this model, a fortran compiler such as gfortran must be installed already.

To plot results in R using the provided functions in `output/`, 
R must be installed (http://cran.r-project.org/) along with the library "fields"
to be able to overlay country boundaries. 

If R is already installed, the "fields" library can be installed by loading R and calling,
```R
install.packages("fields")
```

## How to install, compile and run

1. Download the repository to your computer (either using git or the .zip file).
From the command line, go to the main model directory.

2. To compile greb-ucm with gfortran into the executable file `greb.x`, 
    ```
    make greb 
    ```

3. To run greb-ucm with the model output and parameters stored in the directory `output/test`,
    ```
    ./greb.x output/test 
    ```

4. Go to the main output directory,
    ```
    cd output/
    ```

5. Call R from the output directory and load the model results using the example,
    ```
    R
    ```
    ```R
    source("example.r")
    ```

## Output diagnostics 

The following variables are output from the model with dimensions [nlon,nlat,ntime]
- Tmm  : near surface temperature, monthly mean
- Tamm : atmospheric temperature,  monthly mean
- Tomm : deep ocean temperature, monthly mean 
- qmm  : atmospheric moisture, monthly mean 
- apmm : planetary albedo, monthly mean 
