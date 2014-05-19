
# Load functions
source("functions.r")
source("functions_greb.r")

# Tmm  : near surface temperature, monthly mean
# Tamm : atmospheric temperature,  monthly mean
# Tomm : deep ocean temperature, monthly mean 
# qmm  : atmospheric moisture, monthly mean 
# apmm : planetary albedo, monthly mean 

## DATA LOADING ##

if (FALSE) {
    # Where is the experiment stored, relative to current directory
    path = "default"

    # # Load boundary data (the same for all experiments)
    # grebb = greb_load_boundaries("../input")    # Boundary data

    # Load the parameters, input data and model output
    par   = greb_load_parameters(path)
    grebc = greb_load(path,filename="control", year0=1970,nyr=par$NUMERICS$time_ctrl)  # control run
    greb  = greb_load(path,filename="scenario",year0=1940,nyr=par$NUMERICS$time_scnr)  # scenario

    # Calculate time series from the 2D data (area weighted by latitude!)
    grebc_ts = greb_calc_timeseries(grebc)
    greb_ts  = greb_calc_timeseries(greb)

}

## SOME PLOTS ##

## PLOT: time series of the global mean
if (FALSE) {
    
    # Plot style    
    greb_plotpar()
    par(mfrow=c(5,1),plt=c(0.06,0.95,0.15,0.88))

    xlim = range(greb_ts$time)

    ylim = range(greb_ts$Tmm)
    plot(xlim,ylim,type='n',ann=FALSE)
    title("Near-surface temp. (K)",line=0.5)
    grid()
    lines(greb_ts$time,greb_ts$Tmm,lwd=1.5,col=1)

    ylim = range(greb_ts$Tamm)
    plot(xlim,ylim,type='n',xlab="Time",ann=FALSE)
    title("Atmospheric temp. (K)",line=0.5)
    grid()
    lines(greb_ts$time,greb_ts$Tamm,lwd=1.5,col=1)
    
    ylim = range(greb_ts$Tomm)
    plot(xlim,ylim,type='n',xlab="Time",ann=FALSE)
    title("Oceanic temp. (K)",line=0.5)
    grid()
    lines(greb_ts$time,greb_ts$Tomm,lwd=1.5,col=1)
    
    ylim = range(greb_ts$qmm)
    plot(xlim,ylim,type='n',xlab="Time",ann=FALSE)
    title("Atmospheric moisture content (kg m^-2)",line=0.5)
    grid()
    lines(greb_ts$time,greb_ts$qmm,lwd=1.5,col=1)
    
    ylim = range(greb_ts$apmm)
    plot(xlim,ylim,type='n',xlab="Time",ann=FALSE)
    title("Planetary albedo",line=0.5)
    grid()
    lines(greb_ts$time,greb_ts$apmm,lwd=1.5,col=1)
    
}

## PLOT: 2D diagnostic fields for a time period
if (FALSE) {

    kk = which( greb$year %in% c(1985:1989) & greb$month %in% c(6,7,8) )

    greb_plotpar()
    par(mfrow=c(3,2),plt=c(0.1,0.95,0.1,0.90))

    myimage(greb$lon,greb$lat,apply(greb$Tmm[,,kk],MARGIN=c(1,2),FUN=mean))
    title("Near-surface temp. (K)",line=0.5)
    contour(greb$lon,greb$lat,greb$mask,add=TRUE,drawlabels=FALSE)

    myimage(greb$lon,greb$lat,apply(greb$Tamm[,,kk],MARGIN=c(1,2),FUN=mean))
    title("Atmospheric temp. (K)",line=0.5)
    contour(greb$lon,greb$lat,greb$mask,add=TRUE,drawlabels=FALSE)

    myimage(greb$lon,greb$lat,apply(greb$Tomm[,,kk],MARGIN=c(1,2),FUN=mean))
    title("Oceanic temp. (K)",line=0.5)
    contour(greb$lon,greb$lat,greb$mask,add=TRUE,drawlabels=FALSE)

    myimage(greb$lon,greb$lat,apply(greb$qmm[,,kk],MARGIN=c(1,2),FUN=mean))
    title("Atmospheric moisture content (kg m^-2)",line=0.5)
    contour(greb$lon,greb$lat,greb$mask,add=TRUE,drawlabels=FALSE)

    myimage(greb$lon,greb$lat,apply(greb$apmm[,,kk],MARGIN=c(1,2),FUN=mean))
    title("Planetary albedo",line=0.5)
    contour(greb$lon,greb$lat,greb$mask,add=TRUE,drawlabels=FALSE)

}


