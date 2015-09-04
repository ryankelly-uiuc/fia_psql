rm(list=ls())

# Load RPostgreSQL library
# RPostgreSQL has to be installed from source. First make sure to have the DBI package installed already. This is a normal install:
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


# Now load some PEcAn functions, written by R. Kooper, M. Dietze, et al. If you have PEcAn you can just load the library, but if not, download PSQL_utils.R from the macrosystems-FIA folder (currently https://duke.box.com/macrosystems-FIA), and source it here:
source("path_to_file/PSQL_utils.R")


# Settings for your database (Change as needed.)
  dbsettings = list(
    user     = "",                # PSQL username
    password = "",                # PSQL password
    dbname   = "fia5data",        # PSQL database name
    host     = "localhost",       # PSQL server address (don't change unless server is remote)
    driver   = 'PostgreSQL',      # DB driver (shouldn't need to change)
    write    = FALSE              # Whether to open connection with write access. 
  )


# Define a region/point of interest
#  If POI=TRUE, the region is defined as the single lat/lon point given, +/- gridres degrees in all four cardinal directions. 
# If POI=FALSE, give 2-element vectors for lat/lon to specify the bounds of the area of interest. gridres will be ignored. 

  # Example 1
# 	POI	    = TRUE
# 	gridres	= 10
# 	lat     = 35
# 	lon     = -79.5

  # Example 2
	POI	    = FALSE
	gridres	= 10
	lat     = c(30,40)
	lon     = c(-85,-75)


# Survey year
#  The code below will find the census closest to this year for each state, and extract data from those censuses only. 
  year = 2001


# Vector of species codes for all species to extract. Obtain codes from Appendix F of the FIADB Guide. 
  spcd = c(131, 802)


# ------------------- End settings  
  # ----- Setup
    # Open connection to database
    fia.con = db.open(dbsettings)

    # select most current survey
    query = paste('SELECT INVYR, STATECD, STATEAB, STATENM, CYCLE, SUBCYCLE from SURVEY', sep=)
    surv = db.query(query, con=fia.con)
      names(surv) = tolower(names(surv))

    states = sort(unique(surv$statecd))
    states = states[states < 72]
    cycle  = rep(NA,max(states))
    old    = rep(FALSE,max(states))
  
    ## choose the cycle closest to the specified year
    ## note:	does not check for COMPLETE cycles
    for(s in states){
      sel = which(surv$statecd == s)
      cycle[s] = surv$cycle[sel[which.min(abs(year-surv$invyr[sel]))]]
    }
  
  
    # Define area of interest
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
	

  # ----- Query plot info ("pss" designation refers to ED model "patches")
    query = paste('SELECT p.CYCLE,p.STATECD,p.MEASYEAR as time,p.CN as patch,MIN(c.STDORGCD) as trk,AVG(c.STDAGE) as age,p.LAT,p.LON FROM PLOT as p LEFT JOIN COND as c on p.CN=c.PLT_CN WHERE 
             p.LON >= ',lonmin,' and p.LON < ',lonmax,
              ' and p.LAT >= ',latmin,' and p.LAT < ',latmax,' GROUP BY p.CN')
            
    # Note aggregate is required on COND variables, since there may be multiple conditions per plot
    pss = db.query(query, con=fia.con)
      names(pss) = tolower(names(pss))
  
    # Restrict to census nearest to specified year
    pss = pss[pss$cycle == cycle[pss$statecd],]

    # Look at the first few lines of data
    head(pss)


  # ----- Query tree info ("css" designation refers to ED model "cohorts")
    query = paste('SELECT p.MEASYEAR as time,p.CYCLE,p.STATECD,p.CN as patch,CONCAT(CAST(t.SUBP AS CHAR),CAST(t.TREE AS CHAR)) as cohort,t.DIA*2.54 as dbh, t.SPCD as spcd, t.TPA_UNADJ*0.0002471 as n FROM PLOT as p LEFT JOIN TREE as t on p.CN=t.PLT_CN WHERE 
             p.LON >= ',lonmin,' and p.LON < ',lonmax,
				' and p.LAT >= ',latmin,' and p.LAT < ',latmax, sep='')

		css = db.query(query, con=fia.con)
		names(css) = tolower(names(css))
		
		
    # Restrict to census nearest to specified year
    css = css[css$cycle == cycle[css$statecd],]

    # Look at the first few lines of data	
    head(css)


  # ----- Close DB connection
    db.close(fia.con)