jet.colors = c("#00007F", "blue", "#007FFF", "cyan","#7FFF7F",
                 "yellow", "#FF7F00", "red", "#7F0000")

mylegend <- function(breaks,col,units="",x=c(0,1),y=c(0,1),at=NULL,labels=NULL,
                     xlab="",ylab="",xlim=NULL,ylim=NULL,zlim=range(breaks),
                     cex=1,cex.lab=1,new=TRUE,vertical=TRUE,line=1.8,
                     asp=1,mgp=c(3,0.5,0),col.axis="grey10",...)
{
    n      = length(breaks)    
    ynorm  = (breaks - min(breaks))
    ynorm  = ynorm / max(ynorm)
    y00    = ynorm[1:(n-1)]
    y11    = ynorm[2:n]
    x00    = rep(0,n)
    x11    = rep(1,n) 

    if ( vertical ) {
      x0   = x00
      x1   = x11 
      y0   = y00
      y1   = y11 
      xlim = c(0,1)
      ylim = zlim 
      ax   = 4
    } else {
      x0   = y00
      x1   = y11
      y0   = x00
      y1   = x11
      xlim = zlim
      ylim = c(0,1)
      ax   = 1
    }

    xlim0 = range(x0,x1)
    ylim0 = range(y0,y1)

    par(new=new,xpd=NA,xaxs="i",yaxs="i",...)
    plot( xlim0,ylim0, type="n",axes=F,ann=F,cex=cex)
    rect(x0,y0,x1,y1,col=col,border=col,lwd=1)

    par(new=TRUE,xpd=NA,xaxs="i",yaxs="i",...)
    plot(xlim,ylim,type="n",axes=F,ann=F,cex=cex)
    axis(ax,at=at,labels=labels,mgp=mgp,tcl=-0.1,col=col.axis,col.axis=col.axis,cex.axis=cex)
    box(col="grey10")

    mtext(side=1,line=line,xlab,cex=cex.lab)
    mtext(side=2,line=line,ylab,cex=cex.lab)

    par(xpd=FALSE)
}

myimage  <- function(x,y,z,breaks=NULL,col=NULL,xlab=NULL,ylab=NULL,
                     xlim=range(x,na.rm=TRUE),ylim=range(y,na.rm=TRUE),
                     zlim=range(z,na.rm=TRUE))
{
    ztmp = z 
    if (!is.null(zlim)) {
        ztmp[z<zlim[1]] = zlim[1]
        ztmp[z>zlim[2]] = zlim[2]
    } else {
        zlim = range(ztmp,na.rm=TRUE)
    }

    if (is.null(breaks)) {
        nb = 15
        breaks = pretty(zlim,nb)
    }
    nb = length(breaks)
    col = colorRampPalette(jet.colors)(nb-1)

    par(plt=c(0.88,0.92,0.2,0.8))
    mylegend(breaks=breaks,col=col,new=FALSE)

    par(plt=c(0.13,0.86,0.1,0.9),new=TRUE)
    image(x=x,y=y,z=z,ann=FALSE,xlim=xlim,ylim=ylim,zlim=zlim,breaks=breaks,col=col)
    title(xlab=xlab,ylab=ylab)

    
}






