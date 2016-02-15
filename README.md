This is a docker container that runs mariadb, but also has mydumper and myloader binaries available inside the container.

You can use this for simple database imports/exports/backups via docker exec commands.

After compiling mydumper, I should probably remove all the prerequisite software that gets installed...call it a feature request :)
