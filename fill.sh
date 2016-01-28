#!/bin/bash

[[ -z ${1} ]] && count=400 || count=${1}

while true
do 
	for n  in `seq 1 3 9`
	do
		mysql -h 10.33.234.150 -u root -ppassword test -e "update ttbl set count=$[$count*10+${n}] where id=${n};"
		mysql -h 10.33.234.151 -u root -ppassword test -e "update ttbl set count=$[$count*10+${n}+1] where id=$[${n}+1];"
		mysql -h 10.33.234.152 -u root -ppassword test -e "update ttbl set count=$[$count*10+${n}+2] where id=$[${n}+2];"
		mysql -h 10.33.234.150 -u root -ppassword test -e "update ttbl2 set string=cast($[$count*10+${n}] AS char) where id=${n};"
		mysql -h 10.33.234.151 -u root -ppassword test -e "update ttbl2 set string=cast($[$count*10+${n}+1] AS char) where id=$[${n}+1];"
		mysql -h 10.33.234.152 -u root -ppassword test -e "update ttbl2 set string=cast($[$count*10+${n}+2] AS char) where id=$[${n}+2];"
		mysql -h 10.33.234.152 -u root -ppassword test -e "select * FROM ttbl LEFT JOIN (ttbl2) ON (ttbl.id = ttbl2.id);"
	done
	count=$[$count+1]
	[[ $((${count} % 20 )) -eq 0 ]] && echo sleeping... && sleep 60
done
