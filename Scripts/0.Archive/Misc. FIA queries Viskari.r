# This was a "script" where I was quickly testing some stuff in response to an email from Toni Viskari. Will be unusable as-is, but some chunks may be handy later.

SELECT p.MEASYEAR as time,p.PLOT,p.CYCLE,p.SUBCYCLE,p.STATECD,p.LON,p.LAT,t.DIA*2.54 as dbh, t.STATUSCD,t.SPCD as spcd FROM PLOT as p LEFT JOIN TREE as t on p.CN=t.PLT_CN WHERE p.LON >= -85 AND p.LON < -75 AND p.LAT >= 30 AND p.LAT < 40 AND t.STATUSCD=1 AND t.DIA*2.54 > 5.0;


query = paste('SELECT p."MEASYEAR" as time,p."PLOT",p."CYCLE",p."SUBCYCLE",p."STATECD",p."LON",p."LAT",t."DIA"*2.54 as dbh, t."STATUSCD",t."SPCD" as spcd FROM "PLOT" as p LEFT JOIN "TREE" as t on p."CN"=t."PLT_CN" WHERE p."LON" >= ',lonmin,' AND p."LON" < ',lonmax,' AND p."LAT" >= ',latmin,' AND p."LAT" < ',latmax,' AND t."STATUSCD"=1 AND t."DIA"*2.54 > 5.0', sep='')

query = 'SELECT p."MEASYEAR" as time,p."PLOT",p."CYCLE",p."SUBCYCLE",p."STATECD",p."LON",p."LAT",t."DIA"*2.54 as dbh, t."STATUSCD",t."SPCD" as spcd FROM "PLOT" as p LEFT JOIN "TREE" as t on p."CN"=t."PLT_CN" WHERE p."STATECD"=37'

q = db.query(query, con=fia.con)


dim(q)
plots = sort(unique(q$PLOT))
  plots = plots[1:25] # ********************TEST
  qq = q[q$PLOT %in% plots,]
  
  qq=q
cycles = sort(unique(qq$CYCLE))
np = length(plots)
nc = length(cycles)

# dbh = aggregate(qq$dbh, by=list(qq$PLOT,qq$CYCLE), FUN=mean)
# aggregate(qq$time, by=list(qq$CYCLE), FUN=mean)

dbh2 = matrix(NA, nrow=np, ncol=nc)
for(i in 1:np) {
  for(j in 1:nc) {
    dbh2[i,j] = mean(qq$dbh[qq$PLOT==plots[i] & qq$CYCLE==cycles[j]], na.rm=T)
  }
  cat(i)
}
rownames(dbh2) = paste("plot",plots,sep=".")
colnames(dbh2) = paste("cycle",cycles,sep=".")
dbh2

SELECT p."MEASYEAR" as time,p."PLOT",p."CYCLE",p."SUBCYCLE",p."STATECD",p."LON",p."LAT",t."DIA"*2.54 as dbh, t."STATUSCD",t."SPCD" as spcd FROM "PLOT" as p LEFT JOIN "TREE" as t on p."CN"=t."PLT_CN" WHERE p."LON" >= -85 AND p."LON" < -75 AND p."LAT" >= 30 AND p."LAT" < 40 AND t."STATUSCD"=1 AND t."DIA"*2.54 > 5.0;





lonmin=360-82
lonmax=360-76
latmin=33
latmax=39
query = paste('SELECT p.MEASYEAR as time,p.PLOT,p.CYCLE,p.SUBCYCLE,p.STATECD,p.LON,p.LAT,t.DIA*2.54 as dbh, t.STATUSCD,t.SPCD as spcd FROM PLOT as p LEFT JOIN TREE as t on p.CN=t.PLT_CN WHERE p.LON >= ',lonmin,' AND p.LON < ',lonmax,' AND p.LAT >= ',latmin,' AND p.LAT < ',latmax, sep='')
q = db.query(query, con=fia.con)

query='SELECT p.MEASYEAR as time,p.PLOT,p.CYCLE,p.SUBCYCLE,p.STATECD,p.LON,p.LAT FROM plot as p'
query='SELECT p."MEASYEAR" as time,p."PLOT",p."CYCLE",p."SUBCYCLE",p."STATECD",p."LON",p."LAT" FROM "PLOT" as p WHERE "STATECD"=37'

q = db.query(query, con=fia.con)
#   q = q[ !is.na(q$lon) & !is.na(q$lat), ]
  q = q[ !is.na(q$LON) & !is.na(q$LON), ]

  library(maps)
  library(rworldmap)
  library(rgdal)
  data(coastsCoarse,envir = environment())     # An alternative base map. Needs one fix:
    ind = which(coastsCoarse@lines[[94]]@Lines[[1]]@coords[,1] > 180)
    coastsCoarse@lines[[94]]@Lines[[1]]@coords[ind,1] = 180

  # North america albers equal area conic
  # http://spatialreference.org/ref/esri/north-america-albers-equal-area-conic/proj4/
  proj4 = "+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
  crs = CRS(proj4)
  

  coordinates(q) = c("lon","lat")
  coordinates(q) = c("LON","LAT")
    proj4string(q) = CRS("+proj=longlat")

  q.tr  = spTransform(q, crs)
  coasts.tr = spTransform(coastsCoarse, crs)
    

  plot(q, xlim=range(q$lon), ylim=range(q$lat), bty='o')
  plot(q, xlim=range(q$LON), ylim=range(q$LAT), bty='o')
  map('state', add=T, col=2)
  points(35+54/60+24.84/3600, 360-78+55/60+18.48/3600, col=4)
