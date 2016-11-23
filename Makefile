up:
	docker-compose up -d

down:
	docker-compose down

install: create-database create-config extract up

extract:
	docker-compose run --user `id -u`:`id -g` --rm --no-deps worldserver /scripts/extract.sh

TDB_RELEASE=TDB335.62
TDB=TDB_full_335.62_2016_10_17
GIT=https://raw.githubusercontent.com/TrinityCore/TrinityCore/3.3.5
INITDB_PATH=mount/initdb

create-database:
	mkdir -p ${INITDB_PATH}
	curl ${GIT}/sql/create/create_mysql.sql | sed 's/localhost/%/g' > ${INITDB_PATH}/01_create.sql
	echo "USE auth;" > ${INITDB_PATH}/02_auth_database.sql
	curl ${GIT}/sql/base/auth_database.sql >> ${INITDB_PATH}/02_auth_database.sql
	echo "USE characters;" > ${INITDB_PATH}/03_characters_database.sql
	curl ${GIT}/sql/base/characters_database.sql >> ${INITDB_PATH}/03_characters_database.sql
	wget https://github.com/TrinityCore/TrinityCore/releases/download/${TDB_RELEASE}/${TDB}.7z
	p7zip -d ${TDB}.7z
	mv ${TDB}/TDB_full_world_.sql ${INITDB_PATH}/04_world.sql
	sed -i '1iUSE world;' ${INITDB_PATH}/04_world.sql
	rm -rf ${TDB}


create-config:
	mkdir -p etc
	curl ${GIT}/src/server/authserver/authserver.conf.dist | \
	sed 's/LogsDir =.*/LogsDir = "..\/log"/g' | \
	sed 's/Updates.AutoSetup.*=.*/Updates.AutoSetup = 0/g' | \
	sed 's/Appender.Console.*=.*/Appender.Console = 0,0,0/g' | \
	sed 's/Appender.Auth.*=.*/Appender.Auth=2,2,1,auth.log,a/g' | \
	sed 's/LoginDatabaseInfo = ".*"/LoginDatabaseInfo = "db;3306;trinity;trinity;auth"/g' > etc/authserver.conf

	curl ${GIT}/src/server/worldserver/worldserver.conf.dist | \
	sed 's/LogsDir =.*/LogsDir = "..\/log"/g' | \
	sed 's/DataDir =.*/DataDir = "..\/data"/g' | \
	sed 's/mmap.enablePathFinding = 0/mmap.enablePathFinding = 1/g' | \
	sed 's/SkipCinematics = 0/SkipCinematics = 2/g' | \
	sed 's/Updates.AutoSetup.*=.*/Updates.AutoSetup = 0/g' | \
	sed 's/Console.Enable = 1/Console.Enable = 0/g' | \
        sed 's/Ra.Enable = 0/Ra.Enable = 1/g' | \
	sed 's/Appender.Console.*=.*/Appender.Console=0,0,0/g' | \
	sed 's/Appender.Server.*=.*/Appender.Server=2,2,1,server.log,a/g' | \
	sed 's/Appender.GM.*=.*/Appender.GM=0,0,0/g' | \
	sed 's/Appender.DBErrors.*=.*/Appender.DBErrors=0,0,0/g' | \
	sed -e 's/\(Login\|World\|Character\|Hotfix\)DatabaseInfo\([ ]*\)= "[^;]*\(.*\)"/\1DatabaseInfo\2= "db\3"/g' > etc/worldserver.conf

