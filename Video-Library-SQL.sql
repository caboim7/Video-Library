-- Deletes all tables with the same name that might exist
drop table genre cascade constraints;
drop table age_requirement cascade constraints;
drop table movie cascade constraints;
drop table idioms cascade constraints;
drop table has cascade constraints;
drop table available_in cascade constraints;
drop table digital cascade constraints;
drop table dvd cascade constraints;
drop table stock cascade constraints;
drop table place cascade constraints;
drop table person cascade constraints;
drop table users cascade constraints;
drop table artist cascade constraints;
drop table actor cascade constraints;
drop table director cascade constraints;
drop table rental cascade constraints;
drop table works cascade constraints;
drop table directed cascade constraints;

-- Deletes all sequences with the same name that exists
drop sequence seq_id_person;
drop sequence seq_id_rental;
-- Genre Table
create table genre (
    genre varchar2(50),
    description varchar2(200) not NULL,
    unique(description),
    primary key(genre)
);

-- Age Requirement Table
create table age_requirement (
    age_rating varchar2(36),
    warnings varchar2(143),
    ageRequired number(2,0) not NULL,
    unique(ageRequired),
    check(ageRequired >= 0),
    primary key(age_rating)
);

-- Movie Table
create table movie (
    nameM varchar2(50),
    release_date date,
    duration number(5,0) not NULL, --saved in seconds
    synopsis varchar2(4000),
    age_rating varchar2(36) not NULL,
    check(duration > 0),
    foreign key (age_rating) references age_requirement(age_rating),
    primary key(nameM, release_date)
);

-- Idioms Table
create table idioms (
    idiom varchar2(20),
    primary key (idiom)
);

-- Has Table (associates movies with genres)
create table has (
    genre varchar2(50),
    nameM varchar2(50),
    release_date date,
    foreign key (genre) references genre(genre),
    foreign key (nameM, release_date) references movie(nameM, release_date),
    primary key (genre, nameM, release_date)
);

-- Available In Table (Associates movies with languages)
create table available_in (
    idiom varchar2(10),
    nameM varchar2(50),
    release_date date,
    foreign key (idiom) references idioms(idiom),
    foreign key (nameM, release_date) references movie(nameM, release_date),
    primary key (idiom, nameM, release_date)
);

-- Digital Table
create table digital (
    resolution varchar2(20) not NULL,
    nameM varchar2(50),
    release_date date,
    foreign key (nameM, release_date) references movie(nameM, release_date),
    primary key (nameM, release_date)
);

-- Place Table (the location of the DVDs)
create table place (
    number_of_shelf number(2,0),
    number_of_hall number(2,0),
    check(number_of_shelf > 0 and number_of_hall > 0),
    primary key (number_of_shelf, number_of_hall)
);

-- Stock Table (Tracks stock of movies)
create table stock (
    stock number(2,0),
    check(stock >= 0),
    primary key(stock)
);

-- DVD Table
create table dvd (
    number_of_shelf number(2,0),
    number_of_hall number(2,0),
    nameM varchar2(50),
    release_date date,
    stock number(2,0),
    check(number_of_shelf > 0 and number_of_hall > 0),
    check(stock >= 0),
    foreign key (number_of_shelf, number_of_hall) references place (number_of_shelf, number_of_hall),
    foreign key (nameM, release_date) references movie(nameM, release_date),
    foreign key (stock) references stock(stock),
    primary key (nameM, release_date)
);

-- Person Table
create table person (
    idPerson number(10),
    date_of_birth date not NULL,
    nameP varchar2(100) not NULL,
    primary key (idPerson)
);

-- Users Table
create table users (
    idPerson number(10),
    email varchar2(50) not NULL,
    nif number(10,0),
    password varchar2(30) not null,
    address varchar2(100),
    unique(email),
    unique(nif),
    foreign key (idPerson) references person(idPerson),
    primary key (idPerson)
);

-- Artist Table
create table artist (
    idPerson number(10),
    nationality varchar2(30),
    biography varchar2(4000),
    foreign key (idPerson) references person(idPerson),
    unique(biography),
    primary key (idPerson)
);

-- Actor Table
create table actor (
    idPerson number(10),
    foreign key (idPerson) references artist(idPerson),
    primary key (idPerson)
);

-- Director Table
create table director (
    idPerson number(10),
    foreign key (idPerson) references artist(idPerson),
    primary key (idPerson)
);

-- Rental Table
create table rental (
    idR number(10),
    date_of_return date not NULL,
    price number(5,2) not NULL,
    idPerson number(10) not NULL,
    nameM varchar2(50) not NULL,
    release_date date not NULL,
    check(price > 0),
    foreign key (idPerson) references users(idPerson),
    foreign key (nameM, release_date) references movie(nameM, release_date),
    unique(date_of_return, idPerson, nameM, release_date),
    primary key (idR)
);

-- Works Table (Associates movies with their actors)
create table works (
    idPerson number(10),
    nameM varchar2(50),
    release_date date,
    foreign key (idPerson) references actor(idPerson),
    foreign key (nameM, release_date) references movie(nameM, release_date),
    primary key (idPerson, nameM, release_date)
);

-- Directed Table (Associates movies with their director)
create table directed (
    idPerson number(10),
    nameM varchar2(50),
    release_date date,
    foreign key (idPerson) references director(idPerson),
    foreign key (nameM, release_date) references movie(nameM, release_date),
    primary key (idPerson, nameM, release_date)
);   


create sequence seq_id_person
start with 1
increment by 1;


create sequence seq_id_rental
start with 1
increment by 1;


--Views


-- View de rental para user access
CREATE OR REPLACE VIEW getRentalsForUsers AS
    SELECT idR, date_of_return, price, nameM, release_date, CALC_TIME(nameM, release_date) as time, synopsis, duration, age_rating, idPerson
    FROM rental NATURAL INNER JOIN person NATURAL INNER JOIN users NATURAL INNER JOIN movie;


-- View de rental para admin access
CREATE OR REPLACE VIEW getRentalsForAdmins AS
    SELECT idR, date_of_return, price, nameM, release_date, idPerson
    FROM rental;

-- Creates a view to get the age of the person
CREATE OR REPLACE VIEW PERSON_VIEW AS
SELECT IDPERSON, NAMEP AS NAME, TRUNC(
        MONTHS_BETWEEN(SYSDATE, date_of_birth)/12) AS AGE, DATE_OF_BIRTH 
FROM PERSON;

-- Creats a view to get all the information regarding the actors
CREATE OR REPLACE VIEW getActors AS
    SELECT *
    FROM actor NATURAL INNER JOIN artist NATURAL INNER JOIN PERSON_VIEW;


-- Creats a view to get all the information regarding the directors
CREATE OR REPLACE VIEW getDirectors AS
    SELECT *
    FROM director NATURAL INNER JOIN artist natural INNER join PERSON_VIEW;


-- Creats a view to get all the information regarding the users
CREATE OR REPLACE VIEW getUsers AS
SELECT *
FROM users NATURAL join person_view;


-- create a view for the digital
create or replace view DigitalView as 
select * 
from digital NATURAL join movie;


-- create a view for the dvd
create or replace view DvdView as 
select * 
from DVD NATURAL join movie;


-- Triggers, procedures, funcs

-- Checks if the user is old enough to rent the movie
CREATE OR REPLACE TRIGGER RENTAL_MINAGE 
INSTEAD OF INSERT ON getRentalsForAdmins 
FOR EACH ROW
DECLARE
    u_age NUMBER;
    min_age NUMBER;
BEGIN
    SELECT TRUNC(
        MONTHS_BETWEEN(SYSDATE, date_of_birth)/12) INTO u_age
    from PERSON
    WHERE idPerson = :NEW.idPerson;

    SELECT(ageRequired) INTO min_age
    FROM AGE_REQUIREMENT
    WHERE age_rating = (
        SELECT age_rating
        FROM MOVIE
        WHERE nameM = :NEW.nameM and release_date = :NEW.release_date
    );

    IF u_age < min_age THEN
        RAISE_APPLICATION_ERROR(-20100, 'This user is not old enough to rent this movie');
    END IF;
END;
/


-- Insert a new rental e in the rental table
CREATE OR REPLACE PROCEDURE Insert_Rental (
    new_nameM IN VARCHAR2,
    new_release_date IN DATE,
    new_idPerson IN NUMBER,
    new_price IN NUMBER,
    new_date_of_return IN DATE
)
AS
    num NUMBER(4);
BEGIN
    SELECT COUNT(*) INTO num
    FROM rental
    WHERE nameM = new_nameM and release_date = new_release_date and idPerson = new_idPerson and date_of_return = new_date_of_return;
    
    IF num <> 0 THEN
        RAISE_APPLICATION_ERROR(-20100, 'Movie already rented by that user with that return date');
    ELSE
        INSERT INTO RENTAL (idR, date_of_return, price, idPerson, nameM, release_date) VALUES (SEQ_ID_RENTAL.NEXTVAL, new_date_of_return, new_price, new_idPerson, new_nameM, new_release_date);
    END IF;
END;
/


-- Trigger para inserir na tabela rental em vez de na view
CREATE OR REPLACE TRIGGER INSERT_INTO_RENTAL 
INSTEAD OF INSERT ON getRentalsForAdmins
    FOR EACH ROW
    BEGIN
        INSERT_RENTAL(:new.nameM, :new.release_date, :new.idPerson, :new.price, :new.date_of_return);
    END;
/



-- Updates the dvd's stock
CREATE OR REPLACE PROCEDURE Update_DVD (
    nnameM IN VARCHAR2,
    nrelease_date IN DATE,
    nstock IN NUMBER
) 
IS
    num NUMBER;
BEGIN 
    select count(stock) into num
    from stock
    where stock = nstock;
    
    if num = 0 then 
        insert into stock(stock) values(nstock);
    end if;

    update dvd
    SET stock = nstock
    WHERE nameM = nnameM and release_date = nrelease_date;
 END;
/


-- Deletes a digital movie
CREATE OR REPLACE TRIGGER DELETE_MOVIE_DIGITAL
AFTER DELETE ON DIGITAL
FOR EACH ROW
BEGIN
    DELETE FROM DIRECTED
    WHERE nameM = :old.nameM and release_date = :old.release_date;

    DELETE FROM HAS
    WHERE nameM = :old.nameM and release_date = :old.release_date;

    DELETE FROM WORKS
    WHERE nameM = :old.nameM and release_date = :old.release_date;

    DELETE FROM AVAILABLE_IN
    WHERE nameM = :old.nameM and release_date = :old.release_date;

    DELETE FROM MOVIE
    WHERE nameM = :old.nameM and release_date = :old.release_date;
END;
/


-- Deletes a dvd
CREATE OR REPLACE TRIGGER DELETE_MOVIE_DVD
AFTER DELETE ON DVD
FOR EACH ROW
BEGIN
    DELETE FROM DIRECTED
    WHERE nameM = :old.nameM and release_date = :old.release_date;

    DELETE FROM HAS
    WHERE nameM = :old.nameM and release_date = :old.release_date;

    DELETE FROM WORKS
    WHERE nameM = :old.nameM and release_date = :old.release_date;

    DELETE FROM AVAILABLE_IN
    WHERE nameM = :old.nameM and release_date = :old.release_date;

    DELETE FROM MOVIE
    WHERE nameM = :old.nameM and release_date = :old.release_date;
END;
/


-- Inserts a dvd into the database
create or replace PROCEDURE Insert_DVD (
    number_of_shelfn IN NUMBER,
    number_of_halln IN NUMBER,
    nnameM IN VARCHAR2,
    nrelease_date IN DATE,
    nstock IN NUMBER
) 
IS
    num NUMBER;
BEGIN 
    select count(stock) into num
    from stock
    where stock = nstock;
    
    if num = 0 then 
        insert into stock(stock) values(nstock);
    end if;

    select count(*) into num
    from place
    where number_of_hall = number_of_halln and number_of_shelf = number_of_shelfn;

    if num = 0 then
        insert into place(number_of_shelf, number_of_hall) values(number_of_shelfn, number_of_halln);
    end if;

    insert into dvd(number_of_shelf, number_of_hall, nameM, release_date, stock) values (number_of_shelfn, number_of_halln, nnameM, nrelease_date, nstock);

 END;
/


-- Adds a rental to the system
CREATE OR REPLACE TRIGGER addRental BEFORE INSERT ON rental
FOR EACH ROW
DECLARE 
    m_count number;
    s number;
BEGIN
    SELECT COUNT(*) INTO m_count
    FROM MOVIE NATURAL INNER JOIN DVD
    WHERE nameM = :new.nameM and release_date = :new.release_date;

    IF(m_count <> 0)
    THEN
    SELECT stock INTO s
    FROM MOVIE NATURAL INNER JOIN DVD
    WHERE nameM = :new.nameM and release_date = :new.release_date;

    IF(s = 0)
    THEN RAISE_APPLICATION_ERROR(-20100, 'DVD does not have enough stock');
    END IF;
    
    UPDATE_DVD(:new.nameM,:new.release_date, (s-1));
    END IF;
END;
/


-- Calculates the duration of the movie
CREATE OR REPLACE FUNCTION CALC_TIME(Mname VARCHAR2, date_release DATE) 
RETURN VARCHAR2
IS
    time VARCHAR2(8);
BEGIN
    SELECT 
    FLOOR(duration / 3600) || ':' ||
    FLOOR(MOD(duration, 3600) / 60) || ':' ||
    MOD(duration, 60) INTO time
    FROM MOVIE
    WHERE nameM = Mname and release_date = date_release;
    RETURN time;
END CALC_TIME; 
/


-- Inserts a digital movie
CREATE OR REPLACE PROCEDURE INSERT_MOVIE_DIGITAL(
    resolution IN VARCHAR2,
    nameM IN VARCHAR2,
    release_date IN DATE,
    synopsis IN VARCHAR2,
    duration IN NUMBER,
    age_rating IN VARCHAR2,
    actors IN VARCHAR2, -- comma-separated
    idioms IN VARCHAR2, -- comma-separated
    genres IN VARCHAR2, -- comma-separated
    directors IN VARCHAR2 -- comma-separated
) 
IS BEGIN 
    INSERT_MOVIE(nameM, release_date, synopsis, duration, age_rating, actors, idioms, genres, directors);  
    INSERT INTO digital(resolution, nameM, release_date) VALUES(resolution, nameM, release_date);  
END;
/


-- inserts a director, if the artist already exists, only inserts in the table director, else inserts in the table director, artist, person because they are isa
create or replace PROCEDURE Insert_Director (
    nameP IN VARCHAR2,
    date_of_birth IN DATE,
    nbiography IN VARCHAR2,
    nationality IN VARCHAR2
)
AS
    idPerson NUMBER(10);
BEGIN
    SELECT idPerson INTO idPerson
    FROM ARTIST
    WHERE biography = nbiography;
    INSERT INTO DIRECTOR (idPerson) VALUES (idPerson);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO PERSON (idPerson, date_of_birth, nameP) 
            VALUES (SEQ_ID_PERSON.NEXTVAL, date_of_birth, nameP);
            
            INSERT INTO ARTIST (idPerson, nationality, biography) 
            VALUES (SEQ_ID_PERSON.CURRVAL, nationality, nbiography);
            
            INSERT INTO DIRECTOR (idPerson) 
            VALUES (SEQ_ID_PERSON.CURRVAL);
END;
/


-- Verifies if an artist is an actor or director or both
CREATE OR REPLACE TRIGGER ARTIST_ISA_DIRECTOR
AFTER INSERT ON DIRECTOR
DECLARE
    a_count NUMBER;
    sum_count NUMBER;
BEGIN
    SELECT COUNT( DISTINCT(idPerson)) INTO a_count
    FROM ARTIST;
    SELECT COUNT( DISTINCT(idPerson)) INTO sum_count
    FROM (
        SELECT idPerson FROM ACTOR
        UNION
        SELECT idPerson FROM DIRECTOR
    );

    IF a_count != sum_count then
        RAISE_APPLICATION_ERROR(-20100, 'An artist must be an actor or director or both');
    END IF;
END;
/


-- Verifies if an artist is an actor or director or both
CREATE OR REPLACE TRIGGER ARTIST_ISA_ACTOR
AFTER INSERT ON ACTOR
DECLARE
    a_count NUMBER;
    sum_count NUMBER;
BEGIN
    SELECT COUNT( DISTINCT(idPerson)) INTO a_count
    FROM ARTIST;
    SELECT COUNT( DISTINCT(idPerson)) INTO sum_count
    FROM (
        SELECT idPerson FROM ACTOR
        UNION
        SELECT idPerson FROM DIRECTOR
    );

    IF a_count != sum_count then
        RAISE_APPLICATION_ERROR(-20100, 'An artist must be an actor or director or both');
    END IF;
END;
/


-- inserts an actor, if the artist already exists, only inserts in the table actor, else inserts in the table actor, artist, person because they are isa
create or replace PROCEDURE Insert_Actor (
    nameP IN VARCHAR2,
    date_of_birth IN DATE,
    nbiography IN VARCHAR2,
    nationality IN VARCHAR2
)
AS
    idP varchar2(10);
BEGIN
    SELECT idPerson INTO idP
    FROM ARTIST
    WHERE biography = nbiography;
    INSERT INTO ACTOR (idPerson) VALUES (idP);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO PERSON (idPerson, date_of_birth, nameP) 
            VALUES (SEQ_ID_PERSON.NEXTVAL, date_of_birth, nameP);
            
            INSERT INTO ARTIST (idPerson, nationality, biography) 
            VALUES (SEQ_ID_PERSON.CURRVAL, nationality, nbiography);
            
            INSERT INTO ACTOR (idPerson) 
            VALUES (SEQ_ID_PERSON.CURRVAL);
END;
/


-- Inserts a director from the view
create or replace trigger insert_director_from_view
        instead of insert on GETDIRECTORS
        for each row
    begin 
        insert_DIRECTOR (:new.name, :new.date_of_birth, :new.BIOGRAPHY, :new.nationality);
    end;
/


-- Deletes a director
create or replace trigger Delete_DIRECTOR
    instead of delete on GETDIRECTORS
for each row 
declare
    a_count NUMBER;
    p_count NUMBER;
begin
    delete from DIRECTOR
    where idPerson = :old.idPerson;

    select count(*) into a_count
    from ACTOR
    where idPerson = :old.idPerson;

    if(a_count = 0)
    then 
        delete from ARTIST
        where idPerson = :old.idPerson;
        delete from PERSON
        where idPerson = :old.idPerson;
    end if;
end;
/


-- Updates a director's biography
create or replace trigger update_biography_director
    instead of update on GETDIRECTORS
    for each row
begin
    update ARTIST
    set biography = :new.biography
    where idPerson = :old.idPerson;
end;
/


-- Update the user's password
create or replace trigger update_password_user
    instead of update on GETUSERS
    for each row
begin
    update USERS
    set password = :new.password
    where idPerson = :old.idPerson;
end;
/


-- Updates the atribute biography of an actor from the table ARITST
create or replace trigger update_biography_actor
    instead of update on GETACTORS
    for each row
begin
    update ARTIST
    set biography = :new.biography
    where idPerson = :old.idPerson;
end;
/


-- Delete an actor from the table ACTOR
create or replace trigger Delete_ACTOR
    instead of delete on GETACTORS
for each row 
declare
 d_count NUMBER;
 p_count NUMBER;
begin
    delete from ACTOR
    where idPerson = :old.idPerson;

    select count(*) into d_count
    from DIRECTOR
    where idPerson = :old.idPerson;

    if(d_count = 0)
    then 
        delete from ARTIST
        where idPerson = :old.idPerson;
        delete from PERSON
        where idPerson = :old.idPerson;
    end if;
end;
/


-- Inserts and actor from the view
create or replace trigger insert_actor_from_view
        instead of insert on GETACTORS
        for each row
    begin 
        insert_ACTOR (:new.name, :new.date_of_birth, :new.BIOGRAPHY, :new.nationality);
    end;
/


-- Adds a new user to the table user.
create or replace trigger insert_user_from_view
        instead of insert on GETUSERS
        for each row
    begin 
        insert_user (:new.name, :new.date_of_birth, :new.email, :new.nif, :new.password, :new.address);
    end;
/


-- Calculate the age of the person by the date of birth.
CREATE OR REPLACE FUNCTION CALC_AGE (date_of_birth DATE)
RETURN NUMBER
IS 
    age NUMBER;
BEGIN
    SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, date_of_birth)/12) AS age INTO age
    FROM PERSON;
END CALC_AGE;
/


-- Delete a user from the table users
create or replace trigger Delete_User
    instead of delete on GETUSERS
for each row 
declare u_count NUMBER;
begin
    delete from USERS
    where idPerson = :old.idPerson;

    delete from PERSON
    where idPerson = :old.idPerson;
end;
/


-- Verifies if people in person are users or artists
CREATE OR REPLACE TRIGGER PERSON_ISA_ARTIST
AFTER INSERT ON ARTIST
DECLARE 
    person_count NUMBER;
    sum_count NUMBER;
BEGIN
    SELECT COUNT( DISTINCT(idPerson)) INTO person_count
    FROM(PERSON);
    SELECT COUNT( DISTINCT(idPerson)) INTO sum_count
    FROM(
        SELECT idPerson FROM ARTIST
        UNION
        SELECT idPerson FROM USERS
    );

    IF person_count != sum_count THEN
        RAISE_APPLICATION_ERROR(-20100, 'A person must be either an artist or a user');
    END IF;
END;
/


-- Movie is digital or dvd
CREATE OR REPLACE TRIGGER MOVIE_ISA_DIGITAL
AFTER INSERT ON DIGITAL
DECLARE
    m_count NUMBER;
    sum_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO m_count
    FROM (
        SELECT DISTINCT nameM, release_date from MOVIE
    );
    SELECT COUNT(*) INTO sum_count
    FROM (
        SELECT DISTINCT nameM, release_date FROM DVD
        UNION
        SELECT DISTINCT nameM, release_date FROM DIGITAL
    );

    IF m_count != sum_count then
        RAISE_APPLICATION_ERROR(-20100, 'A movie must be available in DVD or digitally');
    END IF;
END;
/


-- Same ^^
CREATE OR REPLACE TRIGGER MOVIE_ISA_DVD
AFTER INSERT ON DVD
DECLARE
    m_count NUMBER;
    sum_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO m_count
    FROM (
        SELECT DISTINCT nameM, release_date from MOVIE
    );
    SELECT COUNT(*) INTO sum_count
    FROM (
        SELECT DISTINCT nameM, release_date FROM DVD
        UNION
        SELECT DISTINCT nameM, release_date FROM DIGITAL
    );

    IF m_count != sum_count then
        RAISE_APPLICATION_ERROR(-20100, 'A movie must be available in DVD or digitally');
    END IF;
END;
/


--Verifies if people in person are users or artists
CREATE OR REPLACE TRIGGER PERSON_ISA_USER
AFTER INSERT ON USERS
DECLARE 
    person_count NUMBER;
    sum_count NUMBER;
BEGIN
    SELECT COUNT( DISTINCT(idPerson)) INTO person_count
    FROM(PERSON);
    SELECT COUNT( DISTINCT(idPerson)) INTO sum_count
    FROM(
        SELECT idPerson FROM ARTIST
        UNION
        SELECT idPerson FROM USERS
    );

    IF person_count != sum_count THEN
        RAISE_APPLICATION_ERROR(-20100, 'A person must be either an artist or a user');
    END IF;
END;
/


-- inserts user in the table users and person because its an isa
CREATE OR REPLACE PROCEDURE Insert_User (
    nameP IN VARCHAR2,
    date_of_birth IN DATE,
    nemail IN VARCHAR2,
    nif IN NUMBER,
    password IN VARCHAR2,
    address IN VARCHAR2
)
AS
    num NUMBER(4);
BEGIN
    SELECT COUNT(idPerson) INTO num
    FROM users
    WHERE email = nemail;
    
    IF num <> 0 THEN
        RAISE_APPLICATION_ERROR(-20100, 'User already exits');
    ELSE
        INSERT INTO PERSON (idPerson, date_of_birth, nameP) VALUES (SEQ_ID_PERSON.NEXTVAL, date_of_birth, nameP);
        INSERT INTO USERS (idPerson, email, nif, password, address) VALUES (SEQ_ID_PERSON.CURRVAL, nemail, nif, password, address);
    END IF;
END;
/


-- Insert a dvd movie
CREATE OR REPLACE PROCEDURE INSERT_MOVIE_DVD(
    number_of_shelf IN NUMBER,
    number_of_hall IN NUMBER,
    stock IN NUMBER,
    nameM IN VARCHAR2,
    release_date IN DATE,
    synopsis IN VARCHAR2,
    duration IN NUMBER,
    age_rating IN VARCHAR2,
    actors IN VARCHAR2, -- comma-separated
    idioms IN VARCHAR2, -- comma-separated
    genres IN VARCHAR2, -- comma-separated
    directors IN VARCHAR2 -- comma-separated
) 
IS BEGIN 
    INSERT_MOVIE(nameM, release_date, synopsis, duration, age_rating, actors, idioms, genres, directors);  
    INSERT_DVD(number_of_shelf, number_of_hall, nameM, release_date, stock);  
END;
/


create or replace PROCEDURE ADD_IDIOM (
    idiom_new  IN VARCHAR2,
    nameM_new IN VARCHAR2,
    release_date_new VARCHAR2
)
IS
    idiom_count NUMBER;
    counter NUMBER;
BEGIN
    SELECT COUNT(*) INTO idiom_count FROM IDIOMS WHERE idiom = idiom_new;

    IF idiom_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20100, 'Idiom must exist to be available in a movie.');
    END IF;
    
    SELECT COUNT(*) INTO counter FROM (AVAILABLE_IN INNER JOIN MOVIE USING (nameM, release_date))
        WHERE idiom = idiom_new and nameM = nameM_new and release_date = release_date_new;
    
    if counter = 0 THEN
        INSERT INTO AVAILABLE_IN VALUES(idiom_new, nameM_new, release_date_new);
    END IF;
END;
/


-- Add a new movie to the table movie
CREATE OR REPLACE PROCEDURE Insert_Movie (
    nameM IN VARCHAR2,
    release_date IN DATE,
    synopsis IN VARCHAR2,
    duration IN NUMBER,
    age_rating IN VARCHAR2,
    actors IN VARCHAR2, -- comma-separated
    idioms IN VARCHAR2, -- comma-separated
    genres IN VARCHAR2, -- comma-separated
    directors IN VARCHAR2 -- comma-separated
)
AS
    v_actor NUMBER;
    v_pos NUMBER := 1;
    v_comma_pos NUMBER;
    i_idiom VARCHAR2(255);
    i_pos NUMBER := 1;
    i_comma_pos NUMBER;
    g_genre VARCHAR2(255);
    g_pos NUMBER := 1;
    g_comma_pos NUMBER;
    d_director NUMBER;
    d_pos NUMBER := 1;
    d_comma_pos NUMBER;
BEGIN  
    INSERT INTO movie (nameM, release_date, duration, synopsis, age_rating)
    VALUES (nameM, release_date, duration, synopsis, age_rating);
    
    -- Pieces of code created by Chat GPT and by us
    IF(actors is not null)
    THEN
    LOOP
        v_comma_pos := INSTR(actors, ',', v_pos);
        
        IF v_comma_pos > 0 THEN
            v_actor := TO_NUMBER(SUBSTR(actors, v_pos, v_comma_pos - v_pos));
            v_pos := v_comma_pos + 1;
        ELSE
            v_actor := TO_NUMBER(SUBSTR(actors, v_pos));
            v_pos := LENGTH(actors) + 1;
        END IF;
        
        -- Insert into the works table
        ADD_WORKS(v_actor, nameM, release_date);
        EXIT WHEN v_pos > LENGTH(actors);
    END LOOP;
    ELSE
        RAISE_APPLICATION_ERROR(-20100, 'A movie must have at least one actor.');
    END IF;

    IF(idioms IS NOT NULL)
    THEN
    LOOP
        i_comma_pos := INSTR(idioms, ',', i_pos);
        
        IF i_comma_pos > 0 THEN
            i_idiom := SUBSTR(idioms, i_pos, i_comma_pos - i_pos);
            i_pos := i_comma_pos + 1;
        ELSE
            i_idiom := SUBSTR(idioms, i_pos);
            i_pos := LENGTH(idioms) + 1;
        END IF;
        
        -- Insert into the works table
        ADD_IDIOM(i_idiom, nameM, release_date);
        EXIT WHEN i_pos > LENGTH(idioms);
    END LOOP;
    ELSE
        RAISE_APPLICATION_ERROR(-20100, 'A movie must have at least one idiom.');
    END IF;

    IF(genres IS NOT NULL)
    THEN
    LOOP
        g_comma_pos := INSTR(genres, ',', g_pos);
        
        IF g_comma_pos > 0 THEN
            g_genre := SUBSTR(genres, g_pos, g_comma_pos - g_pos);
            g_pos := g_comma_pos + 1;
        ELSE
            g_genre := SUBSTR(genres, g_pos);
            g_pos := LENGTH(genres) + 1;
        END IF;
        
        -- Insert into the works table
        ADD_HAS(g_genre, nameM, release_date);
        EXIT WHEN g_pos > LENGTH(genres);
    END LOOP;
    ELSE
        RAISE_APPLICATION_ERROR(-20100, 'A movie must have at least one genre.');
    END IF;

    IF(directors is not null)
    then
    LOOP
        d_comma_pos := INSTR(directors, ',', d_pos);
        
        IF d_comma_pos > 0 THEN
            d_director := TO_NUMBER(SUBSTR(directors, d_pos, d_comma_pos - d_pos));
            d_pos := d_comma_pos + 1;
        ELSE
            d_director := TO_NUMBER(SUBSTR(directors, d_pos));
            d_pos := LENGTH(directors) + 1;
        END IF;
        
        -- Insert into the works table
        ADD_DIRECTED(d_director, nameM, release_date);
        EXIT WHEN d_pos > LENGTH(directors);
    END LOOP;
    ELSE
        RAISE_APPLICATION_ERROR(-20100, 'A movie must have at least one director.');
    end if;

END;
/


-- Update the atribute address of a user from the table USERS
create or replace trigger update_address_users
    instead of update on GETUSERS
    for each row
begin
    update USERS
    set address = :new.address
    where idPerson = :old.idPerson;
end;
/


-- This trigger update the atribute email from the table users
create or replace trigger update_email_users
    instead of update on GETUSERS
    for each row
begin
    update USERS
    set email = :new.email
    where idPerson = :old.idPerson;
end;
/


-- Verifies if the genre exists in the database if not gives an error, if the genre doesnt exist in the table HAS inserts.
CREATE OR REPLACE PROCEDURE ADD_HAS (
    genre_new  IN VARCHAR2,
    nameM_new IN VARCHAR2,
    release_date_new IN DATE
)
IS
    genre_count NUMBER;
    counter NUMBER;
BEGIN
    SELECT COUNT(*) INTO genre_count FROM GENRE WHERE genre = genre_new;

    IF genre_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20100, 'Genre must exist to be available in a movie.');
    END IF;
    
    SELECT COUNT(*) INTO counter FROM HAS INNER JOIN MOVIE USING (nameM, release_date)
        WHERE genre = genre_new and nameM = nameM_new and release_date = release_date_new;
    
    if counter = 0 THEN
        INSERT INTO HAS VALUES(genre_new, nameM_new, release_date_new);
    END IF;
END;
/


-- Verifies if the director exists in the database if not gives an error, if the director doesnt exist in the table DIRECTED inserts.
CREATE OR REPLACE PROCEDURE ADD_DIRECTED (
    idPerson_new IN NUMBER,
    nameM_new IN VARCHAR2,
    release_date_new IN DATE
)
IS
    person_count NUMBER;
    counter NUMBER;
BEGIN
    SELECT COUNT(*) INTO person_count FROM (PERSON INNER JOIN DIRECTOR USING (idPerson))WHERE idPerson = idPerson_new;

    IF person_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20100, 'Director must exist to be in a movie.');
    END IF;
    
    SELECT COUNT(*) INTO counter FROM DIRECTED INNER JOIN MOVIE USING (nameM, release_date)
        WHERE idPerson = idPerson_new and nameM= nameM_new and release_date = release_date_new;
    
    if counter = 0 THEN
        INSERT INTO DIRECTED VALUES(idPerson_new, nameM_new, release_date_new);
    END IF;
END;
/


-- Verifies if the actor exists in the database if not gives an error, if the actor doesnt exist in the table WORKS inserts.
CREATE OR REPLACE PROCEDURE ADD_WORKS (
    idPerson_new  IN NUMBER,
    nameM_new IN VARCHAR2,
    release_date_new IN DATE
)
IS
    person_count NUMBER;
    counter NUMBER;
BEGIN
    SELECT COUNT(*) INTO person_count 
    FROM PERSON NATURAL INNER JOIN ARTIST NATURAL INNER JOIN ACTOR 
    WHERE idPerson = idPerson_new;

    IF person_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20100, 'Actor must exist to be in a movie.');
    END IF;
    
    SELECT COUNT(*) INTO counter FROM WORKS INNER JOIN MOVIE USING (nameM, release_date)
        WHERE idPerson = idPerson_new and nameM= nameM_new and release_date = release_date_new;
    
    if counter = 0 THEN
        INSERT INTO WORKS VALUES(idPerson_new, nameM_new, release_date_new);
    END IF;
END;
/


-- Checks if the date of birth is not greater than sysdate
CREATE OR REPLACE TRIGGER PERSON_DATE_OF_BIRTH
    BEFORE INSERT ON PERSON FOR EACH ROW
BEGIN
    IF :NEW.DATE_OF_BIRTH > SYSDATE THEN
       RAISE_APPLICATION_ERROR(-20100, 'Can not create a profile for a person that was not born yet');
    END IF;
END;
/


-- Only allows rentals that the day of return is greater than SYSDATE
CREATE OR REPLACE TRIGGER RENTAL_DATE_OF_RETURN
    BEFORE INSERT ON RENTAL FOR EACH ROW
BEGIN
    IF :NEW.DATE_OF_RETURN <= SYSDATE THEN
       RAISE_APPLICATION_ERROR(-20100, 'Can not create a new rental if the day of return is today or before.');
    END IF;
END;
/


-- Verifies if the movie was released
CREATE OR REPLACE TRIGGER MOVIE_RELEASE_DATE
    BEFORE INSERT ON MOVIE FOR EACH ROW
BEGIN
    IF :NEW.RELEASE_DATE > SYSDATE THEN
       RAISE_APPLICATION_ERROR(-20100, 'Can not create a movie that was not released yet');
    END IF;
END;
/



insert into AGE_REQUIREMENT values('G - General Audiences', 'Depictions of violence are minimal. No nudity, sex scenes or drug use are present in the motion picture.', 0);
insert into AGE_REQUIREMENT values('PG - Parental Guidance Suggested', 'There may be some profanity and some depictions of violence or brief nudity.', 7);
insert into AGE_REQUIREMENT values('PG-13 - Parents Strongly Cautioned', 'violence, nudity, sensuality, language, adult activities or other elements', 13);
insert into AGE_REQUIREMENT values('R - Restricted', 'may include adult themes, adult activity, hard language, intense or persistent violence, sexually-oriented nudity, drug abuse or other elements', 17);
insert into AGE_REQUIREMENT values('NC-17 - Adults Only', 'violence, sex, aberrational behavior, drug abuse', 18);


INSERT INTO idioms (idiom) VALUES ('Afrikaans');
INSERT INTO idioms (idiom) VALUES ('Akan');
INSERT INTO idioms (idiom) VALUES ('Albanian');
INSERT INTO idioms (idiom) VALUES ('Amharic');
INSERT INTO idioms (idiom) VALUES ('Arabic');
INSERT INTO idioms (idiom) VALUES ('Armenian');
INSERT INTO idioms (idiom) VALUES ('Assamese');
INSERT INTO idioms (idiom) VALUES ('Aymara');
INSERT INTO idioms (idiom) VALUES ('Azerbaijani');
INSERT INTO idioms (idiom) VALUES ('Balochi');
INSERT INTO idioms (idiom) VALUES ('Bambara');
INSERT INTO idioms (idiom) VALUES ('Bashkir');
INSERT INTO idioms (idiom) VALUES ('Basque');
INSERT INTO idioms (idiom) VALUES ('Belarusian');
INSERT INTO idioms (idiom) VALUES ('Bengali');
INSERT INTO idioms (idiom) VALUES ('Bhojpuri');
INSERT INTO idioms (idiom) VALUES ('Bislama');
INSERT INTO idioms (idiom) VALUES ('Bosnian');
INSERT INTO idioms (idiom) VALUES ('Breton');
INSERT INTO idioms (idiom) VALUES ('Bulgarian');
INSERT INTO idioms (idiom) VALUES ('Burmese');
INSERT INTO idioms (idiom) VALUES ('Cantonese');
INSERT INTO idioms (idiom) VALUES ('Catalan');
INSERT INTO idioms (idiom) VALUES ('Cebuano');
INSERT INTO idioms (idiom) VALUES ('Chamorro');
INSERT INTO idioms (idiom) VALUES ('Chechen');
INSERT INTO idioms (idiom) VALUES ('Cherokee');
INSERT INTO idioms (idiom) VALUES ('Chichewa');
INSERT INTO idioms (idiom) VALUES ('Chinese');
INSERT INTO idioms (idiom) VALUES ('Chuvash');
INSERT INTO idioms (idiom) VALUES ('Cornish');
INSERT INTO idioms (idiom) VALUES ('Corsican');
INSERT INTO idioms (idiom) VALUES ('Croatian');
INSERT INTO idioms (idiom) VALUES ('Czech');
INSERT INTO idioms (idiom) VALUES ('Danish');
INSERT INTO idioms (idiom) VALUES ('Dari');
INSERT INTO idioms (idiom) VALUES ('Dhivehi');
INSERT INTO idioms (idiom) VALUES ('Dutch');
INSERT INTO idioms (idiom) VALUES ('Dzongkha');
INSERT INTO idioms (idiom) VALUES ('English');
INSERT INTO idioms (idiom) VALUES ('Esperanto');
INSERT INTO idioms (idiom) VALUES ('Estonian');
INSERT INTO idioms (idiom) VALUES ('Ewe');
INSERT INTO idioms (idiom) VALUES ('Faroese');
INSERT INTO idioms (idiom) VALUES ('Fijian');
INSERT INTO idioms (idiom) VALUES ('Filipino');
INSERT INTO idioms (idiom) VALUES ('Finnish');
INSERT INTO idioms (idiom) VALUES ('Flemish');
INSERT INTO idioms (idiom) VALUES ('French');
INSERT INTO idioms (idiom) VALUES ('Frisian');
INSERT INTO idioms (idiom) VALUES ('Galician');
INSERT INTO idioms (idiom) VALUES ('Georgian');
INSERT INTO idioms (idiom) VALUES ('German');
INSERT INTO idioms (idiom) VALUES ('Greek');
INSERT INTO idioms (idiom) VALUES ('Guarani');
INSERT INTO idioms (idiom) VALUES ('Gujarati');
INSERT INTO idioms (idiom) VALUES ('Haitian Creole');
INSERT INTO idioms (idiom) VALUES ('Hausa');
INSERT INTO idioms (idiom) VALUES ('Hawaiian');
INSERT INTO idioms (idiom) VALUES ('Hebrew');
INSERT INTO idioms (idiom) VALUES ('Hindi');
INSERT INTO idioms (idiom) VALUES ('Hmong');
INSERT INTO idioms (idiom) VALUES ('Hungarian');
INSERT INTO idioms (idiom) VALUES ('Icelandic');
INSERT INTO idioms (idiom) VALUES ('Igbo');
INSERT INTO idioms (idiom) VALUES ('Ilocano');
INSERT INTO idioms (idiom) VALUES ('Indonesian');
INSERT INTO idioms (idiom) VALUES ('Inuktitut');
INSERT INTO idioms (idiom) VALUES ('Irish');
INSERT INTO idioms (idiom) VALUES ('Italian');
INSERT INTO idioms (idiom) VALUES ('Japanese');
INSERT INTO idioms (idiom) VALUES ('Javanese');
INSERT INTO idioms (idiom) VALUES ('Kannada');
INSERT INTO idioms (idiom) VALUES ('Kazakh');
INSERT INTO idioms (idiom) VALUES ('Khmer');
INSERT INTO idioms (idiom) VALUES ('Kinyarwanda');
INSERT INTO idioms (idiom) VALUES ('Kirundi');
INSERT INTO idioms (idiom) VALUES ('Korean');
INSERT INTO idioms (idiom) VALUES ('Kurdish');
INSERT INTO idioms (idiom) VALUES ('Kyrgyz');
INSERT INTO idioms (idiom) VALUES ('Lao');
INSERT INTO idioms (idiom) VALUES ('Latin');
INSERT INTO idioms (idiom) VALUES ('Latvian');
INSERT INTO idioms (idiom) VALUES ('Lingala');
INSERT INTO idioms (idiom) VALUES ('Lithuanian');
INSERT INTO idioms (idiom) VALUES ('Luxembourgish');
INSERT INTO idioms (idiom) VALUES ('Macedonian');
INSERT INTO idioms (idiom) VALUES ('Malagasy');
INSERT INTO idioms (idiom) VALUES ('Malay');
INSERT INTO idioms (idiom) VALUES ('Malayalam');
INSERT INTO idioms (idiom) VALUES ('Maltese');
INSERT INTO idioms (idiom) VALUES ('Maori');
INSERT INTO idioms (idiom) VALUES ('Marathi');
INSERT INTO idioms (idiom) VALUES ('Marshallese');
INSERT INTO idioms (idiom) VALUES ('Mongolian');
INSERT INTO idioms (idiom) VALUES ('Nauruan');
INSERT INTO idioms (idiom) VALUES ('Navajo');
INSERT INTO idioms (idiom) VALUES ('Nepali');
INSERT INTO idioms (idiom) VALUES ('Norwegian');
INSERT INTO idioms (idiom) VALUES ('Oriya');
INSERT INTO idioms (idiom) VALUES ('Oromo');
INSERT INTO idioms (idiom) VALUES ('Ossetian');
INSERT INTO idioms (idiom) VALUES ('Papiamento');
INSERT INTO idioms (idiom) VALUES ('Pashto');
INSERT INTO idioms (idiom) VALUES ('Persian');
INSERT INTO idioms (idiom) VALUES ('Polish');
INSERT INTO idioms (idiom) VALUES ('Portuguese');
INSERT INTO idioms (idiom) VALUES ('Punjabi');
INSERT INTO idioms (idiom) VALUES ('Quechua');
INSERT INTO idioms (idiom) VALUES ('Romanian');
INSERT INTO idioms (idiom) VALUES ('Russian');
INSERT INTO idioms (idiom) VALUES ('Samoan');
INSERT INTO idioms (idiom) VALUES ('Sanskrit');
INSERT INTO idioms (idiom) VALUES ('Scots Gaelic');
INSERT INTO idioms (idiom) VALUES ('Serbian');
INSERT INTO idioms (idiom) VALUES ('Sesotho');
INSERT INTO idioms (idiom) VALUES ('Shona');
INSERT INTO idioms (idiom) VALUES ('Sindhi');
INSERT INTO idioms (idiom) VALUES ('Sinhala');
INSERT INTO idioms (idiom) VALUES ('Slovak');
INSERT INTO idioms (idiom) VALUES ('Slovenian');
INSERT INTO idioms (idiom) VALUES ('Somali');
INSERT INTO idioms (idiom) VALUES ('Spanish');
INSERT INTO idioms (idiom) VALUES ('Sundanese');
INSERT INTO idioms (idiom) VALUES ('Swahili');
INSERT INTO idioms (idiom) VALUES ('Swedish');
INSERT INTO idioms (idiom) VALUES ('Tajik');
INSERT INTO idioms (idiom) VALUES ('Tamil');
INSERT INTO idioms (idiom) VALUES ('Tatar');
INSERT INTO idioms (idiom) VALUES ('Telugu');
INSERT INTO idioms (idiom) VALUES ('Thai');
INSERT INTO idioms (idiom) VALUES ('Tigrinya');
INSERT INTO idioms (idiom) VALUES ('Tongan');
INSERT INTO idioms (idiom) VALUES ('Turkish');
INSERT INTO idioms (idiom) VALUES ('Turkmen');
INSERT INTO idioms (idiom) VALUES ('Twi');
INSERT INTO idioms (idiom) VALUES ('Ukrainian');
INSERT INTO idioms (idiom) VALUES ('Urdu');
INSERT INTO idioms (idiom) VALUES ('Uzbek');
INSERT INTO idioms (idiom) VALUES ('Vietnamese');
INSERT INTO idioms (idiom) VALUES ('Welsh');
INSERT INTO idioms (idiom) VALUES ('Wolof');
INSERT INTO idioms (idiom) VALUES ('Xhosa');
INSERT INTO idioms (idiom) VALUES ('Yiddish');
INSERT INTO idioms (idiom) VALUES ('Yoruba');
INSERT INTO idioms (idiom) VALUES ('Zulu');


--Users
BEGIN
    Insert_User('João Silva', DATE '2005-04-10', 'joao.silva@example.com', 123456789, 'joaos_password', 'Rua Principal, 123, Lisboa, Portugal');
    Insert_User('Ana Santos', DATE '1980-08-15', 'ana.santos@example.com', 987654321, 'anas_password', 'Avenida das Flores, 456, Porto, Portugal');
    Insert_User('Miguel Costa', DATE '1999-12-20', 'miguel.costa@example.com', 135792468, 'miguels_password', 'Rua do Carmo, 789, Braga, Portugal');
    Insert_User('Sofia Pereira', DATE '1975-03-05', 'sofia.pereira@example.com', 246813579, 'sofias_password', 'Praceta das Rosas, 101, Faro, Portugal');
    Insert_User('Rafaela Oliveira', DATE '2010-11-25', 'rafaela.oliveira@example.com', 369258147, 'rafaelas_password', 'Largo da Liberdade, 202, Coimbra, Portugal');
    Insert_User('Diogo Martins', DATE '1992-06-12', 'diogo.martins@example.com', 975318624, 'diogos_password', 'Travessa da Paz, 303, Aveiro, Portugal');
    Insert_User('Carolina Almeida', DATE '1988-09-30', 'carolina.almeida@example.com', 852147963, 'carolinas_password', 'Rua dos Cedros, 404, Viseu, Portugal');
    Insert_User('Tiago Gonçalves', DATE '2003-02-17', 'tiago.goncalves@example.com', 741852963, 'tiagos_password', 'Avenida dos Pinheiros, 505, Évora, Portugal');
    Insert_User('Inês Fernandes', DATE '1970-07-08', 'ines.fernandes@example.com', 159632487, 'inesf_password', 'Rua da Esperança, 606, Guimarães, Portugal');
    Insert_User('Pedro Rodrigues', DATE '2000-05-03', 'pedro.rodrigues@example.com', 852963741, 'pedror_password', 'Rua das Oliveiras, 707, Setúbal, Portugal');  
    Insert_User('Beatriz Carvalho', DATE '1996-09-18', 'beatriz.carvalho@example.com', 369147258, 'beatrizc_password', 'Rua dos Girassóis, 808, Lisboa, Portugal');
    Insert_User('Hugo Sousa', DATE '1985-12-27', 'hugo.sousa@example.com', 852369741, 'hugos_password', 'Avenida Central, 909, Porto, Portugal');
    Insert_User('Mariana Matos', DATE '2002-03-14', 'mariana.matos@example.com', 741852964, 'marianam_password', 'Praça da República, 1010, Braga, Portugal');
    Insert_User('Rui Oliveira', DATE '1978-06-30', 'rui.oliveira@example.com', 159753486, 'ruiol_password', 'Largo do Pelourinho, 1111, Faro, Portugal');
    Insert_User('Sara Pereira', DATE '1990-05-21', 'sara.pereira@example.com', 258369147, 'sarap_password', 'Avenida das Palmeiras, 1212, Coimbra, Portugal');
END;
/



--Genres
INSERT INTO GENRE (genre, description) 
VALUES ('Drama', 'Movies intended to be serious, focused on realistic characters and emotional themes.');
INSERT INTO GENRE (genre, description) 
VALUES ('Crime', 'Movies focused on criminal activities, often involving law enforcement and investigations.');
INSERT INTO GENRE (genre, description) 
VALUES ('Action', 'Movies characterized by intense sequences of physical feats, often including violence and combat.');
INSERT INTO GENRE (genre, description) 
VALUES ('Adventure', 'Movies involving exciting and unusual experiences, often with a focus on exploration and discovery.');
INSERT INTO GENRE (genre, description) 
VALUES ('Fantasy', 'Movies featuring magical or supernatural elements, often set in imaginary worlds.');
INSERT INTO GENRE (genre, description) 
VALUES ('Thriller', 'Movies characterized by suspense, excitement, and tension, often involving crime or espionage.');
INSERT INTO GENRE (genre, description) 
VALUES ('Sci-Fi', 'Movies focused on speculative fiction, exploring imaginative concepts such as advanced science and technology.');
INSERT INTO GENRE (genre, description) 
VALUES ('Comedy', 'Movies intended to be humorous or amusing, often featuring exaggerated characters and situations.');
INSERT INTO GENRE (genre, description) 
VALUES ('Biography', 'Movies based on the life stories of real people, often depicting their achievements, struggles, and personal experiences.');
INSERT INTO GENRE (genre, description) 
VALUES ('History', 'Movies set in the past, often depicting historical events, figures, and periods.');
INSERT INTO GENRE (genre, description) 
VALUES ('Animation', 'Movies created through animation techniques, including hand-drawn, computer-generated, and stop-motion animation.');
INSERT INTO GENRE (genre, description) 
VALUES ('Western', 'The Western is a genre of fiction typically set in the American frontier between the California Gold Rush of 1849.');


--artists
BEGIN
    -- Actors for 'Inception'
    Insert_Actor('Leonardo DiCaprio', DATE '1974-11-11', 'An American actor and film producer born November 11, 1974.', 'American');
    Insert_Actor('Joseph Gordon-Levitt', DATE '1981-02-17', 'An American actor, filmmaker, singer, and entrepreneur.', 'American');
    Insert_Actor('Ellen Page', DATE '1987-02-21', 'A Canadian actor and producer.', 'Canadian');
    
    -- Director for 'Inception'
    Insert_Director('Christopher Nolan', DATE '1970-07-30', 'A British-American film director, producer, and screenwriter.', 'British-American');
    
    -- Actors for 'Interstellar'
    Insert_Actor('Matthew McConaughey', DATE '1969-11-04', 'An American actor and producer born November 4, 1969.', 'American');
    Insert_Actor('Anne Hathaway', DATE '1982-11-12', 'An American actress.', 'American');
    Insert_Actor('Jessica Chastain', DATE '1977-03-24', 'An American actress and producer.', 'American');
    
    -- Actors for 'Gladiator'
    Insert_Actor('Russell Crowe', DATE '1964-04-07', 'A New Zealand actor, film producer, and musician.', 'New Zealander');
    Insert_Actor('Joaquin Phoenix', DATE '1974-10-28', 'An American actor, producer, and activist.', 'American');
    Insert_Actor('Connie Nielsen', DATE '1965-07-03', 'A Danish actress.', 'Danish');
    
    -- Director for 'Gladiator'
    Insert_Director('Ridley Scott', DATE '1937-11-30', 'A British film director and producer.', 'British');
    
    -- Actors for 'The Lion King'
    Insert_Actor('Matthew Broderick', DATE '1962-03-21', 'An American actor and singer.', 'American');
    Insert_Actor('Jeremy Irons', DATE '1948-09-19', 'An English actor.', 'English');
    Insert_Actor('James Earl Jones', DATE '1931-01-17', 'An American actor.', 'American');
    
    -- Directors for 'The Lion King'
    Insert_Director('Roger Allers', DATE '1949-06-29', 'An American film director, screenwriter, storyboard artist, animator, and playwright.', 'American');
    Insert_Director('Rob Minkoff', DATE '1962-08-11', 'An American filmmaker.', 'American');
    
    -- Actors for 'Saving Private Ryan'
    Insert_Actor('Tom Hanks', DATE '1956-07-09', 'Thomas Jeffrey Hanks is an American actor and filmmaker. Known for both his comedic and dramatic roles, he is one of the most popular and recognizable film stars worldwide', 'American');
    Insert_Actor('Matt Damon', DATE '1970-10-08', 'An American actor, producer, and screenwriter.', 'American');
    Insert_Actor('Tom Sizemore', DATE '1961-11-29', 'Thomas Edward Sizemore Jr. was an American actor.', 'American');
    
    -- Director for 'Saving Private Ryan'
    Insert_Director('Steven Spielberg', DATE '1946-12-18', 'An American film director, producer, and screenwriter.', 'American');
    
    -- Actors for 'Jurassic Park'
    Insert_Actor('Sam Neill', DATE '1947-09-14', 'A New Zealand actor, director, producer, and screenwriter.', 'New Zealander');
    Insert_Actor('Laura Dern', DATE '1967-02-10', 'An American actress and filmmaker.', 'American');
    Insert_Actor('Jeff Goldblum', DATE '1952-10-22', 'An American actor and musician. ', 'American');
    
    
    -- Actors for 'The Silence of the Lambs'
    Insert_Actor('Jodie Foster', DATE '1962-11-19', 'An American actress, director, and producer.', 'American');
    Insert_Actor('Anthony Hopkins', DATE '1937-12-31', 'A Welsh actor, director, and producer.', 'Welsh');
    Insert_Actor('Lawrence A. Bonney', DATE '1935-01-20', 'Bonney is an American actor best remembered for his only film role in the Academy Award winning film The Silence of the Lambs.', 'American');
    
    -- Director for 'The Silence of the Lambs'
    Insert_Director('Jonathan Demme', DATE '1944-02-22', 'An American director, producer, and screenwriter.', 'American');
    
    -- Actors for 'Se7en'
    Insert_Actor('Morgan Freeman', DATE '1937-06-01', 'An American actor, director, and narrator.', 'American');
    Insert_Actor('Brad Pitt', DATE '1963-12-18', 'An American actor and film producer.', 'American');
    Insert_Actor('Kevin Spacey', DATE '1959-07-26', 'An American actor and producer.', 'American');
    
    -- Director for 'Se7en'
    Insert_Director('David Fincher', DATE '1962-08-28', 'An American film director.', 'American');
    
    -- Actors for 'Braveheart'
    Insert_Actor('Mel Gibson', DATE '1956-01-03', 'An American actor, film director, producer, and screenwriter.', 'American');
    Insert_Actor('Sophie Marceau', DATE '1966-11-17', 'A French actress, director, screenwriter, and author.', 'French');
    Insert_Actor('Patrick McGoohan', DATE '1928-03-19', 'An American-born actor, writer, and director.', 'American');
    
    -- Director for 'Braveheart'
    Insert_Director('Mel Gibson', DATE '1956-01-03', 'An American actor, film director, producer, and screenwriter.', 'American');
    
    -- Actors for 'The Green Mile'
    Insert_Actor('Michael Clarke Duncan', DATE '1957-12-10', 'Michael Clarke Duncan was an American actor. He was best known for his breakout role as John Coffey in The Green Mile', 'American');
    Insert_Actor('David Morse', DATE '1953-10-11', 'An American actor, singer, director, and writer.', 'American');
    
    -- Director for 'The Green Mile'
    Insert_Director('Frank Darabont', DATE '1959-01-28', 'A French-American film director, screenwriter, and producer.', 'French-American');
    
    -- Actors for 'The Departed'
    Insert_Actor('Jack Nicholson', DATE '1937-04-22', 'An American actor and filmmaker.', 'American');
    
    -- Director for 'The Departed'
    Insert_Director('Martin Scorsese', DATE '1942-11-17', 'An American film director, producer, screenwriter, and actor.', 'American');
    
    -- Actors for 'Whiplash'
    Insert_Actor('Miles Teller', DATE '1987-02-20', 'An American actor and musician.', 'American');
    Insert_Actor('J.K. Simmons', DATE '1955-01-09', 'Jonathan Kimble Simmons is an American actor. Considered one of the most eminent male character actors of his generation', 'American');
    Insert_Actor('Melissa Benoist', DATE '1988-10-04', 'An American actress and singer.', 'American');
    
    -- Director for 'Whiplash'
    Insert_Director('Damien Chazelle', DATE '1985-01-19', 'Damien Sayre Chazelle is an American filmmaker', 'American');

END;
/

BEGIN
    Insert_Actor('Marlon Brando', DATE '1924-04-03', 'Marlon Brando was an American actor and film director with a career spanning 60 years, during which he won multiple Academy Awards for his performances.', 'American');
    Insert_Actor('Heath Ledger', DATE '1979-04-04', 'Heath Ledger was an Australian actor and director. After performing roles in several Australian television and film productions during the 1990s, Ledger left for the United States in 1998 to further develop his film career.', 'Australian');
    Insert_Actor('Al Pacino', DATE '1940-04-25', 'Al Pacino is an American actor and filmmaker. He is best known for his roles as Michael Corleone in The Godfather trilogy, Tony Montana in Scarface, and Frank Serpico in Serpico.', 'American');
    Insert_Actor('Ian McKellen', DATE '1939-05-25', 'Sir Ian McKellen is an English actor. His work has spanned genres from Shakespearean and modern theatre to popular fantasy and science fiction. He is widely regarded as one of the greatest actors of his generation.', 'English');
    Insert_Actor('Samuel L. Jackson', DATE '1948-12-21', 'Samuel L. Jackson is an American actor and producer. Widely regarded as one of the most popular actors of his generation, the films in which he has appeared have collectively grossed over $27 billion worldwide.', 'American');
    Insert_Actor('Liam Neeson', DATE '1952-06-07', 'Liam Neeson is an actor from Northern Ireland. He has been nominated for several awards, including an Academy Award for Best Actor, a BAFTA Award for Best Actor in a Leading Role, and three Golden Globe Awards for Best Actor in a Motion Picture Drama.', 'Northern Irish');
    Insert_Actor('Keanu Reeves', DATE '1964-09-02', 'Keanu Reeves is a Canadian actor. He gained fame for his starring roles in several blockbuster films, including comedies from the Bill and Ted franchise and action thrillers such as Speed and The Matrix trilogy.', 'Canadian');
    Insert_Actor('Tim Robbins', DATE '1958-10-16', 'Tim Robbins is an American actor, screenwriter, director, producer, and musician. He is best known for his portrayal of Andy Dufresne in the prison drama film The Shawshank Redemption.', 'American');
    Insert_Actor('Robert De Niro', DATE '1943-08-17', 'Robert De Niro is an American actor, producer, and director who holds both American and Italian citizenship. He is particularly known for his collaborations with director Martin Scorsese.', 'American');
    Insert_Actor('Christian Bale', DATE '1974-01-30', 'Christian Bale is an English actor known for his intense method acting style, often transforming his body drastically for his roles. He has received critical acclaim for his work in various genres.', 'British');
    Insert_Actor('Sean Astin', DATE '1971-02-25', 'Sean Astin is an American actor, voice actor, director, and producer. He is best known for his film roles as Samwise Gamgee in The Lord of the Rings trilogy, Mikey Walsh in The Goonies, and the title character of Rudy.', 'American');
    Insert_Actor('Uma Thurman', DATE '1970-04-29', 'Uma Thurman is an American actress and model. She has performed in a variety of films, from romantic comedies and dramas to science fiction and action movies.', 'American');
    Insert_Actor('John Travolta', DATE '1954-02-18', 'John Travolta is an American actor, singer, dancer, and pilot. He first gained fame in the 1970s, appearing on the television series Welcome Back, Kotter and starring in the box office successes Saturday Night Fever and Grease.', 'American');
    Insert_Actor('Gary Oldman', DATE '1958-03-21', 'Gary Oldman is an English actor and filmmaker. He is known for his versatility and intense portrayals of complex characters. He has received various awards throughout his career, including an Academy Award, a Golden Globe, and a BAFTA Award.', 'English');
    Insert_Actor('Robin Wright', DATE '1966-04-08', 'Robin Wright is an American actress and director. She has won a Golden Globe Award and a Satellite Award, and received nominations for seven Primetime Emmy Awards and a Screen Actors Guild Award.', 'American');
    Insert_Actor('Laurence Fishburne', DATE '1961-07-30', 'Laurence Fishburne is an American actor, playwright, producer, screenwriter, and film director. He is known for playing Morpheus in The Matrix trilogy, Jason "Furious" Styles in Boyz n the Hood, and Tyrone "Mr. Clean" Miller in Apocalypse Now.', 'American');
    Insert_Actor('Helena Bonham Carter', DATE '1966-05-26', 'Helena Bonham Carter is an English actress. Known for her roles in independent films and large-scale blockbusters, she has received various accolades, including a British Academy Film Award and a Screen Actors Guild Award.', 'British');
    Insert_Actor('Bruce Dern', DATE '1936-06-04', 'Bruce Dern is an American actor, often playing supporting villainous characters of unstable nature. He has been nominated for two Academy Awards and four Golden Globe Awards.', 'American');
    Insert_Actor('Joe Pesci', DATE '1943-02-09', 'Joe Pesci is an American actor and musician. He is known for portraying tough, volatile characters in a variety of genres and is best known for his collaborations with director Martin Scorsese.', 'American');
    Insert_Actor('Cate Blanchett', DATE '1969-05-14', 'Cate Blanchett is an Australian actress. She is known for her roles in both blockbusters and independent films and has received numerous accolades, including two Academy Awards, three Golden Globe Awards, and three British Academy Film Awards.', 'Australian');
    Insert_Actor('Johnny Depp', DATE '1963-06-09', 'Johnny Depp is an American actor.', 'American');
END;
/


-- Insert directors using the procedure
BEGIN
    Insert_Director('Francis Ford Coppola', DATE '1939-04-07', 'Francis Ford Coppola is an American film director, producer, and screenwriter. He was a central figure in the New Hollywood filmmaking movement of the 1960s and 1970s, and is widely considered to be one of the greatest filmmakers of all time.', 'American');
    Insert_Director('Peter Jackson', DATE '1961-10-31', 'Sir Peter Jackson is a New Zealand film director, producer, and screenwriter. He is best known for directing The Lord of the Rings film trilogy, which earned him three Academy Awards, including Best Director.', 'New Zealander');
    Insert_Director('Quentin Tarantino', DATE '1963-03-27', 'Quentin Tarantino is an American film director, screenwriter, producer, and actor. His films are characterized by nonlinear storylines, stylized violence, extended dialogue scenes, ensemble casts, references to popular culture, and soundtracks primarily consisting of songs from the 1960s to the 1980s.', 'American');
    Insert_Director('Martin Scorsese', DATE '1942-11-17', 'Martin Scorsese is an American film director, producer, screenwriter, and actor. He is widely regarded as one of the greatest directors in the history of cinema, with a career spanning more than 50 years and encompassing a wide range of film genres.', 'American');
    Insert_Director('Robert Zemeckis', DATE '1951-05-14', 'Robert Zemeckis is an American film director, producer, and screenwriter. He is known for his visual effects-driven films, including the Back to the Future trilogy, Who Framed Roger Rabbit, and Forrest Gump.', 'American');
    Insert_Director('Lana Wachowski', DATE '1965-06-21', 'Lana Wachowski is an American film director, screenwriter, and producer. She is best known for co-directing The Matrix trilogy with her sister, Lilly Wachowski.', 'American');
    Insert_Director('Lilly Wachowski', DATE '1967-12-29', 'Lilly Wachowski is an American film director, screenwriter, and producer. She is best known for co-directing The Matrix trilogy with her sister, Lana Wachowski.', 'American');
    Insert_Director('James Cameron', DATE '1954-08-16', 'James Cameron is a Canadian film director, producer, and screenwriter. He is known for his work on science fiction and epic films, including The Terminator, Aliens, Titanic, and Avatar.', 'Canadian');
END;
/


--movies
BEGIN
    INSERT_MOVIE_DVD(
        1,
        10,
        10,
        'Inception',
        DATE '2010-07-16',
        'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.',
        8880,
        'PG-13 - Parents Strongly Cautioned',
        '16,17,18',
        'English',
        'Action,Adventure,Sci-Fi',
        '19'
    );

    INSERT_MOVIE_DVD(
        2,
        20,
        5,
        'Interstellar',
        DATE '2014-11-07',
        'A team of explorers travel through a wormhole in space in an attempt to ensure humanitys survival.',
        10140,
        'PG-13 - Parents Strongly Cautioned',
        '20,21,22',
        'English',
        'Adventure,Drama,Sci-Fi',
        '19'
    );

    INSERT_MOVIE_DVD(
        3,
        30,
        8,
        'Gladiator',
        DATE '2000-05-05',
        'A former Roman General sets out to exact vengeance against the corrupt emperor who murdered his family and sent him into slavery.',
        9240,
        'R - Restricted',
        '23,24,25',
        'English',
        'Action,Adventure,Drama',
        '26'
    );

    INSERT_MOVIE_DVD(
        4,
        40,
        7,
        'The Lion King',
        DATE '1994-06-24',
        'Lion prince Simba and his father are targeted by his bitter uncle, who wants to ascend the throne himself.',
        5280,
        'G - General Audiences',
        '27,28,29',
        'English',
        'Animation,Adventure,Drama',
        '30,31'
    );

    INSERT_MOVIE_DVD(
        5,
        50,
        6,
        'Saving Private Ryan',
        DATE '1998-07-24',
        'Following the Normandy Landings, a group of U.S. soldiers go behind enemy lines to retrieve a paratrooper whose brothers have been killed in action.',
        10140,
        'R - Restricted',
        '32,33,34',
        'English',
        'Drama',
        '35'
    );

    INSERT_MOVIE_DVD(
        6,
        60,
        4,
        'Jurassic Park',
        DATE '1993-06-11',
        'During a preview tour, a theme park suffers a major power breakdown that allows its cloned dinosaur exhibits to run amok.',
        7620,
        'PG-13 - Parents Strongly Cautioned',
        '36,37,38',
        'English',
        'Adventure,Sci-Fi,Thriller',
        '35'
    );

    INSERT_MOVIE_DVD(
        7,
        70,
        3,
        'The Silence of the Lambs',
        DATE '1991-02-14',
        'A young F.B.I. cadet must receive the help of an incarcerated and manipulative cannibal killer to help catch another serial killer, a madman who skins his victims.',
        7080,
        'R - Restricted',
        '39,40,41',
        'English',
        'Crime,Drama,Thriller',
        '42'
    );

    INSERT_MOVIE_DVD(
        8,
        80,
        9,
        'Se7en',
        DATE '1995-09-22',
        'Two detectives, a rookie and a veteran, hunt a serial killer who uses the seven deadly sins as his motives.',
        7620,
        'R - Restricted',
        '43,44,45',
        'English',
        'Crime,Drama',
        '46'
    );

    INSERT_MOVIE_DVD(
        9,
        90,
        12,
        'Braveheart',
        DATE '1995-05-24',
        'Scottish warrior William Wallace leads his countrymen in a rebellion to free his homeland from the tyranny of King Edward I of England.',
        10740,
        'R - Restricted',
        '47,48,49',
        'English',
        'Biography,Drama,History',
        '47'
    );

    INSERT_MOVIE_DVD(
        10,
        10,
        11,
        'The Green Mile',
        DATE '1999-12-10',
        'The lives of guards on Death Row are affected by one of their charges: a black man accused of child murder and rape, yet who has a mysterious gift.',
        11460,
        'R - Restricted',
        '32,50,51',
        'English',
        'Crime,Drama,Fantasy',
        '52'
    );

    INSERT_MOVIE_DVD(
        11,
        11,
        14,
        'The Departed',
        DATE '2006-10-06',
        'An undercover cop and a mole in the police attempt to identify each other while infiltrating an Irish gang in South Boston.',
        9120,
        'R - Restricted',
        '16,33,53',
        'English',
        'Crime,Drama,Thriller',
        '54'
    );

    INSERT_MOVIE_DVD(
        12,
        12,
        15,
        'Whiplash',
        DATE '2014-10-10',
        'A promising young drummer enrolls at a cut-throat music conservatory where his dreams of greatness are mentored by an instructor who will stop at nothing to realize a students potential.',
        6420,
        'R - Restricted',
        '55,56,57',
        'English',
        'Drama',
        '58'
    );

    INSERT_MOVIE_DIGITAL(
        '1080p (HD)',
        'The Shawshank Redemption',
        DATE '1994-09-23',
        'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.',
        8520,
        'R - Restricted',
        '66,43',
        'English',
        'Drama,Crime',
        '52'
    );
    
    INSERT_MOVIE_DIGITAL(
        '1080p (HD)',
        'The Godfather',
        DATE '1972-03-24',
        'The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.',
        10500,
        'R - Restricted',
        '59,61',
        'English',
        'Drama,Crime',
        '80'
    );
    
    INSERT_MOVIE_DIGITAL(
        '1080p (HD)',
        'The Dark Knight',
        DATE '2008-07-18',
        'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
        9120,
        'PG-13 - Parents Strongly Cautioned',
        '68,60',
        'English',
        'Drama,Action',
        '19'
    );
    
    INSERT_MOVIE_DIGITAL(
        '1080p (HD)',
        'The Godfather: Part II',
        DATE '1974-12-20',
        'The early life and career of Vito Corleone in 1920s New York City is portrayed, while his son, Michael, expands and tightens his grip on the family crime syndicate.',
        12120,
        'R - Restricted',
        '61,67',
        'English',
        'Crime,Drama',
        '80'
    );
    
    INSERT_MOVIE_DIGITAL(
        '1080p (HD)',
        'The Lord of the Rings: The Return of the King',
        DATE '2003-12-17',
        'Gandalf and Aragorn lead the World of Men against Saurons army to draw his gaze from Frodo and Sam as they approach Mount Doom with the One Ring.',
        12000,
        'PG-13 - Parents Strongly Cautioned',
        '62',
        'English',
        'Adventure,Fantasy',
        '81'
    );
    
    INSERT_MOVIE_DIGITAL(
        '1080p (HD)',
        'Pulp Fiction',
        DATE '1994-10-14',
        'The lives of two mob hitmen, a boxer, a gangster and his wife, and a pair of diner bandits intertwine in four tales of violence and redemption.',
        9180,
        'R - Restricted',
        '71,70,63',
        'English',
        'Drama,Crime',
        '82'
    );
    
    INSERT_MOVIE_DIGITAL(
        '1080p (HD)',
        'Schindlers List',
        DATE '1993-12-15',
        'In German-occupied Poland during World War II, industrialist Oskar Schindler gradually becomes concerned for his Jewish workforce after witnessing their persecution by the Nazis.',
        11760,
        'R - Restricted',
        '64',
        'English',
        'Biography,Drama',
        '35'
    );
    
    INSERT_MOVIE_DIGITAL(
        '1080p (HD)',
        'Fight Club',
        DATE '1999-10-15',
        'An insomniac office worker and a devil-may-care soap maker form an underground fight club that evolves into something much, much more.',
        8340,
        'R - Restricted',
        '44,75',
        'English',
        'Drama,Thriller',
        '46'
    );
    
    INSERT_MOVIE_DIGITAL(
        '1080p (HD)',
        'Forrest Gump',
        DATE '1994-07-06',
        'The presidencies of Kennedy and Johnson, the events of Vietnam, Watergate, and other historical events unfold from the perspective of an Alabama man with an IQ of 75, whose only desire is to be reunited with his childhood sweetheart.',
        8520,
        'PG-13 - Parents Strongly Cautioned',
        '32,73',
        'English',
        'Comedy,Drama',
        '84'
    );
    
    INSERT_MOVIE_DIGITAL(
        '1080p (HD)',
        'The Matrix',
        DATE '1999-03-31',
        'A computer hacker learns from mysterious rebels about the true nature of his reality and his role in the war against its controllers.',
        8160,
        'R - Restricted',
        '65,74',
        'English',
        'Action,Sci-Fi',
        '85,86'
    );
END;
/

BEGIN
    INSERT_RENTAL('Inception', DATE '2010-07-16', 1, 32.00, DATE '2024-06-10');
    INSERT_RENTAL('Gladiator', DATE '2000-05-05', 2, 20.00, DATE '2024-06-11');
    INSERT_RENTAL('Interstellar', DATE '2014-11-07', 3, 41.00, DATE '2024-06-12');
    INSERT_RENTAL('Se7en', DATE '1995-09-22', 1, 10.00, DATE '2024-06-13');
    INSERT_RENTAL('Braveheart', DATE '1995-05-24', 4, 32.90, DATE '2024-06-14');
    INSERT_RENTAL('Whiplash', DATE '2014-10-10', 6, 33.00, DATE '2024-06-15');
    INSERT_RENTAL('Jurassic Park', DATE '1993-06-11', 3, 3.00, DATE '2024-06-16');
    INSERT_RENTAL('The Matrix', DATE '1999-03-31', 1, 4.00, DATE '2024-06-17');
    INSERT_RENTAL('The Dark Knight', DATE '2008-07-18', 4, 8.55, DATE '2024-06-18');
    INSERT_RENTAL('Pulp Fiction', DATE '1994-10-14', 2, 7.76, DATE '2024-06-19');
END;
/

