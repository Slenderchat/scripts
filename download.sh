#!/bin/bash
echo -n "Введите пожалуйста дату в формате 'год-месяц-число': "
read DATE
TF=$(mktemp)
curl -sL http://10.57.192.200/${DATE}/cam-1/ | sed -n 's/.*\([0-2][0-9]-[0-9][0-9]-[0-9][0-9]\).mp4.*/\1/p' > ${TF}
echo "Укажите границы скачивания в формате: 'часы-минуты'"
echo -n "От: "
read MIN
echo -n "До: "
read MAX
TF2=$(mktemp)
while read -r LINE
do
	if [ ${MIN:0:2} -ne ${MAX:0:2} ]
	then
		if [ ${LINE:0:2} -ge ${MIN:0:2} ] && [ ${LINE:0:2} -le ${MAX:0:2} ]
		then
			if [ ${LINE:0:2} -eq ${MIN:0:2} ]
			then
				if [ ${LINE:3:2} -ge ${MIN:3:2} ]
				then
					echo ${LINE} >> ${TF2}
				fi
			elif [ ${LINE:0:2} -eq ${MAX:0:2} ]
			then
				if [ ${LINE:3:2} -le ${MAX:3:2} ]
				then
					echo ${LINE} >> ${TF2}
				fi
			else
				echo ${LINE} >> ${TF2}
			fi
		fi
	else
		if [ ${LINE:0:2} -eq ${MIN:0:2} ]
		then
			if [ ${LINE:3:2} -ge ${MIN:3:2} ] && [ ${LINE:3:2} -le ${MAX:3:2} ]
			then
				echo ${LINE} >> ${TF2}
			fi
		fi
	fi
done < ${TF}
while read -r LINE
do
	curl -sLO http://10.57.192.200/${DATE}/cam-1/${LINE}.mp4
done < ${TF2}
rm ${TF}
rm ${TF2}
