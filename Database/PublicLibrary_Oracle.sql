-- sqlplus system/admin
-- conn admin_library/library1234;
-- @"C:\Users\luisj\Google Drive\Portafolio de proyectos\Public Library\DataBase\PublicLibrary_Oracle.sql"
-- PROJECT: PUBLIC LIBRARY.
-- LUIS J. BRAVO ZÚÑIGA.
-- SCRIPT DATA BASE (ORACLE).

	host cls;
	
	set linesize 200
	set pagesize 300

	PROMPT *** PROJECT: PUBLIC LIBRARY.
	PROMPT *** LUIS J. BRAVO ZUNIGA.
	PROMPT *** SCRIPT DATA BASE (ORACLE).
	
	PROMPT [SYSTEM: START SCRIPT]
	
	conn system/admin
	
	PROMPT [ADMIN_LIBRARY: DROPING USER]
	drop user admin_library cascade;
	
	PROMPT [SYSTEM: CREATE USER ADMIN]
	create user admin_library identified by library1234;
	grant dba to admin_library;
	conn admin_library/library1234;

	PROMPT [ADMIN_LIBRARY: DROPING TABLES]
	
	PROMPT [ADMIN_LIBRARY: DROPING USERS TABLE]
	drop table Users;
	
	PROMPT [ADMIN_LIBRARY: DROPING BOOK TABLE]
	drop table Book;
	
	PROMPT [ADMIN_LIBRARY: DROPING SUBGENRE TABLE]
	drop table subgenre;
	
	PROMPT [ADMIN_LIBRARY: DROPING SEQUENCES]
	
	PROMPT [ADMIN_LIBRARY: DROPING SEQUENCES FOR SUBGENRE]
	drop sequence PK_seq_subgenre;
	
	PROMPT [ADMIN_LIBRARY: CREATING TABLES]
		
	PROMPT [ADMIN_LIBRARY: CREATING TABLE USERS]
	create table Users(
	username			varchar2(25)		not null,
	password			varchar2(16)		not null,
	state_data			varchar2(1)			not null
	);
	
	PROMPT [ADMIN_LIBRARY: CREATING TABLE BOOK]
	create table Book(
	ISBN				varchar2(13)		not null,
	title				varchar2(40)		not null,
	author_fname		varchar2(20)		not null,
	author_lname		varchar2(20)		not null,
	editorial			varchar2(20)		not null,
	year_publication	varchar2(4)			not null,
	idiom				varchar2(10)		not null,	
	pages				varchar2(10)		not null,
	id_subgenre			number				not null,
	quantity			number				not null,
	state_data			varchar2(1)			not null
	);
	
	PROMPT [ADMIN_LIBRARY: CREATING TABLE SUBGENRE]
	create table Subgenre(
	id					number				not null,
	title				varchar2(20)		not null
	);

	PROMPT [ADMIN_LIBRARY: CREATING SEQUENCES]
	
	PROMPT [ADMIN_LIBRARY: CREATING SEQUENCES FOR SUBGENRE]
	create sequence PK_seq_subgenre start with 1 increment by 1 cache 2;
	
	PROMPT [ADMIN_LIBRARY: CREATING RESTRICTIONS]
	
	-- NOTE: PRIMARY KEY
	PROMPT [ADMIN_LIBRARY: CREATING PRIMARY KEY OF TABLE USERS]
	alter table Users add constraint PK_users primary key (username);
	
	PROMPT [ADMIN_LIBRARY: CREATING PRIMARY KEY OF TABLE BOOK]
	alter table Book add constraint PK_book primary key (ISBN);
	
	PROMPT [ADMIN_LIBRARY: CREATING PRIMARY KEY OF TABLE SUBGENRE]
	alter table Subgenre add constraint PK_subgenre primary key (id);
	
	-- NOTE: FOREIGN KEY
	PROMPT [ADMIN_LIBRARY: CREATING FOREIGN KEY OF TABLE BOOK]
	alter table Book add constraint FK_book_subgenre foreign key (id_subgenre) references Subgenre;
	
	-- NOTE: CHECK CONSTRAINT FOR STATE OF DATA
	PROMPT [ADMIN_LIBRARY: CREATING CHECK CONSTRAINT FOR DATA STATE. THIS ATRIBUTTE ONLY CAN TAKE TWO VALUES: 'A' OR 'I']
	alter table Users add constraint cdt_state_data_users check (state_data in ('A', 'I'));
	alter table Book add constraint cdt_state_data_book check (state_data in ('A', 'I'));
	
	-- NOTE: CHECK CONSTRAINT FOR QUANTITY
	PROMPT [ADMIN_LIBRARY: CREATING CHECK CONSTRAINT FOR QUANTITY. THIS ATRIBUTTE MUST TO BE > -1]
	alter table Book add constraint cdt_quantity check (quantity > -1);
	
	PROMPT [ADMIN_LIBRARY: GET CURSOR]
	create or replace package TYPES
	as
	type ref_cursor is ref cursor;
	end;
	/
	show error
	
	PROMPT [ADMIN_LIBRARY: CREATING FUNCTION]
	-- FORMAT: f_<OPERATION>_<TABLE>
	
	-- NOTE: FUNCTION FOR CHECK LOGIN.
	PROMPT [ADMIN_LIBRARY: CREATING FUNCTION FOR CHECK LOGIN]
	create or replace function f_check_login(arg_username in Users.username%type, arg_password in Users.password%type) return number is
	var_result number(1);
	begin
		select count(username)
		into var_result
		from Users 
		where username = upper(arg_username) and password = arg_password and state_data = 'A';
		return var_result;
	end f_check_login;
	/
	show errors
	
    -- NOTE: FUNCTION FOR CONSULT AND LIST BOOK. 
	PROMPT [ADMIN_LIBRARY: CREATING FUNCTION FOR CONSULT BOOK]
	create or replace function f_consult_book(arg_ISBN in Book.ISBN%type) return TYPES.ref_cursor 
	as
	c_book_data TYPES.ref_cursor;
	begin
		open c_book_data for
		select ISBN, title, author_fname, author_lname, editorial, year_publication, idiom, pages, id_subgenre, quantity
		from Book
		where ISBN = arg_ISBN;
		return c_book_data;
	end f_consult_book;
	/
	show errors
	
	PROMPT [ADMIN_LIBRARY: CREATING FUNCTION FOR LIST BOOK]	
	create or replace function f_list_book return TYPES.ref_cursor 
	as
	c_book_data TYPES.ref_cursor;
	begin
		open c_book_data for
		select ISBN, title, author_fname, author_lname, editorial, year_publication, idiom, pages, id_subgenre, quantity
		from Book
		where state_data = 'A'
		order by author_lname;
		return c_book_data;
	end f_list_book;
	/
	show errors
	
	PROMPT [ADMIN_LIBRARY: CREATING OTHERS FUNCTIONS TO VALIDATE OPERATIONS]
	
	PROMPT [ADMIN_LIBRARY: CREATING FUNCTION TO KNOW IF THE BOOK EXISTS]
	create or replace function f_exist_book(arg_ISBN in Book.ISBN%type) return number
	as 
	var_result number(1);
	begin
		select count(ISBN)
		into var_result
		from Book
		where ISBN = arg_ISBN;
		return var_result;
	end f_exist_book;
	/
	show errors
	
	--NOTE: FUNCTION FOR LIST SUBGENRE
	PROMPT [ADMIN_LIBRARY: CREATING FUNCTION FOR LIST SUBGENRE]	
	create or replace function f_list_subgenre return TYPES.ref_cursor 
	as
	c_subgenre_data TYPES.ref_cursor;
	begin
		open c_subgenre_data for
		select title
		from Subgenre;
		return c_subgenre_data;
	end f_list_subgenre;
	/
	show errors

	PROMPT [ADMIN_LIBRARY: CREATING PROCEDURE]
	-- FORMAT: p_<OPERATION>_<TABLE>

	-- NOTE: PROCEDURE FOR INSERT AND UPDATE USER
	PROMPT [ADMIN_LIBRARY: CREATING PROCEDURE FOR INSERT USERS]
	create or replace procedure p_insert_user(arg_username in users.username%type, arg_password in users.password%type) is 
	begin
	    insert into users(username, password, state_data) values (upper(arg_username), arg_password, 'A');
		commit;
	end p_insert_user;
	/
	show errors
	
	PROMPT [ADMIN_LIBRARY: CREATING PROCEDURE FOR UPDATE USERS]
	create or replace procedure p_update_user(arg_username in users.username%type, arg_password in users.password%type) is
	begin
		update Users set password = arg_password where username = upper(arg_username) and state_data = 'A';
		commit;
	end p_update_user;
	/
	show errors
	
	-- NOTE: PROCEDURE FOR INSERT, UPDATE AND DELETE BOOK
	PROMPT [ADMIN_LIBRARY: CREATING PROCEDURE FOR INSERT BOOK]
	create or replace procedure p_insert_book(arg_ISBN in Book.ISBN%type, arg_title in Book.title%type, arg_author_fname in Book.author_fname%type, arg_author_lname in Book.author_lname%type, arg_editorial in Book.editorial%type, arg_year_publication in Book.year_publication%type, arg_idiom in Book.idiom%type, arg_pages in Book.pages%type, arg_id_subgenre in Book.id_subgenre%type, arg_quantity in Book.quantity%type) is
	begin
		if f_exist_book(arg_ISBN) = 0 then
			insert into Book(ISBN, title, author_fname, author_lname, editorial, year_publication, idiom, pages, id_subgenre, quantity, state_data) values (arg_ISBN, arg_title, arg_author_fname, arg_author_lname, arg_editorial, arg_year_publication, arg_idiom, arg_pages, arg_id_subgenre,arg_quantity, 'A');
		else
			update Book set title = arg_title, author_fname = arg_author_fname, author_lname = arg_author_lname, editorial = arg_editorial, year_publication = arg_year_publication, idiom = arg_idiom, pages = arg_pages, id_subgenre = arg_id_subgenre, quantity = arg_quantity, state_data = 'A'
			where ISBN = arg_ISBN;
		end if;
		commit;
	end p_insert_book;
	/
	show errors
	
	PROMPT [ADMIN_LIBRARY: CREATING PROCEDURE FOR UPDATE BOOK]
	create or replace procedure p_update_book(arg_ISBN in Book.ISBN%type, arg_title in Book.title%type, arg_author_fname in Book.author_fname%type, arg_author_lname in Book.author_lname%type, arg_editorial in Book.editorial%type, arg_year_publication in Book.year_publication%type, arg_idiom in Book.idiom%type, arg_pages in Book.pages%type, arg_id_subgenre in Book.id_subgenre%type, arg_quantity in Book.quantity%type) is
	begin
		update Book set title = arg_title, author_fname = arg_author_fname, author_lname = arg_author_lname, editorial = arg_editorial, year_publication = arg_year_publication, idiom = arg_idiom, pages = arg_pages, id_subgenre = arg_id_subgenre, quantity = arg_quantity
		where ISBN = arg_ISBN;
		commit;
	end p_update_book;
	/
	show errors
	
	PROMPT [ADMIN_LIBRARY: CREATING PROCEDURE FOR DELETE BOOK]
	create or replace procedure p_delete_book(arg_ISBN in Book.ISBN%type) is
	begin 
		update Book set state_data = 'I' where ISBN = arg_ISBN;
		commit;
	end p_delete_book;
	/
	show errors
	
	-- NOTE: PROCEDURE FOR INSERT SUBGENRE
	PROMPT [ADMIN_LIBRARY: CREATING PROCEDURE FOR INSERT SUBGENRE]
	create or replace procedure p_insert_subgenre(arg_title in Subgenre.title%type) is
	begin
		insert into subgenre(id, title) values (PK_seq_subgenre.nextval, arg_title);
		commit;
	end p_insert_subgenre;
	/
	show errors
	
	PROMPT [ADMIN_LIBRARY: CREATING TRIGGERS]
	-- FORMAT: t_<bf/af>_<OPERATION>_<TABLE>
	
	PROMPT [ADMIN_LIBRARY: CREATING TRIGGERS BEFORE INSERT OR UPDATE BOOK]
	create or replace trigger t_bf_ins_upd_book before insert or update on Book referencing old as item_old new as item_new
	for each row
	begin
			:item_new.title := initcap(:item_new.title);
			:item_new.author_fname := initcap(:item_new.author_fname);
			:item_new.author_lname := initcap(:item_new.author_lname);
			:item_new.editorial := initcap(:item_new.editorial);
			:item_new.idiom := initcap(:item_new.idiom);
	end t_bf_ins_upd_book;
	/
	show errors

	PROMPT [ADMIN_LIBRARY: INSERTING DATA]
	
	PROMPT [ADMIN_LIBRARY: INSERTING USERS]
	execute p_insert_user('library@newton.ma.us', 'Admin1234');
	
	PROMPT [ADMIN_LIBRARY: INSERTING SUBGENRE]
	execute p_insert_subgenre('Novel');
	execute p_insert_subgenre('Poem');
	execute p_insert_subgenre('Tale');
	execute p_insert_subgenre('Biographic');
	execute p_insert_subgenre('Chronicle');
	execute p_insert_subgenre('Fable');
	execute p_insert_subgenre('Essay');
	execute p_insert_subgenre('Drama');
	execute p_insert_subgenre('Comedy');
	execute p_insert_subgenre('Epic');
	
	execute p_insert_book('9788426107824','The Divine Comedy', 'Dante', 'ALIghieri', 'Juventud Editorial', '2009', 'English', '400', 2, 10);
	execute p_insert_book('9780345533661','Defending Jacob', 'William', 'Landay', 'Bantan Editorial', '2012', 'English', '437', 1, 5);
	execute p_insert_book('9788420649672','The Cold War. A very short introduction', 'Robert J.', 'McMahon', 'Alianza Editorial', '2003', 'Spanish', '299', 5, 2);
	execute p_insert_book('9789588940151','Voices from Chernobyl', 'Svetlana', 'Aleksievich', 'Penguin Random House', '2015', 'Spanish', '406', 7, 12);
	execute p_insert_book('9788491046691','History of the Soviet Union', 'Carlos', 'Taibo', 'Alianza Editorial', '2017', 'Spanish', '463', 5, 10);
	execute p_insert_book('9788466342711','Jurassic Park', 'Michael', 'Crichton', 'Penguin Random House', '1990', 'Spanish', '448', 1, 10);
	execute p_insert_book('9788466343756','Jurassic Park: The Lost World', 'Michael', 'Crichton', 'Penguin Random House', '1995', 'Spanish', '393', 1, 5);
	execute p_insert_book('9786070721311','Inferno', 'Dan', 'Brown', 'Planeta Editorial', '2013', 'English', '551', 1, 7);
	execute p_insert_book('9788408176107','Digital Fortress', 'Dan', 'Brown', 'Planeta Editorial', '1998', 'English', '527', 1, 7);
	execute p_insert_book('9788497941488','Homero: The Odyssey and The Iliad', 'Homero', 'Homero', 'EDIMAT', '2015', 'Spanish', '551', 2, 20);
	execute p_insert_book('9780785825050','The Raven', 'Edgar Allan', 'Poe', 'EDIMAT', '2015', 'English', '30', 2, 0);
	
	-- NOTE: FINAL COMMIT;
	commit;
	
	PROMPT [SYSTEM: END OF SCRIPT]