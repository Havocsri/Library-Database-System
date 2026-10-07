-- SQLBook: Code
--check the databases in mysql'''
show databases;

--if the database is not present then create the database
create database libraryDB;

--check the databases in mysql
show databases;

--use the database
use libraryDB;

--create the books table'''
create table books( book_id int primary key auto_increment,
    title varchar(100) not null,
    author varchar(100) not null,
    category varchar(100),
    quantity int not null,

    constraint chk_book_quantity check ((quantity >= 0)));

    --create the users table'''
    create table users(
        user_id int primary key auto_increment,
        user_name varchar(100) not null,
        email varchar(100) not null unique,
        phone_number varchar(15) not null

    );

--create the transactions table '''
    create table transactions(
        transaction_id int primary key auto_increment ,
        book_id int not null,
        user_id int not null,
        issue_date date not null,
        due_date date not null,
        return_date date,

--join the books and users table with transactions table using foreign key'''
        foreign key (book_id) references books(book_id) on delete restrict,
        foreign key (user_id) references users(user_id) on delete restrict);


--describe users and books table to see'''
    describe users;
    describe books;


--insert the datas into books and users table'''
    insert into books(title,author,category,quantity)values
    
    ('The Great Gatsby','F. Scott Fitzgerald','Fiction',5),
    ('To Kill a Mockingbird','Harper Lee','Fiction',5),
    ('1984','George Orwell','Dystopian',5),
    ('Pride and Prejudice','Jane Austen','Romance',5),
    ('The Catcher in the Rye','J.D. Salinger','Fiction',5);

    insert into users(user_name,email,phone_number)values
    ('alone','alone.@example.com','123-456-7890'),
    (' Smith','smith.@example.com','987-654-3210'),
    ('jason','jason.@example.com','555-555-5555'),
    ('naveen','naveen.@example.com','777-888-9999'),
    ('john','john.@example.com','111-222-3333');


    --check the users and books table to see the inserted datas'''
    select * from books;
    select * from users;

    --check the books table to take the books'''
    select * from books where 
    book_id in (1,2,3,4,5);

     start transaction;

    --insert the datas into transactions table '''
      insert into transactions(book_id,user_id,issue_date,due_date)
      select 4,1,curdate(),date_add(curdate(),interval 14 day)
      from books
      where book_id = 4
      and quantity > 0;

      insert into transactions(book_id,user_id,issue_date,due_date)
      select 2,3,curdate(),date_add(curdate(),interval 14 day)
      from books
      where book_id = 2
      and quantity > 0;

      insert into transactions(book_id,user_id,issue_date,due_date)
      select 1,2,curdate(),date_add(curdate(),interval 14 day)
      from books
      where book_id = 1
      and quantity > 0;

      insert into transactions(book_id,user_id,issue_date,due_date)
      select 5,4,curdate(),date_add(curdate(),interval 14 day)
      from books
      where book_id = 5
      and quantity > 0;

      insert into transactions(book_id,user_id,issue_date,due_date)
      select 3,5,curdate(),date_add(curdate(),interval 14 day)
      from books
      where book_id = 3
      and quantity > 0;

       --update the quantity of books after issud the books'''
       update books
       set quantity = quantity - 1
       where book_id = 4
       and quantity > 0;

       update books
       set quantity = quantity - 1
       where book_id = 2
       and quantity > 0;

       update books
       set quantity = quantity - 1
       where book_id = 1
       and quantity > 0;

       update books
       set quantity = quantity - 1
       where book_id = 5
       and quantity > 0;

       update books
       set quantity = quantity - 1
       where book_id = 3
       and quantity > 0;

    commit;
     
       --check the transactions table to see the issued books'''
      select  
         transactions.transaction_id,
         books.title ,
         users.user_name,
         transactions.issue_date,
         transactions.due_date,
         transactions.return_date
         
      from transactions 
      join books 
      on transactions.book_id = books.book_id
      join users 
      on transactions.user_id = users.user_id;


--check the transactions table to see the issu books which are not returned yet'''
      select  
         transactions.transaction_id,
         books.title ,
         users.user_name,
         transactions.issue_date,
         transactions.due_date,
         transactions.return_date
         
      from transactions 
      join books 
      on transactions.book_id = books.book_id
      join users 
      on transactions.user_id = users.user_id
      where transactions.return_date is null;

--check the transactions table to see the issu books which are returned'''
       select  
         transactions.transaction_id,
         books.title ,
         users.user_name,
         transactions.issue_date,
         transactions.due_date,
         transactions.return_date
         
      from transactions 
      join books 
      on transactions.book_id = books.book_id
      join users 
      on transactions.user_id = users.user_id
      where transactions.return_date is not null;
 

      -- start the transaction to make the changes safely
        start transaction;

      --updatethe quantity of books after retun with the return date of the books
        update transactions
        set return_date=curdate()
        where transaction_id in (1,2,3,4,5)
        and return_date is null;

      --increase the quantity only for the books returned 
        update books 
        set quantity=quantity+1
        where book_id in (
        select book_id    
        from transactions
        where transaction_id in (1,2,3,4,5)
        and return_date = curdate())
        and quantity < 5;  
     

      -- save all the changes permanently
        commit;


--delete a transaction
delete from transactions
where transaction_id = 1;



--delete a book
 
delete from books
where book_id = 1;

--delete a user

delete from users
where user_id = 1;


