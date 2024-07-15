# Personal Contact Notebook

## Overview

Personal Contact Notebook is a Bash script to manage a personal contact database using SQLite. It allows you to insert, list, modify, and delete contacts. This tool provides a simple CLI interface to interact with your contacts database.

## Prerequisites

- `sqlite3` must be installed on your system. You can install it using your package manager. For example, on Ubuntu, you can install it using:
  ```bash
  sudo apt-get install sqlite3
  ```

## Usage

1. **Insert Contact**
2. **List Contacts**
3. **Modify Contact**
4. **Delete Contact**
5. **Clear Screen**
6. **Exit**

## Script Details

### Script Variables

- `DATABASENAME`: The name of the SQLite database file. Default is `personalcontact.db`.
- `CREATESQL`: SQL statement to create the `CONTACT` table if it does not exist.
- `SQLITPATH`: Path to the `sqlite3` executable. Default is `/usr/bin/sqlite3`.

### Functions

- **insert()**: Inserts a new contact into the database.
- **showlist()**: Lists all contacts in the database.
- **searchContact()**: Searches for a contact by name and family.
- **modifyContact()**: Modifies an existing contact.
- **deleteContact()**: Deletes a contact.
- **datavalidationcheck()**: Validates the data entered by the user.
- **datadublicationcheck()**: Checks for duplicate contacts.

### Main Menu

Displays the main menu and prompts the user to select an operation.

## Installation

1. Ensure `sqlite3` is installed on your system.
2. Download or clone the script to your local machine.
3. Make the script executable:
   ```bash
   chmod +x personal_contact_notebook.sh
   ```

## Running the Script

To run the script, execute the following command in your terminal:
```bash
./contact.sh
```

## Contact Table Structure

The `CONTACT` table has the following structure:
- `ID`: Integer, primary key, auto-increment.
- `NAME`: VARCHAR(30), contact's first name.
- `FAMILY`: VARCHAR(60), contact's last name.
- `MOBILEPHONE`: INTEGER, contact's mobile phone number.
- `HOMEPHONE`: INTEGER, contact's home phone number.
- `MAIL`: VARCHAR(70), contact's email address.
- `DEL`: INTEGER, flag to mark deleted contacts.

## Example

### Inserting a Contact

1. Select `Insert Contact` from the main menu.
2. Enter the required contact details.
3. The contact will be inserted into the database if all validations pass.

### Listing Contacts

1. Select `List Contact` from the main menu.
2. All contacts will be displayed in the terminal.

### Modifying a Contact

1. Select `Modify Contact` from the main menu.
2. Enter the name and family of the contact you want to modify.
3. Enter the new details for the contact.

### Deleting a Contact

1. Select `Delete Contact` from the main menu.
2. Enter the name and family of the contact you want to delete.
3. Confirm the deletion.

## License

This project is licensed under the MIT License.

## Acknowledgements

This script is a simple personal project to manage contact information. Special thanks to the SQLite team for providing a lightweight and powerful database engine.
