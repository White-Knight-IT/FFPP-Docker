/* Allow ffppapiservice user to connect from the local docker container */
CREATE USER 'ffppapiservice'@'localhost' IDENTIFIED BY 'wellknownpassword';

/* Allow ffppapiservice user to connect from the local docker network. This
is required so we can communicate with tyhe DB from another docker container. */
CREATE USER 'ffppapiservice'@'172.17.0.0/255.255.0.0' IDENTIFIED BY 'wellknownpassword';

/* We grant ffppapiservice all permissions to ONLY the ffpp database and its children. 
This allows EF Core to use the account to build/update the tables and do all the things */

GRANT ALL ON ffpp.* TO 'ffppapiservice'@'localhost';
GRANT ALL ON ffpp.* TO 'ffppapiservice'@'172.17.0.0/255.255.0.0';

/* Commits the changes we just made into the DB */
FLUSH PRIVILEGES;
