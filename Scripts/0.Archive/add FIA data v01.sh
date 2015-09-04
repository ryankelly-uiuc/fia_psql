curl -o fia5data.psql.gz http://isda.ncsa.illinois.edu/~kooper/EBI/fia5data.psql.gz

# export PATH="path_to_psql_bin":$PATH
# E.g.:
# export PATH="/Library/PostgreSQL/9.4/bin/":$PATH
export PATH="/Applications/Postgres.app/Contents/Versions/9.4/bin/":$PATH

# As you may know, this can be added to a dotfile like .bashrc so that the PSQL utilities are always available to you from the command line. Just runnint the command once will work for now. 

createuser -P bety
createuser -P rkooper

dropdb --if-exists fia5data
createdb fia5data
gzcat fia5data.psql.gz | psql -d fia5data
# rm fia5data.psql.gz










USERNAME='bety'
DATABASE='fia5data2'
DB_PSQLDUMP='/Volumes/Camilla/Pecan/FIA/FIADB_version5_1.psql'
# DB_PSQLDUMP='/Work/Research/FIA/data.land_copy/contrib/FIA/fiadb5_1.psql'
# export PATH="/Library/PostgreSQL/9.4/bin/":$PATH
export PATH="/Applications/Postgres.app/Contents/Versions/9.4/bin/":$PATH
dropdb --if-exists ${DATABASE}
createdb ${DATABASE}

# Note: May get 'notices' here warning that tables don't exist. These are normal and can be ignored. 
psql -U ${USERNAME} -d ${DATABASE} < ${DB_PSQLDUMP}

DATA_DIR="/Users/ryan/Data/Pecan/FIA/Individual_states"

# FILES="FIADB_REFERENCE AK AL AR AZ CA CO CT DE FL GA IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA PR RI SC SD TN TX UT VA VI VT WA WI WV WY"

# FILES="FIADB_REFERENCE AK AL AR"

DATA_DIR="/Users/ryan/Data/Pecan/FIA/"
FILES="ENTIRE"

cd ${DATA_DIR}

for f in ${FILES}; do
  echo "Unzipping $f..."
  unzip -q -n $f $f

  for g in $f/*.CSV; do
    table=$(basename $g .CSV | sed "s/^${f}_//" | tr '[A-Z]' '[a-z]')
    if [[ "${table}" == ${f}_* ]]; then
      table=${table:3}
    fi
    echo "  Loading ${g} into table ${DATABASE}.${table}..."
    psql -U ${USERNAME} -d ${DATABASE} -c "\COPY ${table} FROM '${g}' WITH CSV HEADER DELIMITER AS ',' NULL AS '' ENCODING 'UTF-8'"

  done
#   rm -rf $f
done

