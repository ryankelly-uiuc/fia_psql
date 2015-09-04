# ----- IMPORT RAW FIA DATA TO A PSQL DATABASE ----------------------------------------- #
# See accompanying "Converting FIA to PSQL.docx" tutorial for details.

  # Set path to PSQL
  # If your PSQL installation is new, may need to add PSQL binaries to your PATH (replace quoted path to point to your PSQL binary):
#     export PATH="path/to/psql/bin":$PATH
    export PATH="/Applications/Postgres.app/Contents/Versions/9.4/bin/":$PATH

    # Of course, you can add this to .bashrc or equivalent so you won't have to do it every time.


  # Create a database to hold the FIA data
    # Set a name for the database.
    DATABASE="fia5data_testrestore"     # Desired database name

    # Delete the database if it exists already. 
    # *** Careful! Only do this is you really mean it! ***
    # If the database doesn't exist and you run this, a harmless warning will print.
    dropdb --if-exists ${DATABASE}

    # Now create the new database with the name set above
    createdb ${DATABASE}


  # Create an empty database from the FIA schema. 

    # Specify path to the PSQL schema, e.g. .../FIADB_version5_1.psql
    DB_PSQLDUMP="/Volumes/Gonzo/Pecan/FIA/FIADB_version5_1_RKedit01.psql"

    # Import schema. Note, you may get 'notices' here warning that tables don't exist. These are normal and can be ignored. 
    psql -d ${DATABASE} < ${DB_PSQLDUMP}


  # Import .csv files containing the FIA data.
    # We assume all .csv files are unzipped and located in a single directory, specified here:
    DATA_DIR="/Volumes/Gonzo/Pecan/FIA/ENTIRE/"
#     DATA_DIR="/Volumes/Gonzo/Pecan/FIA/FIADB_REFERENCE/"

    # Now we loop over all of the .csv files and import each into the PSQL database
    cd ${DATA_DIR}
    for g in ./*.CSV; do
      table=$(basename $g .CSV | sed "s/^${f}_//" | tr '[A-Z]' '[a-z]')
      if [[ "${table}" == ${f}_* ]]; then
        table=${table:3}
      fi
      echo "  Loading ${g} into table ${DATABASE}.${table}..."
     psql -d ${DATABASE} -c "\COPY ${table} FROM '${g}' WITH CSV HEADER DELIMITER AS ',' NULL AS '' ENCODING 'WIN1252'"
    done
