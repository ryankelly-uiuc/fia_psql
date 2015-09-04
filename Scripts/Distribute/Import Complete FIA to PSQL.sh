# ----- IMPORT PSQL DATABASE ----------------------------------------------------------- #
# If you've downloaded a complete PSQL version of the FIA database, it's simple to import to your own PSQL server.

  # Set path to PSQL
  # If your PSQL installation is new, may need to add PSQL binaries to your PATH (replace quoted path to point to your PSQL binary):
    export PATH="path/to/psql/bin":$PATH

    # Of course, you can add this to .bashrc or equivalent so you won't have to do it every time.


  # Create a database to hold the FIA data
    # Set a name for the database.
    DATABASE="fia5data" 
    
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



