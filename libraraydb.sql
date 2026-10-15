-- ---------------------------------------------------------
-- 1. DATABASE SETUP
-- ---------------------------------------------------------
-- This section creates and selects the library database.
-- It also displays the databases available on the server.
show databases;

create database if not exists librarydb;

show databases;

use librarydb;

-- ---------------------------------------------------------
-- 2. CREATE BOOKS TABLE
-- ---------------------------------------------------------
-- This table stores book details and the number of available copies.
-- It also tracks total copies and whether each book is active.
create table if not exists books (
    book_id int primary key auto_increment,
    title varchar(100) not null,
    author varchar(100) not null,
    category varchar(100),
    quantity int not null,
    total_copies int not null,
    is_active boolean not null default 1,
    constraint uq_books_title_author unique (title, author),
    constraint chk_book_quantity check ((quantity >= 0)),
    constraint chk_total_copies check ((total_copies >= 0)),
    constraint chk_quantity_total check ((quantity <= total_copies))
);
-- ---------------------------------------------------------
-- 3. CREATE USERS TABLE
-- ---------------------------------------------------------
-- This table stores library users and their contact information.
-- The active flag shows whether a user can borrow books.
create table if not exists users (
    user_id int primary key auto_increment,
    user_name varchar(100) not null,
    email varchar(100) not null unique,
    phone_number varchar(15) not null,
    is_active boolean not null default 1
);

-- ---------------------------------------------------------
-- 4. CREATE TRANSACTIONS TABLE
-- ---------------------------------------------------------
-- This table records which user borrows each book and when.
-- It stores issue, due, and return dates along with loan status.
create table if not exists transactions (
    transaction_id int primary key auto_increment,
    book_id int not null,
    user_id int not null,
    issue_date date not null,
    due_date date not null,
    return_date date,
    status enum(
        'issued',
        'returned',
        'overdue'
    ) not null default 'issued',
    constraint chk_due_after_issue check (due_date >= issue_date),
    constraint chk_return_after_issue check (
        return_date is null
        or return_date >= issue_date
    ),
    constraint chk_return_status check (
        (
            status = 'returned'
            and return_date is not null
        )
        or (
            status in ('issued', 'overdue')
            and return_date is null
        )
    ),
    foreign key (book_id) references books (book_id) on delete restrict,
    foreign key (user_id) references users (user_id) on delete restrict
);

-- ---------------------------------------------------------
-- 5. PROTECT BORROWING HISTORY
-- ---------------------------------------------------------
-- This trigger blocks deletion of transaction records.
-- It helps preserve the library's borrowing history.
-- Keep borrowing history instead of deleting loan records.
create trigger if not exists prevent_transaction_delete
before delete on transactions
for each row
signal sqlstate '45000' set message_text = 'Borrowing history cannot be deleted';

-- ---------------------------------------------------------
-- 6. DESCRIBE TABLES
-- ---------------------------------------------------------
-- These commands display the structure of the users and books tables.
-- Use the output to review their columns and data types.
describe users;

describe books;

-- ---------------------------------------------------------
-- 7. INSERT SAMPLE BOOKS
-- ---------------------------------------------------------
-- This section adds five example books to the books table.
-- Existing records with the same IDs are left unchanged.
insert into
    books (
        book_id,
        title,
        author,
        category,
        quantity,
        total_copies
    )
values (
        1,
        'The Great Gatsby',
        'F. Scott Fitzgerald',
        'Fiction',
        5,
        5
    ),
    (
        2,
        'To Kill a Mockingbird',
        'Harper Lee',
        'Fiction',
        5,
        5
    ),
    (
        3,
        '1984',
        'George Orwell',
        'Dystopian',
        5,
        5
    ),
    (
        4,
        'Pride and Prejudice',
        'Jane Austen',
        'Romance',
        5,
        5
    ),
    (
        5,
        'The Catcher in the Rye',
        'J.D. Salinger',
        'Fiction',
        5,
        5
    )
on duplicate key update
    book_id = book_id;

-- ---------------------------------------------------------
-- 8. INSERT SAMPLE USERS
-- ---------------------------------------------------------
-- This section adds five example users to the users table.
-- Their fixed IDs match the sample borrowing steps below.
insert into
    users (
        user_id,
        user_name,
        email,
        phone_number
    )
values (
        1,
        'alone',
        'alone.@example.com',
        '123-456-7890'
    ),
    (
        2,
        'Smith',
        'smith.@example.com',
        '987-654-3210'
    ),
    (
        3,
        'jason',
        'jason.@example.com',
        '555-555-5555'
    ),
    (
        4,
        'naveen',
        'naveen.@example.com',
        '777-888-9999'
    ),
    (
        5,
        'john',
        'john.@example.com',
        '111-222-3333'
    )
on duplicate key update
    user_id = user_id;

-- ---------------------------------------------------------
-- 9. VIEW SAMPLE BOOKS AND USERS
-- ---------------------------------------------------------
-- These queries display the current books and users.
-- They help verify that the sample records were added.
select * from books;

select * from users;

-- ---------------------------------------------------------
-- 10. SEARCH BOOKS BY ID
-- ---------------------------------------------------------
-- This query finds books with IDs from 1 through 5.
-- It displays matching records from the books table.
select * from books where book_id in (1, 2, 3, 4, 5);

-- ---------------------------------------------------------
-- 11. ISSUE SAMPLE BOOKS
-- ---------------------------------------------------------
-- This section issues sample books to active users when stock is available.
-- Each successful issue reduces quantity and creates a loan record.
-- Keep the quantity update and loan insert in one transaction.
-- Run this section statement by statement. If a SQL error occurs, stop and
-- run ROLLBACK. Review the issue IDs before running COMMIT.
start transaction;

update books
set
    quantity = quantity - 1
where
    book_id = 4
    and quantity > 0
    and is_active = 1
    and exists (
        select 1
        from users
        where
            user_id = 1
            and is_active = 1
    )
    and not exists (
        select 1
        from transactions
        where
            book_id = 4
            and user_id = 1
            and return_date is null
    );

set @issue_rows = row_count();

insert into
    transactions (
        book_id,
        user_id,
        issue_date,
        due_date
    )
select 4, 1, curdate(), date_add(curdate(), interval 14 day)
from dual
where
    @issue_rows = 1;

set @issue_id_4 = if( row_count() = 1, last_insert_id(), 0 );

update books
set
    quantity = quantity - 1
where
    book_id = 2
    and quantity > 0
    and is_active = 1
    and exists (
        select 1
        from users
        where
            user_id = 3
            and is_active = 1
    )
    and not exists (
        select 1
        from transactions
        where
            book_id = 2
            and user_id = 3
            and return_date is null
    );

set @issue_rows = row_count();

insert into
    transactions (
        book_id,
        user_id,
        issue_date,
        due_date
    )
select 2, 3, curdate(), date_add(curdate(), interval 14 day)
from dual
where
    @issue_rows = 1;

set @issue_id_2 = if( row_count() = 1, last_insert_id(), 0 );

update books
set
    quantity = quantity - 1
where
    book_id = 1
    and quantity > 0
    and is_active = 1
    and exists (
        select 1
        from users
        where
            user_id = 2
            and is_active = 1
    )
    and not exists (
        select 1
        from transactions
        where
            book_id = 1
            and user_id = 2
            and return_date is null
    );

set @issue_rows = row_count();

insert into
    transactions (
        book_id,
        user_id,
        issue_date,
        due_date
    )
select 1, 2, curdate(), date_add(curdate(), interval 14 day)
from dual
where
    @issue_rows = 1;

set @issue_id_1 = if( row_count() = 1, last_insert_id(), 0 );

update books
set
    quantity = quantity - 1
where
    book_id = 5
    and quantity > 0
    and is_active = 1
    and exists (
        select 1
        from users
        where
            user_id = 4
            and is_active = 1
    )
    and not exists (
        select 1
        from transactions
        where
            book_id = 5
            and user_id = 4
            and return_date is null
    );

set @issue_rows = row_count();

insert into
    transactions (
        book_id,
        user_id,
        issue_date,
        due_date
    )
select 5, 4, curdate(), date_add(curdate(), interval 14 day)
from dual
where
    @issue_rows = 1;

set @issue_id_5 = if( row_count() = 1, last_insert_id(), 0 );

update books
set
    quantity = quantity - 1
where
    book_id = 3
    and quantity > 0
    and is_active = 1
    and exists (
        select 1
        from users
        where
            user_id = 5
            and is_active = 1
    )
    and not exists (
        select 1
        from transactions
        where
            book_id = 3
            and user_id = 5
            and return_date is null
    );

set @issue_rows = row_count();

insert into
    transactions (
        book_id,
        user_id,
        issue_date,
        due_date
    )
select 3, 5, curdate(), date_add(curdate(), interval 14 day)
from dual
where
    @issue_rows = 1;

set @issue_id_3 = if( row_count() = 1, last_insert_id(), 0 );

-- An issue ID of 0 means that issue was skipped (for example, no stock).
-- If a SQL statement reports an error, run ROLLBACK instead of COMMIT.
select
    @issue_id_4 as issue_id_4,
    @issue_id_2 as issue_id_2,
    @issue_id_1 as issue_id_1,
    @issue_id_5 as issue_id_5,
    @issue_id_3 as issue_id_3;

commit;

-- ---------------------------------------------------------
-- 12. VIEW ALL TRANSACTIONS
-- ---------------------------------------------------------
-- This query lists loan records with their book and user names.
-- It includes issue, due, and return dates.
select transactions.transaction_id, books.title, users.user_name, transactions.issue_date, transactions.due_date, transactions.return_date
from
    transactions
    join books on transactions.book_id = books.book_id
    join users on transactions.user_id = users.user_id;

-- ---------------------------------------------------------
-- 13. VIEW UNRETURNED BOOKS
-- ---------------------------------------------------------
-- This query lists loans that have not been returned.
-- It shows each loan's book, user, and issue details.
select transactions.transaction_id, books.title, users.user_name, transactions.issue_date, transactions.due_date, transactions.return_date
from
    transactions
    join books on transactions.book_id = books.book_id
    join users on transactions.user_id = users.user_id
where
    transactions.return_date is null;

-- ---------------------------------------------------------
-- 14. VIEW RETURNED BOOKS
-- ---------------------------------------------------------
-- This query lists loans with a recorded return date.
-- It shows each loan's book, user, and transaction dates.
select transactions.transaction_id, books.title, users.user_name, transactions.issue_date, transactions.due_date, transactions.return_date
from
    transactions
    join books on transactions.book_id = books.book_id
    join users on transactions.user_id = users.user_id
where
    transactions.return_date is not null;

-- ---------------------------------------------------------
-- 15. RETURN SAMPLE BOOKS
-- ---------------------------------------------------------
-- This section returns the sample loans created above.
-- Each successful return updates the loan and book quantity.
-- Each statement returns one loan and updates its book quantity together.
-- Run this section statement by statement. If a SQL error occurs, stop and
-- run ROLLBACK. Review the return row counts before running COMMIT.
start transaction;

update books b
join transactions t on t.book_id = b.book_id
set
    b.quantity = b.quantity + 1,
    t.status = 'returned',
    t.return_date = curdate()
where
    t.transaction_id = @issue_id_4
    and t.status in ('issued', 'overdue')
    and t.return_date is null
    and b.quantity < b.total_copies;

set @return_rows_4 = row_count();

update books b
join transactions t on t.book_id = b.book_id
set
    b.quantity = b.quantity + 1,
    t.status = 'returned',
    t.return_date = curdate()
where
    t.transaction_id = @issue_id_2
    and t.status in ('issued', 'overdue')
    and t.return_date is null
    and b.quantity < b.total_copies;

set @return_rows_2 = row_count();

update books b
join transactions t on t.book_id = b.book_id
set
    b.quantity = b.quantity + 1,
    t.status = 'returned',
    t.return_date = curdate()
where
    t.transaction_id = @issue_id_1
    and t.status in ('issued', 'overdue')
    and t.return_date is null
    and b.quantity < b.total_copies;

set @return_rows_1 = row_count();

update books b
join transactions t on t.book_id = b.book_id
set
    b.quantity = b.quantity + 1,
    t.status = 'returned',
    t.return_date = curdate()
where
    t.transaction_id = @issue_id_5
    and t.status in ('issued', 'overdue')
    and t.return_date is null
    and b.quantity < b.total_copies;

set @return_rows_5 = row_count();

update books b
join transactions t on t.book_id = b.book_id
set
    b.quantity = b.quantity + 1,
    t.status = 'returned',
    t.return_date = curdate()
where
    t.transaction_id = @issue_id_3
    and t.status in ('issued', 'overdue')
    and t.return_date is null
    and b.quantity < b.total_copies;

set @return_rows_3 = row_count();

-- A value of 1 means that return was processed; 0 means it was skipped.
select
    @return_rows_4 as return_4,
    @return_rows_2 as return_2,
    @return_rows_1 as return_1,
    @return_rows_5 as return_5,
    @return_rows_3 as return_3;

commit;

-- ---------------------------------------------------------
-- 16. VERIFY TRANSACTION HISTORY
-- ---------------------------------------------------------
-- This query displays a transaction to verify its stored history.
-- It does not delete or change the transaction.
-- Keep borrowing history instead of deleting the transaction.
select * from transactions where transaction_id = 1;

-- ---------------------------------------------------------
-- 17. DEACTIVATE BOOK
-- ---------------------------------------------------------
-- This update deactivates a book only when it has no open loans.
-- The book record remains stored for borrowing history.
-- Mark a book inactive only when it has no open loans.
update books
set
    is_active = 0
where
    book_id = 1
    and not exists (
        select 1
        from transactions
        where
            book_id = 1
            and return_date is null
    );

-- ---------------------------------------------------------
-- 18. DEACTIVATE USER
-- ---------------------------------------------------------
-- This update deactivates a user only when they have no open loans.
-- The user record remains stored in the database.
-- Mark a user inactive only when they have no open loans.
update users
set
    is_active = 0
where
    user_id = 1
    and not exists (
        select 1
        from transactions
        where
            user_id = 1
            and return_date is null
    );