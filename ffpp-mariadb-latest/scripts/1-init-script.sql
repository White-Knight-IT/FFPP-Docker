/* We grant ffppapiservice all permissions to ONLY the ffpp database and its children.
This allows EF Core to use the account to build/update the tables and do all the things */

GRANT ALL ON ffpp.* TO '${ARG_MARIADB_USER}'@'%';

/* Commits the changes we just made into the DB */
FLUSH PRIVILEGES;
