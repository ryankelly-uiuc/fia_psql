# ----- SET PATH ----------------------------------------------------------------------- #
  # If your PSQL installation is new, may need to add PSQL binaries to the PATH using:
  export PATH="path_to_psql_bin":$PATH

  # E.g.:
  # export PATH="/Library/PostgreSQL/9.4/bin/":$PATH
  export PATH="/Applications/Postgres.app/Contents/Versions/9.4/bin/":$PATH

  # As you may know, this can be added to a dotfile like .bashrc so that the PSQL utilities are always available to you from the command line. Just runnint the command once will work for now. 



# ----- EXAMPLE 1: IMPORT PSQL DATABASE ------------------------------------------------ #
  # If you've downloaded a complete PSQL version of the FIA database, it's simple to import to your own PSQL server.

  # The version we've currently made available is used in PEcAn. To use it, you'll first need to add two roles used by the PEcAn software:
    createuser -P bety
    createuser -P rkooper

  # First create a database to hold the FIA data
    DATABASE="fia5data"   # Set this name to whatever you want
    dropdb --if-exists ${DATABASE}
    createdb ${DATABASE}

  # Now import the gzipped data file (file "fia5data.psql.gz" available at https://duke.box.com/macrosystems-FIA)
    PSQL_FILE=""   # Set this to the correct path to the gzipped psql file
    gzcat ${PSQL_FILE} | psql -d ${DATABASE}



# ----- EXAMPLE 2: IMPORT RAW DATA ----------------------------------------------------- #
  # If for any reason you want to download the raw FIA data in .csv format, you can import it this way.
  
  # First change these database settings as appropriate, then create the database on your server
    USERNAME=""             # PSQL username
    DATABASE="fia5data2"     # Desired database name
    
    dropdb --if-exists ${DATABASE}
    createdb ${DATABASE}

  # Then download or make your own version of the FIA database shell (see tutorial), and create an empty PSQL database from it:
    # Path to the database shell, e.g. .../FIADB_version5_1.psql
    DB_PSQLDUMP=""

    # Import. Note, you may get 'notices' here warning that tables don't exist. These are normal and can be ignored. 
    psql -U ${USERNAME} -d ${DATABASE} < ${DB_PSQLDUMP}


  # Now can import .csv files downloaded from DataMart. 
    # Path to where the .csv files are (need to download them first)
    DATA_DIR=""  

    # List of files (without .csv extension) to import. Several examples are provided, but only set once:
      # A list of all individual states, along with the FIADB_REFERENCE
      FILES="FIADB_REFERENCE AK AL AR AZ CA CO CT DE FL GA IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA PR RI SC SD TN TX UT VA VI VT WA WI WV WY"

      # A subset of state data
      FILES="AK IL MA NC"

      # The full database downloaded as the single file ENTIRE.csv
      FILES="ENTIRE"

  # Code (based on R. Kooper's PEcAn implementation) to loop over all files, unzipping them, importing them into the (currently empty) PSQL database, and then deleting the unzipped data

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
      rm -rf $f # Delete unzipped data
    done

