# FIA database dump
export PATH="/Applications/Postgres.app/Contents/Versions/9.4/bin/":$PATH

DATABASE="fia5data_csvimport10"
OUTFILE="/Volumes/Gonzo/Pecan/FIA/PSQL_dumps/fia5_complete_2015.02.05.gz"

pg_dump -v ${DATABASE} -Ox | gzip -9 > ${OUTFILE}

