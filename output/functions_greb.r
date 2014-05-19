



greb_load_boundaries <- function(path,xdim=96,ydim=48,ireal=4)
{   # Load all boundary data from binary files associated with a GREB simulation

    # open(11,file='tsurf',           ACCESS='DIRECT',FORM='UNFORMATTED', RECL=ireal*xdim*ydim)
    # open(12,file='vapor',           ACCESS='DIRECT',FORM='UNFORMATTED', RECL=ireal*xdim*ydim)
    # open(13,file='topography',      ACCESS='DIRECT',FORM='UNFORMATTED', RECL=ireal*xdim*ydim)
    # open(14,file='soil.moisture',   ACCESS='DIRECT',FORM='UNFORMATTED', RECL=ireal*xdim*ydim)
    # open(15,file='solar.radiation', ACCESS='DIRECT',FORM='UNFORMATTED', RECL=ireal*ydim*nstep_yr)
    # open(16,file='zonal.wind',      ACCESS='DIRECT',FORM='UNFORMATTED', RECL=ireal*xdim*ydim)
    # open(17,file='meridional.wind', ACCESS='DIRECT',FORM='UNFORMATTED', RECL=ireal*xdim*ydim)
    # open(18,file='ocean.mld',       ACCESS='DIRECT',FORM='UNFORMATTED', RECL=ireal*xdim*ydim)
    # open(19,file='cloud.cover',     ACCESS='DIRECT',FORM='UNFORMATTED', RECL=ireal*xdim*ydim)
    # open(20,file='glacier.masks',   ACCESS='DIRECT',FORM='UNFORMATTED', RECL=ireal*xdim*ydim)
    
    cat("GREB loading boundary data ... ")

    lat  = seq(-90+1.875,89.99,by=180/ydim)
    lon0 = seq(1.875,359.99,by=360/xdim)
    lon1 = shiftlons(lon0)
    lon  = lon1$lon 

    # timesteps in 1 year 
    ndays_yr  = 365               # number of days per year
    dt        = 12*3600           # time step [s]
    dt_crcl   = 0.5*3600          # time step circulation [s]  
    ndt_days  = 24*3600/dt        # number of timesteps per day
    nstep_yr  = ndays_yr*ndt_days # number of timesteps per year
    step_yr   = seq(1/ndt_days,365,length.out=nstep_yr)

    # Define our output data list and load the current parameters
    dat = list(lon=lon,lat=lat,step_yr=step_yr)

    # Read fixed data 
    dat$z_topo = load_binary(file.path(path,"topography"),     dims=c(xdim,ydim),    ireal=ireal,ii=lon1$ii)
    dat$glac   = load_binary(file.path(path,"glacier.masks"),  dims=c(xdim,ydim),    ireal=ireal,ii=lon1$ii)
    dat$insol  = load_binary(file.path(path,"solar.radiation"),dims=c(ydim,nstep_yr),ireal=ireal)
    
    # Read data throughout the year (nstep_yr times)
    # Define variable names to store in R and corresponding filenames
    vars = data.frame(nm =c("tsurf","vapor","soilm","windu","windv","z_omld","clouds"),
                      fnm=c("tsurf","vapor","soil.moisture","zonal.wind","meridional.wind","ocean.mld","cloud.cover"))

    for (q in 1:length(vars$nm)) {
        dat[[vars$nm[q]]] = load_binary(file.path(path,vars$fnm[q]),dims=c(xdim,ydim,nstep_yr),ireal=ireal,ii=lon1$ii)
    }

    
    # Calculate some additional variables
    dat$winduv = sqrt(dat$windu^2 + dat$windv^2)

    cat("done.\n")

    return(dat)
}

greb_load_parameters <- function(path,filename="namelist")
{   # Load parameter values from the fortran namelist file

    cat("GREB loading parameters from: ",file.path(path,filename)," ... ")
    
    # Initially scan namelist file, omitting comments
    dat = scan(file.path(path,filename),comment.char="!",what="character",quiet=TRUE)

    # Loop over all entries and extract parameter groups, parameter names and values
    par = list()
    q = 1 
    while (q <= length(dat)) {
        
        if (dat[q] == "/") {
            q = q+1
        } else if (length(grep("&",dat[q]))>0) {
            nm = gsub("&","",dat[q])
            par[[nm]] = list()
            q = q+1
        } else {

            vnm = dat[q]
            val = dat[q+2]
            par[[nm]][[vnm]] = as.numeric(val)
            q = q+3
        }
    }

    # Make sure that each group is represented as a data.frame
    for (q in 1:length(par)) par[[q]] = as.data.frame(par[[q]])

    cat("done.\n")

    return(par)
}

greb_load <- function(path,filename,year0=1970,nyr=3,xdim=96,ydim=48,ireal=4)
{   # Load greb simulation output (eg, control or scenario)

    cat("GREB loading from: ",file.path(path,filename)," ... ")

    lat  = seq(-90+1.875,89.99,by=180/ydim)
    lon0 = seq(1.875,359.99,by=360/xdim)
    lon1 = shiftlons(lon0)
    lon  = lon1$lon 

    time = seq(year0+1/24,year0+nyr,by=1/12)
    month = rep(c(1:12),nyr)

    dat = list(lon=lon,lat=lat,time=time,month=month,year=floor(time))

    # Tmm, Tamm, Tomm, qmm, apmm
    nvar = 5 
    nt   = length(time) 

    tmp = load_binary(file.path(path,filename),dims=c(xdim,ydim,nvar,nt),ireal=ireal)
    dat$Tmm  = tmp[lon1$ii,,1,]
    dat$Tamm = tmp[lon1$ii,,2,]
    dat$Tomm = tmp[lon1$ii,,3,]
    dat$qmm  = tmp[lon1$ii,,4,]
    dat$apmm = tmp[lon1$ii,,5,]

    cat("done.\n")

    return(dat)
}

greb_calc_timeseries <- function(dat,ii=c(1:length(dat$lon)),jj=c(1:length(dat$lat)))
{   # Take 2D greb data and calculate time series over a specific region

    area = gridarea(dat$lon[ii],dat$lat[jj])

    out = dat[c("time","month","year")]
    out$Tmm  = apply(dat$Tmm[ii,jj,], MARGIN=3,FUN=mean.areawt,area=area[ii,jj])
    out$Tamm = apply(dat$Tamm[ii,jj,],MARGIN=3,FUN=mean.areawt,area=area[ii,jj])
    out$Tomm = apply(dat$Tomm[ii,jj,],MARGIN=3,FUN=mean.areawt,area=area[ii,jj])
    out$qmm  = apply(dat$qmm[ii,jj,], MARGIN=3,FUN=mean.areawt,area=area[ii,jj])
    out$apmm = apply(dat$apmm[ii,jj,],MARGIN=3,FUN=mean.areawt,area=area[ii,jj])

    return(out)
}


### EXTRA FUNCTIONS ###

load_binary <- function(filename,dims,ireal=4,ii=NULL)
{   # Load binary data from file, shift x indices if necessary (longitudes)

    n = 1 
    for (q in 1:length(dims)) n = n*dims[q] 

    con        = file(filename,"rb")
    var        = readBin(con,numeric(),n=n,size=ireal)
    close(con)

    dim(var) = dims 

    if (!is.null(ii)) {
        if (length(dims)==2) var = var[ii,]
        if (length(dims)==3) var = var[ii,,]
        if (length(dims)==4) var = var[ii,,,]
    }

    return(var)
}

shiftlons <- function(lon,lon180=TRUE,xlim=range(lon))
{
    if (lon180 & range(lon,na.rm=TRUE)[2] > 180) {

        # Store indices of points in xlim range
        ii0 = which(lon >= xlim[1] & lon <= xlim[2])

        # Longitude
        lonX = lon
        i = which(lon > 180)
        lonX[i] = lonX[i] - 360
        i1 = which(lonX< 0)
        i0 = which(lonX>=0)
        ii = c(i1,i0)
        lonX = lonX[ii]

    } else if (!lon180 & range(lon,na.rm=TRUE)[1]<0) {

        # Longitude
        i0 = which(lon < 0)
        i1 = which(lon >=0)
        ii = c(i1,i0) 
        lonX = lon[ii]
        i = which(lonX < 0)
        lonX[i] = lonX[i] + 360

        #cat("lonX ",lonX,"\n")
    }

    return(list(lon=lonX,ii=ii))
}

## Earth grid weighting ##
## AREA of grid boxes
gridarea <- function(lon,lat,Re=6371)
{
  
    nx <- length(lon)
    ny <- length(lat)

    # Convert to radians
    latr <- lat*pi/180
    lonr <- lon*pi/180

    # Simple weighting based on cos(lat)...
    a <- cos(latr)
    area <- matrix(rep(a,nx),byrow=TRUE,ncol=ny,nrow=nx)
  
    # Normalize the area to sum to 1
    area = area / base::sum(area)

    return(area)
}

mean.areawt <- function(var,area,ii=c(1:length(var)),mask=array(TRUE,dim=dim(var)),na.rm=T,...)
{

  # Limit area to masked area
  area[!mask] = NA

  # Reduce data to subset
  var  = var[ii]
  area = area[ii]

  # Remove NAs
  if (na.rm) {
    ii   = !is.na(var + area)
    var  = var[ii]
    area = area[ii]
  }
  
  ave = NA
  if (length(var) > 0) ave = sum(area * var)/sum(area)

  return(ave)
}


greb_plotpar <- function()
{   # Set some default styles

    par(xaxs="i",col="grey40",col.axis="grey40",col.lab="grey40",tcl=0.2,mgp=c(2.5,0.3,0),las=1)
}

