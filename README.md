# Library Database System

## About the Project

This is a simple Library Database System.

It is used to manage books, users, and book transactions.

## Technologies Used

- MySQL
- SQL

## Database Tables

1. Books

- Stores book details.
- Includes title, author, category, and quantity.

2. Users

- Stores user details.
- Includes name, email, and phone number.

3. Transactions

- Stores book issue and return details.
- Includes issue date, due date, and return date.

## Features

- Add books.
- Add users.
- View all books.
- View all users.
- Search books by ID.
- Issue books.
- Return books.
- View all transactions.
- View returned books.
- View not returned books.
- Check book availability before issuing.
- Decrease book quantity after issuing.
- Increase book quantity after returning.
- Deactivate books and users when they have no open loans.
- Prevent duplicate return updates
- Track issue date and due date

## SQL Concepts Used

- CREATE DATABASE
- CREATE TABLE
- PRIMARY KEY
- FOREIGN KEY
- INSERT
- SELECT
- UPDATE
- WHERE
- JOIN
- NOT NULL
- UNIQUE
- AUTO_INCREMENT
- IS NOT NULL
- IS NULL
- IN
- COMMIT
- START TRANSACTION
- DATE_ADD
- CURDATE

## Project Flow

1. Create the database.
2. Create the tables.
3. Add books and users.
4. Issue books to users.
5. Track due dates.
6. Update return dates.
7. View book transactions.
8. Check book availability.
9. Increase book quantity after returning

## Conclusion

This project helps to manage library records easily.

It also helps to track issued and returned books.

## Database Improvements

- Checks book availability before issuing.
- Updates book quantity and issue record in one transaction.
- Shows whether each issue was successful.
- Updates book quantity and return status together.
- Shows whether each return was successful.
- Constraints validate quantities and dates.
- Foreign keys prevent deleting books or users with transaction records.
- Trigger protects borrowing history from deletion.
- Duplicate inserts do not overwrite existing details.
- Numbered sections make the SQL script easy to read.

Note: Run this script in a new database. It uses book and user IDs 1 to 5. If a table already exists, this script will not change it.

Note: If a SQL error occurs, stop and run `ROLLBACK` manually. The script does not roll back automatically.
