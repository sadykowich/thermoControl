#!/bin/sh

#################################################################################
# segéd változók a JSON tartalom összeállításához
#################################################################################

sJSONItemStart="{"
sJSONItemEnd="}"
sJSONSeparator=","
sJSONString="\""
sJSONItemNameIpAddress="\"ipAddress\": "
sJSONItemNameTimeStamp="\"timeStamp\": "
sJSONItemNameValue="\"value\": "

sNewLine="\n"
sCarryReturn="\r"
sEmpty=""
sFileNameLastSuccess=""

#################################################################################
# lekérdezzük az aktuális hõmérséklet értéket
# paraméterek:
#	$1: ip cím és port szám (pl. "192.168.1.168:80")
#	$2: JSON adatsor szeparátor (pl. ",")
#################################################################################

getThermostat () {
	STR1="$1;"
	STR2=$(date +'%H:%M:%S')
	STR21=$(date +'%Y.%m.%d. ')
	STR3=";"
	STR4="`wget -qO- http://$1`"
	# STR5=${STR4/$sNewLine/$sEmpty}
	# STR6=${STR5/$sCarryReturn/$sEmpty}

	STR8=$STR1$STR21$STR2$STR3$STR4
	STR9=$STR2$STR3$STR4

	var=$1
	replace="_"
	STR11=${var//./$replace}
	sFileName=${STR11//:/$replace}
	# echo $STR12

	echo $STR9 > /www/thermo_control/thermo_${sFileName}_last.log

	# echo $STR8 >> /www/thermo_control/thermo_last.log

	# echo $STR1 >> /www/thermo_control/thermo_last.log
	# echo $STR21 >> /www/thermo_control/thermo_last.log
	# echo $STR2 >> /www/thermo_control/thermo_last.log
	# echo $STR3 >> /www/thermo_control/thermo_last.log
	# echo $STR4 >> /www/thermo_control/thermo_last.log

	sJSONItem=$sJSONItemStart$sJSONItemNameIpAddress$sJSONString$1$sJSONString$sJSONSeparator$sJSONItemNameTimeStamp$sJSONString$STR21$STR2$sJSONString$sJSONSeparator$sJSONItemNameValue$sJSONString$STR4$sJSONString$sJSONItemEnd
	echo $sJSONItem >> /www/thermo_control/thermo_last.log

	sFileNameLastSuccess="/www/thermo_control/thermo_${sFileName}_last_success.log"
	sizeSTR4=${#STR4}
	if [ $sizeSTR4 -ge 5 ]; then
		STR41=${STR4:0:5}
		echo "		"$sJSONItemStart > ${sFileNameLastSuccess}
		echo "			"$sJSONItemNameIpAddress$sJSONString$1$sJSONString$sJSONSeparator >> ${sFileNameLastSuccess}
		echo "			"$sJSONItemNameTimeStamp$sJSONString$STR21$STR2$sJSONString$sJSONSeparator >> ${sFileNameLastSuccess}
		echo "			"$sJSONItemNameValue$sJSONString$STR41$sJSONString >> ${sFileNameLastSuccess}
		echo "		"$sJSONItemEnd$2 >> ${sFileNameLastSuccess}
	fi

	# wget 192.168.1.168:80 --output-document=/www/thermo_control/wget.log -O - > /www/thermo_control/thermo_value.log
	# cat /www/thermo_control/thermo_value.log >> /www/thermo_control/thermo.log

	cat /www/thermo_control/thermo_${sFileName}_last.log >> /www/thermo_control/thermo_${sFileName}_$(date +'%Y%m%d').log
}

#################################################################################
sJSONStart="{"
sJSONStart2="\"thermometers\": ["
sJSONEnd="]"
sJSONEnd2="}"

#################################################################################
echo $sJSONStart > /www/thermo_control/thermo_last.log

getThermostat 192.168.1.168:80 $sJSONSeparator
sFileNameLastSuccess01=$sFileNameLastSuccess;
echo $sJSONSeparator >> /www/thermo_control/thermo_last.log

getThermostat 192.168.1.166:80 $sJSONSeparator
sFileNameLastSuccess02=$sFileNameLastSuccess;
echo $sJSONSeparator >> /www/thermo_control/thermo_last.log

getThermostat 192.168.1.165:80 $sJSONSeparator
sFileNameLastSuccess03=$sFileNameLastSuccess;
echo $sJSONSeparator >> /www/thermo_control/thermo_last.log

getThermostat 192.168.1.164:80 ""
sFileNameLastSuccess99=$sFileNameLastSuccess;

echo $sJSONEnd >> /www/thermo_control/thermo_last.log

#################################################################################
# az utolsó érvényes leolvasásokból összeállítjuk a JSON tartalmat:
#################################################################################

echo $sJSONStart > /www/thermo_control/thermo_last_success.log
echo "	"$sJSONStart2 >> /www/thermo_control/thermo_last_success.log
cat ${sFileNameLastSuccess01} >> /www/thermo_control/thermo_last_success.log
cat ${sFileNameLastSuccess02} >> /www/thermo_control/thermo_last_success.log
cat ${sFileNameLastSuccess03} >> /www/thermo_control/thermo_last_success.log
cat ${sFileNameLastSuccess99} >> /www/thermo_control/thermo_last_success.log
echo "	"$sJSONEnd >> /www/thermo_control/thermo_last_success.log
echo $sJSONEnd2 >> /www/thermo_control/thermo_last_success.log

#################################################################################