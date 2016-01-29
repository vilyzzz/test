#!/bin/bash

. config.priv

while true
do 

	SRV=$(( RANDOM % 3 ))
	NR=$(( RANDOM % 9 ))
	NUMBER=$RANDOM

	mysql -h "${HOSTPREFIX}15${SRV}" -u ${USER} -p${PASS} ${DB} -e "update numbers set number=${NUMBER} where id=${NR};"
	mysql -h "${HOSTPREFIX}15${SRV}" -u ${USER} -p${PASS} ${DB} -e "update strings set number=cast(${NUMBER} AS char) where id=${NR};"
	mysql -h "${HOSTPREFIX}15${SRV}" -u ${USER} -p${PASS} ${DB} -e "update stats set number=number+1 where id='all';"
	if [[ $[${NR}%2] -eq 0 ]]
	then 
		mysql -h "${HOSTPREFIX}15${SRV}" -u ${USER} -p${PASS} ${DB} -e "update stats set number=number+1 where id='even';"
	fi
	if [[ $[${NR}%2] -eq 1 ]]
	then 
		mysql -h "${HOSTPREFIX}15${SRV}" -u ${USER} -p${PASS} ${DB} -e "update stats set number=number+1 where id='odd';"
	fi

	mysql -h "${HOSTPREFIX}15${SRV}" -u ${USER} -p${PASS} ${DB} -e "insert into log (id, server, pos, number) values ( ((SELECT nid FROM (SELECT max(id)+1 AS nid FROM log ) AS x)), '${HOSTPREFIX}15${SRV}','${NR}','${NUMBER}');"

done
