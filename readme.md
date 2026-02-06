# AM DBMS - Bash Database Management System

```
  ████████      ███      ███
 ███    ███     ████    ████
 ███    ███     █████  █████
 ██████████     ███ ████ ███
 ███    ███     ███  ██  ███
 ███    ███     ███      ███
 ███    ███     ███      ███
```

AM DBMS is a lightweight, file-based database management system implemented entirely in Bash. It provides essential CRUD operations, table management, and database operations through an interactive command-line interface.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Database Operations](#database-operations)
- [Table Operations](#table-operations)
- [CRUD Operations](#crud-operations)
- [File Structure](#file-structure)
- [Technical Details](#technical-details)
- [Requirements](#requirements)

## Features

- Create, list, and drop databases
- Create, list, and drop tables with custom columns
- Support for multiple data types (int, string)
- Primary key constraints with composite key support
- CRUD operations (Create, Read, Update, Delete)
- Condition-based filtering for queries (=, !=, <, >)
- Data type validation
- Persistent file-based storage
- Interactive command-line interface

## Installation

### Prerequisites

- Bash 4.0 or higher
- Linux/Unix-like operating system (macOS, Linux, WSL, etc.)
- Standard Unix tools (mkdir, touch, grep, awk, etc.)

### Setup

1. Clone or download the repository:

```bash
git clone <repository-url>
cd bash_dbms
```

2. Make the main script executable:

```bash
chmod +x dbms.sh
```

3. Ensure all helper scripts are executable:

```bash
chmod +x src/**/*.sh
```

## Quick Start

To start the AM DBMS system, run:

```bash
./dbms.sh
```

This will launch the interactive main menu where you can manage databases and perform operations.

## Database Operations

### Main Menu Options

When you start the DBMS, you'll see the following options:

```
1) create database
2) connect to database
3) list databases
4) drop database
```

### Create Database

Select option 1 from the main menu and enter the database name. The database will be created in your home directory under `~/dbms_dir/`.

```
Input: create_database
Location: ~/dbms_dir/create_database/
```

### List Databases

Select option 3 to view all existing databases. The system will display a list of all databases in the DBMS directory.

After viewing the list, press Enter to return to the main menu.

### Connect to Database

Select option 2 to connect to an existing database. Once connected, you'll access the database menu with table management and CRUD operation options.

### Drop Database

Select option 4 to delete an entire database. You will be prompted for confirmation before deletion.

**Warning**: This operation is irreversible and will delete all tables and data within the database.

## Table Operations

After connecting to a database, the system menu changes to table operations:

```
1) create table
2) list tables
3) insert into table
4) drop table
5) select from table
6) disconnect from db
7) add column to table
8) update on table
```

### Create Table

1. Enter the table name
2. Add columns one at a time:
   - Enter column name
   - Select data type (int or string)
   - Type "done" when finished adding columns
3. Define primary key column(s):
   - Single primary key: `id`
   - Composite primary key: `id,name`

**Example:**
```
Table Name: employees
Columns:
  - id (int) - Primary Key
  - name (string)
  - salary (int)
```

### List Tables

View all tables in the currently connected database. The display shows table names without the file extensions.

### Drop Table

Delete an entire table from the database. You will be prompted for confirmation.

**Warning**: This operation will delete the table structure and all its data.

### Add Column to Table

Add new columns to an existing table. You will be prompted to:
1. Select the table to modify
2. Enter the column name
3. Select the data type

## CRUD Operations

### Insert (Create)

Insert new rows into a table.

**Features:**
- Automatic data type validation (int must be numeric, string can be any text)
- Primary key uniqueness enforcement
- Composite key support
- Prevents duplicate primary keys

**Process:**
1. Select table name
2. Enter values for each column in order
3. System validates data types
4. Confirms insertion on success

**Example:**
```
Table: employees
id: 1
name: John Doe
salary: 5000
Result: Row successfully inserted
```

### Select (Read)

Query and retrieve data from tables with optional filtering.

**Operators Supported:**
- `=` : Equality (works for all data types)
- `!=` : Inequality
- `>` : Greater than (numeric only)
- `<` : Less than (numeric only)

**Syntax:**
```
condition: column_name operator value
Examples:
  id=1
  name=John
  salary>5000
  id!=5
```

Leave empty to retrieve all rows from the table.

**Example:**
```
Table: employees
Condition: salary>5000
Results: All employees with salary greater than 5000
```

### Update (Modify)

Update existing rows in a table with conditional filtering.

**Features:**
- Update specific columns in matching rows
- Conditional filtering to select rows
- Data type validation for new values
- Primary key constraint enforcement

**Process:**
1. Select table name
2. Enter column names to update (comma-separated): `salary,position`
3. Enter filtering condition or leave empty to update all rows
4. Enter new values for each column being updated
5. System confirms number of rows updated

**Example:**
```
Table: employees
Columns to update: salary
Condition: name=John
New salary: 6000
Result: 1 row updated
```

### Delete (Remove)

Delete rows from a table with conditional filtering.

**Features:**
- Conditional deletion to target specific rows
- Safety confirmation when deleting all rows
- Clear feedback on number of deleted rows

**Process:**
1. Select table name
2. Enter filtering condition or leave empty to delete all rows
3. If deleting all rows, confirm with "yes"
4. System confirms number of rows deleted

**Conditions Support:**
- `=` : Equality
- `!=` : Inequality
- `>` : Greater than (numeric)
- `<` : Less than (numeric)

**Example:**
```
Table: employees
Condition: id=5
Result: 1 row successfully deleted
```

Leave the condition empty to delete all rows (with confirmation prompt).

## File Structure

```
bash_dbms/
├── dbms.sh                 # Main entry point
├── readme.md              # This file
├── docs/
│   └── table_structure.txt # Technical documentation
└── src/
    ├── art.sh             # ASCII art and UI styling
    ├── helpers.sh         # Shared utility functions
    ├── after_connection.sh # Post-connection menu
    ├── db/
    │   ├── create_db.sh   # Database creation
    │   ├── connect_to_db.sh # Database connection
    │   ├── list_dbs.sh    # List databases
    │   └── drop_db.sh     # Database deletion
    ├── table/
    │   ├── create_table.sh # Table creation
    │   ├── list_tables.sh  # List tables
    │   ├── drop_table.sh   # Table deletion
    │   └── create_col.sh   # Add columns
    └── crud/
        ├── insert.sh      # Insert rows
        ├── select.sh      # Query rows
        ├── update.sh      # Update rows
        └── delete.sh      # Delete rows
```

## Technical Details

### Data Storage

AM DBMS uses a two-file system for each table:

1. **Meta File** (`tablename.meta`)
   - Stores column definitions and data types
   - Format: `column_name:data_type`
   - Last line contains primary key definition

   **Example (employees.meta):**
   ```
   id:int
   name:string
   salary:int
   primary_key:id
   ```

2. **Data File** (`tablename.txt`)
   - Stores actual table data in CSV format
   - Comma-separated values
   - One row per line

   **Example (employees.txt):**
   ```
   1,John Doe,5000
   2,Jane Smith,6000
   3,Bob Johnson,5500
   ```

### Database Structure

```
~/dbms_dir/
└── database_name/
    ├── table1.meta
    ├── table1.txt
    ├── table2.meta
    └── table2.txt
```

### Supported Data Types

- **int**: Integer values (numeric only)
- **string**: Text values (any character combination)

### Constraints

- **Primary Key**: Ensures uniqueness of key columns
- **Composite Keys**: Supports multiple columns as primary key
- **Data Type Validation**: Enforces type constraints on insert and update

### Helper Functions

The `helpers.sh` file provides critical functions:

- `populate_table_metadata()`: Loads table schema and constraints
- `validate_value_by_type()`: Validates values against data types
- `disconnect_and_rm_curdb()`: Handles database disconnection

## Requirements

- Bash 4.0+ (for associative arrays)
- Read/write access to home directory
- Standard POSIX utilities

## Usage Examples

### Complete Workflow

```bash
# 1. Start the DBMS
./dbms.sh

# 2. Create a new database (select option 1)
# Enter name: company_db

# 3. Connect to the database (select option 2)
# Enter name: company_db

# 4. Create a table (select option 1)
# Table name: employees
# Columns: id (int), name (string), salary (int)
# Primary key: id

# 5. Insert data (select option 3)
# Insert employee records

# 6. Query data (select option 5)
# View employees with salary > 5000

# 7. Update records (select option 8)
# Update employee salary

# 8. Delete records (select option 5)
# Delete terminated employees

# 9. Disconnect (select option 6)
```

## Known Limitations

- Single condition filtering only (no AND/OR operations)
- Basic data types only (int, string)
- File-based storage (not optimized for large datasets)
- No built-in backup mechanism
- No user authentication or permissions system
- No transaction support

## Future Enhancements

Potential improvements for future versions:

- Multiple condition filtering with AND/OR logic
- Additional data types (float, date, boolean)
- Indexing for improved query performance
- Foreign key constraints
- Transaction support
- Backup and restore functionality
- User authentication
- Query optimization

## Troubleshooting

### Menu covers database output

If the main menu appears immediately after listing databases, the system will now prompt you to press Enter before returning to the menu. This ensures you have time to view the output.

### Path errors in scripts

Ensure you're running `./dbms.sh` from the bash_dbms directory. The script uses relative paths that depend on the current working directory.

### Permission denied errors

Make all scripts executable:
```bash
chmod +x dbms.sh
chmod +x src/**/*.sh
```

### Data not persisting

Verify that the `~/dbms_dir/` directory exists and is writable:
```bash
ls -la ~/dbms_dir/
```

## License

This project is provided as-is for educational purposes.

## Contributing

For bug reports or feature requests, please document the issue clearly with steps to reproduce.

---

**AM DBMS** - A Bash-based database management system for educational and lightweight data storage needs.

Last Updated: February 2026
