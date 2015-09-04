# Create mini DB for testing
  export PATH="/Applications/Postgres.app/Contents/Versions/9.4/bin/":$PATH

  DATABASE="fia5data_csvimport_mini"     # Desired database name
  DATA_DIR="/Volumes/Gonzo/Pecan/FIA/ENTIRE/"  
  g='./DWM_COARSE_WOODY_DEBRIS.CSV'
  USER=assman
  DB_PSQLDUMP="/Volumes/Gonzo/Pecan/FIA/FIADB_version5_1_RKedit01.psql"

  dropdb --if-exists ${DATABASE}
  createdb -U ${USER} ${DATABASE}
  psql -d ${DATABASE} < ${DB_PSQLDUMP}

  cd ${DATA_DIR}

  table=$(basename $g .CSV | sed "s/^${f}_//" | tr '[A-Z]' '[a-z]')
  if [[ "${table}" == ${f}_* ]]; then
    table=${table:3}
  fi
  echo "  Loading ${g} into table ${DATABASE}.${table}..."
  psql -d ${DATABASE} -c "\COPY ${table} FROM '${g}' WITH CSV HEADER DELIMITER AS ',' NULL AS '' ENCODING 'UTF-8'"







# FIA database dump

export PATH="/Applications/Postgres.app/Contents/Versions/9.4/bin/":$PATH
WORK_DIR="/Volumes/Gonzo/Pecan/FIA/"  

cd ${WORK_DIR}
OUTFILE=${DATABASE}.gz

pg_dump -v ${DATABASE} -Ox | gzip > ${OUTFILE}


# Inspect
gunzip -c ${OUTFILE} > ${DATABASE}.Ox.txt


# Reload

NEWDB=fia5data_testrestore
createdb ${NEWDB}
gunzip -c $OUTFILE | psql -d ${NEWDB}