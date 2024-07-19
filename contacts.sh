#!/bin/bash
DATABASENAME="personalcontact.db"


CREATESQL='CREATE TABLE CONTACT(ID INTEGER PRIMARY KEY AUTOINCREMENT,NAME VARCHAR(30),FAMILY VARCHAR(60),MOBILEPHONE INTEGER,HOMEPHONE INTEGER,MAIL VARCHAR(70),DEL INTEGER);'

SQLITPATH='/usr/bin/sqlite3'

if [[ ! -e $SQLITPATH ]]; then
  echo "First install sqlite3..."
  exit 1
fi
if [[ ! -e $DATABASENAME ]]; then
  echo $CREATESQL | sqlite3 $DATABASENAME
fi
insert ()
{
clear
echo "Each CONTACT Need Below Requirement : (* is Necessary )"
echo "CONTACT Name(*), CONTACT FAMILY(*), CONTACT MOBILE NUMBER(*), CONTACT HOME NUMBER(*), CONTACT e-MAIL(*)"
echo -e "---------------------------------------------------------------"
CONDITON=true
while [[ $CONDITON == "true" ]]; do
  _dataValidationCheck=0
  _dataDuplicationCheck=0
read -p " Enter CONTACT Name: " NAME
read -p " Enter CONTACT Famliy: " FAMILY
read -p " Enter CONTACT MOBILE PHONE like (+98935***1133): " MOBILEPHONE
read -p " Enter CONTACT HOME PHONE like (02144113309): " HOMEPHONE
read -p " Enter CONTACT E-Mail: " MAIL

data_validation_check
data_duplication_check

if [ $_dataValidationCheck -eq 0 -a  $_dataDuplicationCheck -eq 0 ]
then
  rowCount=`echo "SELECT COUNT(*) FROM CONTACT;" | sqlite3 $DATABASENAME`
  rowCount=$((rowCount+1))
  echo "INSERT INTO CONTACT VALUES ('$rowCount','$NAME','$FAMILY','$MOBILEPHONE','$HOMEPHONE','$MAIL','0');" | sqlite3 $DATABASENAME
  if [ $? -eq 0 ]; then #$? khroji dastor gahbli || bray check kardan inke dastor gahab 100% ok bashe
    echo "insert completed..."
    sleep  2
  fi
fi
read -p "Do You Want to continue? (yes/no)" ans
 if [[ $ans == "yes" ]]; then
  continue
 else
  CONDITON=false
  fi
 done
}
#casesensitive
 data_validation_check ()
{
NAME=`echo "${NAME,,}"`
FAMILY=`echo "${FAMILY,,}"`
MAIL=`echo "${MAIL,,}"`
if [[ ! $NAME =~ ^[a-z][0-9a-z]*$ ]]; then
  _dataValidationCheck=1
  echo "Name Not Accepted..."
fi
if [[ ! $FAMILY =~ ^[a-z][0-9a-z]*$ ]]; then
  _dataValidationCheck=1
  echo "Family Not Accepted..."
fi
if [[ ! $MOBILEPHONE =~ ^\+98[9]{1}[0-9]{9}$ ]]; then #+98 9
  _dataValidationCheck=1
  echo "Mobile Number Not Accepted..."
fi
if [[ ! $HOMEPHONE =~ ^\0[1-9][1-9]{1}[0-9]{8}$ ]]; then #0 2 1
  _dataValidationCheck=1
  echo "Home Number Not Accepted..."
fi
if [[ ! $MAIL =~ [a-z0-9._-]+@[a-z0-9.-]+\.[a-z]{2,4} ]]
then
  _dataValidationCheck=1
  echo "EMAIL Not Accepted..."
fi
}

  data_duplication_check ()
  {
    recordName=`echo "SELECT NAME FROM CONTACT WHERE FAMILY = '$FAMILY' AND NAME = '$NAME' AND DEL = '0';"| sqlite3 $DATABASENAME`
 if [[ -n $recordName ]]
 then
   _dataDuplicationCheck=1
   echo "Contact Family & Name Are Duplicate...."
 fi
  }

show_list ()
{
  rowCount=`echo "SELECT COUNT(*) FROM CONTACT;" | sqlite3 $DATABASENAME`
   if [[ $rowCount -ne 0 ]]
   then
     clear
     echo "Database CONTACT Content: "
     echo "----------------------------------"
     echo "SELECT ID,NAME,FAMILY,MOBILEPHONE,HOMEPHONE,MAIL FROM CONTACT WHERE DEL = '0';" | sqlite3 $DATABASENAME
     echo -e "----------------------------------\n"
   else
     echo "Database Is Empty..."
   fi
}



search_contact ()
{
  contactRecordID=0
  echo "Find CONTACT: "
  read -p "Enter Your Contact Family: " search_family
  read -p "Enter Your Contact Name: " search_name
  contactRecordID=`echo "SELECT ID FROM CONTACT WHERE FAMILY = '$searchFamily' AND NAME = '$searchName' AND DEL = '0';" | sqlite3 $DATABASENAME`
  return $contactRecordID
}
modifyContact()
{
modifyContactRecordID=0
echo "You Are Modify This Contact:"
echo " SELECT NAME,FAMILY,MOBILEPHONE,HOMEPHONE,MAIL FROM CONTACT WHERE ID ='$1';" | sqlite3 $DATABASENAME
echo -e "\n-------------------------------------------------------"
read -p " Enter CONTACT Name: " NAME
read -p " Enter CONTACT Famliy: " FAMILY
read -p " Enter CONTACT MOBILE PHONE like (+98935***1133): " MOBILEPHONE
read -p " Enter CONTACT HOME PHONE like (02144113309): " HOMEPHONE
read -p " Enter CONTACT E-Mail: " MAIL
_dataValidationCheck=0
_dataDuplicationCheck=0
data_validation_check
data_duplication_check
if [ $_dataValidationCheck -eq 0 -a  $_dataDuplicationCheck -eq 0 ]; then
echo " UPDATE CONTACT SET NAME='$NAME',FAMILY='$FAMILY',MOBILEPHONE='$MOBILEPHONE',HOMEPHONE='$HOMEPHONE',MAIL='$MAIL'WHERE ID ='$1';" | sqlite3 $DATABASENAME
echo "Contact Modified..."
fi
}
delete_contact ()
{
echo " You Are Deleting This Contact: "
echo " SELECT ID,NAME,FAMILY,MOBILEPHONE,HOMEPHONE,MAIL FROM CONTACT WHERE ID='$1';" | sqlite3 $DATABASENAME
echo -e "-----------------------------------------------------\n"
read -p " Are Your Sure ?? (yes/no)" ans2
if [[ $ans2 == "yes" ]]; then
  echo "UPDATE CONTACT SET DEL =1 WHERE ID='$1';" | sqlite3 $DATABASENAME
  echo " Contact Deleted..."
  sleep 1
else
  echo "Contact Not Deleted..."
fi
}
show ()
{
  echo " CONTACT Personal NoteBook "
  echo -e "-----------------------------------\n"
  echo "Operation is: "
  echo "1) Insert Contact  3) Modify Contact   5) Clear Screen"
  echo "2) List Contacts   4) Delete Contact   6) Exit"
}

echo -e " personal contact notebook "
echo -e "-----------------------------------\n"
echo -e " Operation is: \n "
PS3="PLZ Select Item: "
select choice in "Insert Contact" "List Contact" "Modify Contact" "Delete Contact" "Clear Screen" "Exit"
do
case $REPLY  in
1)
insert
show
;;
2)
show_list
show
;;
3)
search_contact
returnValue=`echo $?`
if [[ $returnValue -ne 0 ]]; then
  modify_contact $returnValue
else
  echo -e  "Contact Not Found\n"
fi
show
;;
4)
 search_contact
    returnValue=`echo $?`
 if [[ $returnValue -ne 0 ]]; then
   delete_contact $returnValue
 else
   echo -e "Contact Not Delete\n"
 fi
 show
 ;;
5)
clear
show
;;
6)
echo "--------------------------BYE------------------------------"
exit 0
;;
*)
echo "Incorrect Choice"
esac
done
