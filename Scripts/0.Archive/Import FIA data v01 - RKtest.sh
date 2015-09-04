# ----- SET PATH ----------------------------------------------------------------------- #
# If your PSQL installation is new, may need to add PSQL binaries to your PATH (replace quoted path to point to your PSQL binary):
  export PATH="path/to/psql/bin":$PATH

  # Of course, you can add this to .bashrc or equivalent so you won't have to do it every time.


# ----- EXAMPLE 1: IMPORT PSQL DATABASE ------------------------------------------------ #
# If you've downloaded a complete PSQL version of the FIA database, it's simple to import to your own PSQL server.

  # The version of the database we've currently made available is from PEcAn. To use it, you'll first need to add two PSQL roles used by the PEcAn software (create passwords as prompted):
    createuser -P bety
    createuser -P kooper

  # Create a database to hold the FIA data
    # Set a name for the database.
    DATABASE="fia5data_pecan" 
    
    # Delete the database if it exists already. 
    # *** Careful! Only do this is you really mean it! ***
    # If the database doesn't exist and you run this, a harmless warning will print.
    dropdb --if-exists ${DATABASE}
    
    # Now create the new database with the name set above
    createdb ${DATABASE}


  # Import the gzipped data file, i.e. file "fia5data.psql.gz" available at
  #   https://duke.box.com/s/43rhgem97tl3gi6aywwj3tlsbbrj65xa
    PSQL_FILE="/Volumes/Gonzo/Pecan/FIA/fia5data.psql.gz"   # Set this to the correct path to the gzipped psql file
    gzcat ${PSQL_FILE} | psql -d ${DATABASE}



# ----- EXAMPLE 2: IMPORT RAW DATA ----------------------------------------------------- #
 # If for any reason you want to download the raw FIA data in .csv format, you can import it this way.

  export PATH="/Applications/Postgres.app/Contents/Versions/9.4/bin/":$PATH

  # Create a database to hold the FIA data
    # Set a name for the database.
    DATABASE="fia5data_csvimport10"     # Desired database name

    # Delete the database if it exists already. 
    # *** Careful! Only do this is you really mean it! ***
    # If the database doesn't exist and you run this, a harmless warning will print.
    dropdb --if-exists ${DATABASE}

    # Now create the new database with the name set above
    createdb ${DATABASE}

  # Create an empty PSQL database from the FIA schema, obtained by either:
  #  1. Downloading and converting the MS Access schema available directly from USFS at
  #     http://apps.fs.fed.us/fiadb-downloads/images/FIADB_version5_1.accdb
  #  2. Download an already converted copy, current as of Feb. 2015, at
  #     https://duke.box.com/s/sz6jz8oejkkdhxt4e7ej3zaz5gsmbhmg

    # Specify path to the PSQL schema, e.g. .../FIADB_version5_1.psql
    DB_PSQLDUMP="/Volumes/Gonzo/Pecan/FIA/FIADB_version5_1_RKedit01.psql"

    # Import schema. Note, you may get 'notices' here warning that tables don't exist. These are normal and can be ignored. 
    psql -d ${DATABASE} < ${DB_PSQLDUMP}

  # Now import .csv files containing the FIA data, obtained by either:
  #  1. Downloading zipped .csv files from FIA DataMart at
  #     http://apps.fs.fed.us/fiadb-downloads/datamart.html
  #  2. Downloading the entire database in one big .zip archive, current as of Feb. 2015, at:
  #     https://duke.box.com/s/4x4s5u0obploc2ttl07tvi0ii9d8nrjc
  #     * Note this same file ("ENTIRE.zip") is available from the DataMart website (scroll
  #       to very bottom of the page), but that site is very slow. 

  # Regardless of where the files were obtained, unzip them and point to the directory 
  # containg the .csv files here:
    DATA_DIR="/Volumes/Gonzo/Pecan/FIA/ENTIRE/"
#     DATA_DIR="/Volumes/Gonzo/Pecan/FIA/FIADB_REFERENCE/"

  # Now loop over all of the .csv files and import each into the (currently empty) PSQL database
    cd ${DATA_DIR}

    for g in ./*.CSV; do
      table=$(basename $g .CSV | sed "s/^${f}_//" | tr '[A-Z]' '[a-z]')
      if [[ "${table}" == ${f}_* ]]; then
        table=${table:3}
      fi
      echo "  Loading ${g} into table ${DATABASE}.${table}..."
     psql -d ${DATABASE} -c "\COPY ${table} FROM '${g}' WITH CSV HEADER DELIMITER AS ',' NULL AS '' ENCODING 'WIN1252'"
    done


# 7z e -oENTIRE2 ENTIRE.zip