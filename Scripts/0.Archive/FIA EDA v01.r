rm(list=ls())
library(devtools)

setwd('/Work/Research/FIA/')
# load_all("./data.land_copy")


# library(XML)
# library(PEcAn.utils)
# library(PEcAn.DB)

# Note this has to be installed from source. First make sure to have the DBI package installed already. This is a normal install:
# install.packages("DBI")
#
# Then you may need to add your postgreSQL binary path to the system path for the next part to work. If you don't know where this is you should be able to find it by running 'pg_config' at your command line. Copy the entry for 'BINDIR'. Once you know BINDIR, add it to your path from within R:
#   Sys.setenv("PATH" = paste("<insert psql BINDIR here>", Sys.getenv("PATH"), sep=":"))
#
# Now download the RPostgreSQL source from:
#   http://cran.r-project.org/src/contrib/RPostgreSQL_0.4.tar.gz
# 
# Then install with:
#   install.packages("<PATH TO DOWNLOADED FILE>/RPostgreSQL_0.4.tar.gz", repos=NULL, type="source")


library(RPostgreSQL)
# source("~/pecan/db/R/utils.R")
source("/Work/Research/Pecan/pecan_git/db/R/utils.R")


  dbsettings = list(
    user="bety",
    password="bety",
    host="localhost",
#     port="6422",
#     dbname="fia5",
#     dbname="fia5data", # This one was imported from Rob's tarball
    dbname="fia5data2", # This one was imported from .csv
    driver='PostgreSQL',
    write=TRUE
  )

	POI	    <- T	 ## point or region?
	gridres	<- 10
	lat     <- 35
	lon     <- -79.5

year = 2001


# SPCD. Obtain codes from Appendix F. Could come up with a short list.
spcd = c(131, 802)

# Host pecanvm
#   HostName localhost
#   User carya
#   Port 6422
  
  
	fia.con <- db.open(dbsettings)

  	


	### select just most current
# 	query <- paste('SELECT "INVYR", "STATECD", "STATEAB", "STATENM", "CYCLE", "SUBCYCLE" from "SURVEY"', sep="")
	query <- paste('SELECT INVYR, STATECD, STATEAB, STATENM, CYCLE, SUBCYCLE from SURVEY', sep=)

	surv <- db.query(query, con=fia.con)
	names(surv) = tolower(names(surv))
	

	states <- sort(unique(surv$statecd))
	states <- states[states < 72]
	cycle  <- rep(NA,max(states))
	old    <- rep(FALSE,max(states))
	
	## choose the cycle closest to the specified year
	## note:	does not check for COMPLETE cycles
	for(s in states){
		sel <- which(surv$statecd == s)
		cycle[s] <- surv$cycle[sel[which.min(abs(year-surv$invyr[sel]))]]
	}
	
	if(POI){
		latmax = lat + gridres
		latmin = lat - gridres
		lonmax = lon + gridres
		lonmin = lon - gridres
	} else {
		latmin = min(lat)
		latmax = max(lat)
		lonmin = min(lon)
		lonmax = max(lon)
	}
	n.poi = length(latmin)
	

		##################
		##              ##
		##     PSS      ##
		##              ##
		##################
		## query to get PSS info
		query <- paste('SELECT p.CYCLE,p.STATECD,p.MEASYEAR as time,p.CN as patch,MIN(c.STDORGCD) as trk,AVG(c.STDAGE) as age,p.LAT,p.LON FROM PLOT as p LEFT JOIN COND as c on p.CN=c.PLT_CN WHERE 
             p.LON >= ',lonmin,' and p.LON < ',lonmax,
			      	' and p.LAT >= ',latmin,' and p.LAT < ',latmax,' GROUP BY p.CN')
			      	
    # Note aggregate is required on COND variables, since there may be multiple conditions per plot
			      	
		pss <- db.query(query, con=fia.con)
    names(pss) = tolower(names(pss))
    
    
# 		pss <- pss[pss$cycle == cycle[pss$statecd],]


    head(pss)



		##################
		##              ##
		##     CSS      ##
		##              ##
		##################
		
    
    query <- paste('SELECT p.MEASYEAR as time,p.CYCLE,p.STATECD,p.CN as patch,CONCAT(CAST(t.SUBP AS CHAR),CAST(t.TREE AS CHAR)) as cohort,t.DIA*2.54 as dbh, t.SPCD as spcd, t.TPA_UNADJ*0.0002471 as n FROM PLOT as p LEFT JOIN TREE as t on p.CN=t.PLT_CN WHERE 
             p.LON >= ',lonmin,' and p.LON < ',lonmax,
				' and p.LAT >= ',latmin,' and p.LAT < ',latmax, sep='')

		css <- db.query(query, con=fia.con)
		names(css) = tolower(names(css))
		
		
		
# 		css <- css[css$cycle == cycle[css$statecd],]
	
	head(css)
