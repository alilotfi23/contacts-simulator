#!/bin/bash

# Define the database file name
DATABASENAME="personalcontact.db"

# SQL command to create the CONTACT table if it doesn't exist
CREATESQL='CREATE TABLE CONTACT(ID INTEGER PRIMARY KEY AUTOINCREMENT,NAME VARCHAR(30),FAMILY VARCHAR(60),MOBILEPHONE INTEGER,HOMEPHONE INTEGER,MAIL VARCHAR(70),DEL INTEGER);'

# Path to the sqlite3 binary
SQLITPATH='/usr/bin/sqlite3'

# Check if sqlite3 is installed, if not, prompt the user to install and exit
if [[ ! -e $SQLITPATH ]]; then
  echo "First install sqlite3..."
  exit 1
fi

# Check if the database file exists, if not, create it using the SQL command
if [[ ! -e $DATABASENAME ]]; then
  echo $CREATESQL | sqlite3 $DATABASENAME
fi

# Function to insert new contacts into the database
insert () {
  clear
  echo "Each CONTACT Requires the Following Information: (* is Necessary)"
  echo "CONTACT Name(*), CONTACT FAMILY(*), CONTACT MOBILE NUMBER(*), CONTACT HOME NUMBER(*), CONTACT e-MAIL(*)"
  echo -e "---------------------------------------------------------------"
  
  # Continue inserting contacts until the user decides to stop
  CONDITON=true
  while [[ $CONDITON == "true" ]]; do
    _dataValidationCheck=0
    _dataDuplicationCheck=0
    
    # Prompt the user for contact details
    read -p " Enter CONTACT Name: " NAME
    read -p " Enter CONTACT Family: " FAMILY
    read -p " Enter CONTACT MOBILE PHONE like (+98935***1133): " MOBILEPHONE
    read -p " Enter CONTACT HOME PHONE like (02144113309): " HOMEPHONE
    read -p " Enter CONTACT E-Mail: " MAIL
    
    # Validate the entered data and check for duplication
    data_validation_check
    data_duplication_check
    
    # If validation and duplication checks pass, insert the contact into the database
    if [ $_dataValidationCheck -eq 0 -a  $_dataDuplicationCheck -eq 0 ]; then
      rowCount=`echo "SELECT COUNT(*) FROM CONTACT;" | sqlite3 $DATABASENAME`
      rowCount=$((rowCount+1))
      echo "INSERT INTO CONTACT VALUES ('$rowCount','$NAME','$FAMILY','$MOBILEPHONE','$HOMEPHONE','$MAIL','0');" | sqlite3 $DATABASENAME
      
      # Check if the insert operation was successful
      if [ $? -eq 0 ]; then
        echo "Insert completed..."
        sleep 2
      fi
    fi
    
    # Ask the user if they want to continue adding contacts
    read -p "Do You Want to continue? (yes/no)" ans
    if [[ $ans == "yes" ]]; then
      continue
    else
      CONDITON=false
    fi
  done
}

# Function to validate the input data
data_validation_check () {
  # Convert NAME, FAMILY, and MAIL to lowercase
  NAME=`echo "${NAME,,}"`
  FAMILY=`echo "${FAMILY,,}"`
  MAIL=`echo "${MAIL,,}"`
  
  # Validate each field with regex patterns
  if [[ ! $NAME =~ ^[a-z][0-9a-z]*$ ]]; then
    _dataValidationCheck=1
    echo "Name Not Accepted..."
  fi
  if [[ ! $FAMILY =~ ^[a-z][0-9a-z]*$ ]]; then
    _dataValidationCheck=1
    echo "Family Not Accepted..."
  fi
  if [[ ! $MOBILEPHONE =~ ^\+98[9]{1}[0-9]{9}$ ]]; then
    _dataValidationCheck=1
    echo "Mobile Number Not Accepted..."
  fi
  if [[ ! $HOMEPHONE =~ ^\0[1-9][1-9]{1}[0-9]{8}$ ]]; then
    _dataValidationCheck=1
    echo "Home Number Not Accepted..."
  fi
  if [[ ! $MAIL =~ [a-z0-9._-]+@[a-z0-9.-]+\.[a-z]{2,4} ]]; then
    _dataValidationCheck=1
    echo "EMAIL Not Accepted..."
  fi
}

# Function to check if the contact is a duplicate
data_duplication_check () {
  recordName=`echo "SELECT NAME FROM CONTACT WHERE FAMILY = '$FAMILY' AND NAME = '$NAME' AND DEL = '0';" | sqlite3 $DATABASENAME`
  
  # If a record with the same name and family exists, mark it as a duplicate
  if [[ -n $recordName ]]; then
    _dataDuplicationCheck=1
    echo "Contact Family & Name Are Duplicate...."
  fi
}

# Function to display the list of contacts
show_list () {
  rowCount=`echo "SELECT COUNT(*) FROM CONTACT;" | sqlite3 $DATABASENAME`
  
  # If the table has records, display them
  if [[ $rowCount -ne 0 ]]; then
    clear
    echo "Database CONTACT Content: "
    echo "----------------------------------"
    echo "SELECT ID,NAME,FAMILY,MOBILEPHONE,HOMEPHONE,MAIL FROM CONTACT WHERE DEL = '0';" | sqlite3 $DATABASENAME
    echo -e "----------------------------------\n"
  else
    echo "Database Is Empty..."
  fi
}

# Function to search for a contact by name and family
search_contact () {
  contactRecordID=0
  echo "Find CONTACT: "
  read -p "Enter Your Contact Family: " search_family
  read -p "Enter Your Contact Name: " search_name
  contactRecordID=`echo "SELECT ID FROM CONTACT WHERE FAMILY = '$search_family' AND NAME = '$search_name' AND DEL = '0';" | sqlite3 $DATABASENAME`
  return $contactRecordID
}

# Function to modify an existing contact
modifyContact() {
  modifyContactRecordID=0
  echo "You Are Modifying This Contact:"
  echo " SELECT NAME,FAMILY,MOBILEPHONE,HOMEPHONE,MAIL FROM CONTACT WHERE ID ='$1';" | sqlite3 $DATABASENAME
  echo -e "\n-------------------------------------------------------"
  
  # Prompt for new details
  read -p " Enter CONTACT Name: " NAME
  read -p " Enter CONTACT Family: " FAMILY
  read -p " Enter CONTACT MOBILE PHONE like (+98935***1133): " MOBILEPHONE
  read -p " Enter CONTACT HOME PHONE like (02144113309): " HOMEPHONE
  read -p " Enter CONTACT E-Mail: " MAIL
  
  _dataValidationCheck=0
  _dataDuplicationCheck=0
  
  # Validate and check duplication before updating
  data_validation_check
  data_duplication_check
  if [ $_dataValidationCheck -eq 0 -a  $_dataDuplicationCheck -eq 0 ]; then
    echo " UPDATE CONTACT SET NAME='$NAME',FAMILY='$FAMILY',MOBILEPHONE='$MOBILEPHONE',HOMEPHONE='$HOMEPHONE',MAIL='$MAIL' WHERE ID ='$1';" | sqlite3 $DATABASENAME
    echo "Contact Modified..."
  fi
}

# Function to delete a contact (soft delete by setting DEL flag to 1)
delete_contact () {
  echo "You Are Deleting This Contact: "
  echo " SELECT ID,NAME,FAMILY,MOBILEPHONE,HOMEPHONE,MAIL FROM CONTACT WHERE ID='$1';" | sqlite3 $DATABASENAME
  echo -e "-----------------------------------------------------\n"
  
  # Ask for confirmation before deletion
  read -p "Are You Sure ?? (yes/no)" ans2
  if [[ $ans2 == "yes" ]]; then
    echo "UPDATE CONTACT SET DEL =1 WHERE ID='$1';" | sqlite3 $DATABASENAME
    echo "Contact Deleted..."
    sleep 1
  else
    echo "Contact Not Deleted..."
  fi
}

# Function to show the main menu
show () {
  echo "CONTACT Personal Notebook"
  echo -e "-----------------------------------\n"
  echo "Operations:"
  echo "1) Insert Contact  3) Modify Contact   5) Clear Screen"
  echo "2) List Contacts   4) Delete Contact   6) Exit"
}

# Display the notebook header
echo -e "Personal Contact Notebook"
echo -e "-----------------------------------\n"
echo -e "Operation is: \n"

# Main menu for the user to select an action
PS3="Please Select an Option: "
select choice in "Insert Contact" "List Contact" "Modify Contact" "Delete Contact" "Clear Screen" "Exit"
do
  case $REPLY in
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
        modifyContact $returnValue
      else
        echo -e "Contact Not Found\n"
      fi
      show
      ;;
    4)
      search_contact
      returnValue=`echo $?`
      if [[ $returnValue -ne 0 ]]; then
        delete_contact $returnValue
      else
        echo -e "Contact Not Found\n"
      fi
      show
      ;;
    5)
      clear
      show
