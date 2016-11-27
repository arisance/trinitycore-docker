FROM ubuntu:xenial

# install requirements
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends mysql-client git cmake make gcc g++ libmysqlclient-dev libssl-dev libbz2-dev libreadline-dev libncurses-dev libboost-dev libboost-thread-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-iostreams-dev curl wget p7zip
RUN mkdir -p /opt/trinitycore/build

# create database
ENV GIT=https://raw.githubusercontent.com/TrinityCore/TrinityCore/3.3.5
ENV TDB_RELEASE=TDB335.62
ENV TDB=TDB_full_335.62_2016_10_17
RUN curl ${GIT}/sql/create/create_mysql.sql | sed 's/localhost/%/g' > /opt/trinitycore/db/01_create.sql && \
    echo "USE auth;" > /opt/trinitycore/db/02_auth_database.sql && \
    curl ${GIT}/sql/base/auth_database.sql >> /opt/trinitycore/db/02_auth_database.sql && \
    echo "USE characters;" > /opt/trinitycore/db/03_characters_database.sql && \
    curl ${GIT}/sql/base/characters_database.sql >> /opt/trinitycore/db/03_characters_database.sql && \
    wget https://github.com/TrinityCore/TrinityCore/releases/download/${TDB_RELEASE}/${TDB}.7z && \
    p7zip -d ${TDB}.7z && \
    mv ${TDB}/TDB_full_world_*.sql /opt/trinitycore/db/04_world.sql && \
    sed -i '1iUSE world;' /opt/trinitycore/db/04_world.sql && \
    rm -rf ${TDB}
ADD 05_admin_account.sql /opt/trinitycore/db

# create config
RUN curl ${GIT}/src/server/authserver/authserver.conf.dist | \
    sed 's/LogsDir =.*/LogsDir = "..\/log"/g' | \
    sed 's/Updates.AutoSetup.*=.*/Updates.AutoSetup = 0/g' | \
    sed 's/Appender.Console.*=.*/Appender.Console = 0,0,0/g' | \
    sed 's/Appender.Auth.*=.*/Appender.Auth=2,2,1,auth.log,a/g' | \
    sed 's/LoginDatabaseInfo = ".*"/LoginDatabaseInfo = "db;3306;trinity;trinity;auth"/g' > /opt/trinitycore/etc/authserver.conf && \
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
    sed -e 's/\(Login\|World\|Character\|Hotfix\)DatabaseInfo\([ ]*\)= "[^;]*\(.*\)"/\1DatabaseInfo\2= "db\3"/g' > /opt/trinitycore/etc/worldserver.conf

# compile sources
RUN git clone -b 3.3.5 git://github.com/TrinityCore/TrinityCore.git /opt/trinitycore/sources
WORKDIR /opt/trinitycore/build
RUN cmake ../sources -DTOOLS=1 -DWITH_DYNAMIC_LINKING=ON -DSCRIPTS=dynamic -DUSE_COREPCH=1 -DUSE_SCRIPTPCH=1 -DCMAKE_INSTALL_PREFIX=/opt/trinitycore -DCONF_DIR=/opt/trinitycore/etc
RUN make -j$(nproc)
RUN make -j$(nproc) install

# configuration
WORKDIR /opt/trinitycore
RUN sed -e 's/DataDir = "."/DataDir = "..\/data"/g; s/LogsDir = ""/LogsDir = "..\/log"/g; s/\(Login\|World\|Character\|Hotfix\)DatabaseInfo\([ ]*\)= "[^;]*\(.*\)"/\1DatabaseInfo\2= "db\3"/g' etc/worldserver.conf.dist > etc/worldserver.conf

ADD scripts /scripts
