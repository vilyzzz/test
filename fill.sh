#!/bin/bash
# Author Vilius A.
. config.priv

if [[ "x${1}" = "xinit" ]]
then
	SRV=7
	mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} -e "CREATE DATABASE ${DB};"
	mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} ${DB} -e "CREATE TABLE numbers (id int NOT NULL PRIMARY KEY, number int NOT NULL);"
	mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} ${DB} -e "CREATE TABLE strings (id int NOT NULL PRIMARY KEY, number varchar(100) NOT NULL);"
	mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} ${DB} -e "CREATE TABLE stats (id varchar(5), number int NOT NULL);"
	mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} ${DB} -e "CREATE TABLE logs (id int NOT NULL PRIMARY KEY, server varchar(20), pos int, number int);"
	for i in `seq 1 9`
	do 
		mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} ${DB} -e "insert into numbers (id) values (${i});"
		mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} ${DB} -e "insert into strings (id) values (${i});"
	done
	mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} ${DB} -e "insert into stats (id) values ('all');"
	mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} ${DB} -e "insert into stats (id) values ('even');"
	mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} ${DB} -e "insert into stats (id) values ('odd');"
	mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} ${DB} -e "insert into logs (id) values (0);"
	exit 0
fi

while true
do 

	SRV=$(( RANDOM % 3 +6))
	NR=$(( RANDOM % 9 +1 ))
	SLEEP=$(( RANDOM % 2 ))
	NUMBER=$RANDOM

	mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} ${DB} -e "update numbers set number=${NUMBER} where id=${NR};"
	mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} ${DB} -e "update strings set number=cast(${NUMBER} AS char) where id=${NR};"
	mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} ${DB} -e "update stats set number=number+1 where id='all';"
	if [[ $[${NR}%2] -eq 0 ]]
	then 
		mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} ${DB} -e "update stats set number=number+1 where id='even';"
	fi
	if [[ $[${NR}%2] -eq 1 ]]
	then 
		mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} ${DB} -e "update stats set number=number+1 where id='odd';"
	fi

	mysql -h "${HOSTPREFIX}24${SRV}" -u ${USER} -p${PASS} ${DB} -e "insert into logs (id, server, pos, number) values ( ((SELECT nid FROM (SELECT max(id)+1 AS nid FROM logs ) AS x)), '${HOSTPREFIX}15${SRV}','${NR}','${NUMBER}');"
	sleep ${SLEEP}

done
