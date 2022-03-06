CREATE TABLE book (
   book_id INT AUTO_INCREMENT PRIMARY KEY,
   author_id INT,
   title VARCHAR(255),
   isbn INT,
   available BOOL,
   genre_id INT
);

CREATE TABLE author (
   author_id INT AUTO_INCREMENT PRIMARY KEY,
   first_name VARCHAR(255),
   last_name VARCHAR(255),
   birthday DATE,
   deathday DATE
);

CREATE TABLE patron (
   patron_id INT AUTO_INCREMENT PRIMARY KEY,
   first_name VARCHAR(255),
   last_name VARCHAR(255),
   loan_id INT
);

CREATE TABLE reference_books (
   reference_id INT AUTO_INCREMENT PRIMARY KEY,
   edition INT,
   book_id INT,
   FOREIGN KEY (book_id)
      REFERENCES book(book_id)
      ON UPDATE SET NULL
      ON DELETE SET NULL
);

INSERT INTO reference_books(edition, book_id)
VALUE (5,32);

CREATE TABLE genre (
   genre_id INT PRIMARY KEY,
   genres VARCHAR(100)
);

CREATE TABLE loan (
   loan_id INT AUTO_INCREMENT PRIMARY KEY,
   patron_id INT,
   date_out DATE,
   date_in DATE,
   book_id INT,
   FOREIGN KEY (book_id)
      REFERENCES book(book_id)
      ON UPDATE SET NULL
      ON DELETE SET NULL
);

SELECT title, isbn
FROM book
WHERE genre_id=6;

SELECT book.title, author.first_name, author.last_name
FROM author
INNER JOIN book ON author.author_id=book.author_id
WHERE author.deathday IS NULL;

UPDATE book 
SET available=0
WHERE book_id=4;
INSERT INTO loan (patron_id, date_out, book_id)
VALUE (1, CURDATE(), 4);
UPDATE patron
SET loan_id=1
WHERE patron_id=1;

UPDATE book 
SET available=1
WHERE book_id=4;
UPDATE loan
SET date_in=DATE_ADD(date_out, INTERVAL 2 WEEK)
WHERE loan_id=1;
UPDATE patron
SET loan_id=NULL
WHERE patron_id=1;

SELECT patron.first_name, patron.last_name
FROM loan
LEFT JOIN patron ON loan.loan_id=patron.loan_id
WHERE patron.loan_id IS NOT NULL 

UNION 

SELECT genre.genres, loan.loan_id
FROM loan
LEFT JOIN genre ON genre.genre_id=book.book_id
WHERE book.book_id IN (SELECT book_id FROM loan WHERE date_in IS NULL);

SELECT patron.first_name, patron.last_name, genres 
FROM (SELECT first_name, last_name, book_id
FROM patron_loan;

SELECT first_name, last_name, genres
FROM ( SELECT first_name, last_name, book_id
	 FROM patron p
	 INNER JOIN loan l ON p.loan_id = l.loan_id) AS A
INNER JOIN ( SELECT book_id, genres
	 FROM genre
	 INNER JOIN book ON genre.genre_id = book.genre_id) AS B
ON A.book_id=B.book_id;

# Return names of the patrons with the genre of every book they currently have checked out.

-- Retrieve first name, last name, and genre of checked out books.
SELECT patron_loan.first_name, patron_loan.last_name, genres
FROM (
	-- Return first name, last name, and book_id from the patron_loan table.
	SELECT first_name, last_name, book_id
    FROM patron
    -- Merge entries from the loan and patron tables that have the same loan_id.
    INNER JOIN loan ON loan.loan_id = patron.loan_id
) AS patron_loan
-- Merge entries from the patron_loan and genre_book tables that have the same book_id.
INNER JOIN (
	SELECT genres, book_id
    FROM genre
    -- Merge the genre and book table entries.
    INNER JOIN book ON genre.genre_id = book.genre_id
) AS genre_book
ON genre_book.book_id = patron_loan.book_id;

# Alternative approach:

SELECT first_name, last_name, genres
FROM (
	SELECT first_name, last_name, book_id
	FROM patron
	INNER JOIN loan ON loan.loan_id = patron.loan_id
) AS patron_loan
-- Merge entries from patron_loan and checked_out_genres that have mathcing book_id values.
INNER JOIN (
	-- Return entries for books that are NOT available.
	SELECT book_id, genre_id
    FROM book
    WHERE available = FALSE
) AS checked_out_genres ON patron_loan.book_id = checked_out_genres.book_id
-- Merge entries from genre and checked_out_genres that have mathcing genre_id values.
INNER JOIN genre ON checked_out_genres.genre_id = genre.genre_id;

