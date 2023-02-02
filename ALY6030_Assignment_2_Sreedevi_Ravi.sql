#Assignment 2
#Create a database for movies
CREATE SCHEMA IF NOT EXISTS movieinfo;
#View all schemas
SHOW SCHEMAS;
#Use movieinfo as the database in which all the tables will be stored
USE movieinfo;

#Create a table structure to store the data from csv file movies
DROP TABLE IF EXISTS movies;
CREATE TABLE movies
 (Year INT, 
 Length INT, 
 Title VARCHAR(255), 
 Subject VARCHAR(255), 
 Actor VARCHAR(255), 
 Actress VARCHAR(255), 
 Director VARCHAR(255), 
 Popularity INT, 
 Awards VARCHAR(255));
 
#Do a select to check table structure
SELECT * FROM movies;

#Stop here
#Load data from movies.csv into the table movies by using import wizard in Workbench

#Do a count to see if the values have been loaded
SELECT COUNT(*) FROM movies;

#Check the values
SELECT * FROM movies;

#First normal Form 1 NF
#Add a primary key to the table movies
#Primary key is an auto-increment field
ALTER TABLE movies
ADD COLUMN MovieID INT NOT NULL PRIMARY KEY AUTO_INCREMENT;   

#The columns Actor,Actress and Director can be broken down 
#into Last name and First name
#####Add columns to store first and last names of Actor, Actress and Director
ALTER TABLE movies
ADD ActorFirstName varchar(255);

ALTER TABLE movies
ADD ActorLastName varchar(255);

ALTER TABLE movies
ADD ActressFirstName varchar(255);

ALTER TABLE movies
ADD ActressLastName varchar(255);

ALTER TABLE movies
ADD DirectorFirstName varchar(255);

ALTER TABLE movies
ADD DirectorLastName varchar(255);
########################
#Update the column with first and last name for Actor with SUBSTRING_INDEX

UPDATE movies
SET
  ActorLastName = SUBSTRING_INDEX(Actor, ',', 1),
  ActorFirstName = SUBSTRING_INDEX(Actor, ',', -1)
WHERE MovieID <> 0 ;

#Update the column with first and last name for Actress with SUBSTRING_INDEX

UPDATE movies
SET
  ActressLastName = SUBSTRING_INDEX(Actress, ',', 1),
  ActressFirstName = SUBSTRING_INDEX(Actress, ',', -1)
WHERE MovieID <> 0 ;

#Update director names
#Update the column with first and last name for Director with SUBSTRING_INDEX

UPDATE movies
SET
  DirectorLastName = SUBSTRING_INDEX(Director, ',', 1),
  DirectorFirstName = SUBSTRING_INDEX(Director, ',', -1)
WHERE MovieID <> 0 ;
###
#Check if the Actor Last name and actor first name is correctly stored.
SELECT Actor,ActorLastName,ActorFirstName from movies;

#Check if the Actress Last name and actor first name, 
#Director first and last names are correctly stored.

SELECT Actress,ActressLastName,ActressFirstName,Director,DirectorLastName,DirectorFirstName from movies;
##Drop the columns Actor,Actress and Director
ALTER TABLE movies
DROP COLUMN Actor,
DROP COLUMN Actress,
DROP COLUMN Director;
###
#Doing a select to see the new structure for movies.
SELECT * FROM movies;
select count(*) from movies;
#Are there any repeating titles?
select count(distinct(Title)) from movies;

SELECT Title,COUNT(*) AS Occurrence FROM
 movies GROUP BY Title HAVING COUNT(*)>1;   
 
 #Are there repeating title in the same year?
 SELECT Year,Title,COUNT(*) AS Occurrence FROM
 movies GROUP BY Year,Title HAVING COUNT(*)>1;   

#Are there multiple movies with same popularity?
 SELECT Popularity,COUNT(*) AS Occurrence FROM
 movies GROUP BY Popularity HAVING COUNT(*)>1;   
 
Select * from movies;

# Second normal Form
##### Non-prime attribute subject depends on MovieID but not movie name
# Create a table for genre
DROP TABLE IF EXISTS Genre;
CREATE TABLE Genre (
	GenreID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    GenreName VARCHAR(255) NOT NULL
);

#Verify table Genre
SELECT * FROM Genre;

# Insert subject information into Genre table from movies table
# Using DISTINCT to eliminate duplicate subject name
# Only inserting Name, letting ID to auto increment
TRUNCATE table Genre;
INSERT INTO Genre
(GenreName)
SELECT DISTINCT Subject
FROM movies where Subject IS NOT NULL;
###
SELECT * FROM Genre;
##
#Create a foreign key in movies to link Genre
#This can allow nulls
ALTER TABLE movies 
ADD COLUMN GenreID INT NULL;
#Verify the column
SELECT * from movies;

#Update GenreID values in movies with the ID values in Genre table
# Match records by subject
UPDATE movies m, Genre g
SET m.GenreID = g.GenreID
WHERE m.Subject = g.GenreName
AND m.MovieID <> 0;
#Check the updates
SELECT Subject,GenreID from movies;
#Remove redundant columns from movies
ALTER TABLE movies
DROP COLUMN Subject;
#Check if the column is dropped
SELECT * FROM movies;

# Create 1:M relations between movies and Genre
# by specifying to RDBMS that GenreID in the movies table
# Is a FK which points to field GenreID in the Genre table
ALTER TABLE movies
ADD FOREIGN KEY (GenreID) REFERENCES Genre(GenreID);

## Do a join select to check the values
SELECT m.Title,m.Year, g.GenreName from movies m 
LEFT join Genre g 
ON m.GenreID = g.GenreID;
###
##### Non-prime attribute actor last name and actor first name depends on MovieID but not movie title
# Create a table for actor
DROP TABLE IF EXISTS Actor;

CREATE TABLE Actor(
    ActorID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    ActorFirstName VARCHAR(255) NOT NULL,
    ActorLastName VARCHAR(255) NOT NULL
);

# Insert actor information into Actor table from movies table
# Using DISTINCT to eliminate duplicate subject name
# Only inserting Name, letting ID to auto increment
TRUNCATE table Actor;
INSERT INTO Actor
(ActorFirstName,ActorLastName)
SELECT DISTINCT ActorFirstName,ActorLastName
FROM movies where ActorFirstName IS NOT NULL
AND ActorLastName is NOT NULL;

#Verify table Actor
SELECT * FROM Actor;

##
#Create a foreign key in movies to link Actor
#This can allow nulls
ALTER TABLE movies 
ADD COLUMN ActorID INT NULL;
#Verify the column
SELECT * from movies;

#Update ActorID values in movies with the ID values in Actor table
# Match records by actor first and last name
#Add a condition MovieID <> 0 to prevent error on safe update
UPDATE movies m, Actor g
SET m.ActorID = g.ActorID
WHERE m.ActorFirstName = g.ActorFirstName
AND m.ActorLastName = g.ActorLastName
AND m.MovieID <> 0;

#Check the updates
SELECT ActorFirstName,ActorLastName,ActorID from movies;

#Remove redundant columns from movies
ALTER TABLE movies
DROP COLUMN ActorFirstName,
DROP COLUMN ActorLastName;
#Check if the column is dropped
SELECT * FROM movies;

# Create 1:M relations between movies and Actor
# by specifying to RDBMS that ActorID in the movies table
# Is a FK which points to field ActorID in the Actor table
ALTER TABLE movies
ADD FOREIGN KEY (ActorID) REFERENCES Actor(ActorID);

##Do a select with join to check values from movies and Actor
## Do a join select to check the values
SELECT m.Title,m.Year, g.ActorFirstName,g.ActorLastName from movies m 
LEFT join Actor g
ON m.ActorID = g.ActorID;

##### Non-prime attribute Actress last name and Actress first name depends on MovieID but not movie title
# Create a table for Actress
DROP TABLE IF EXISTS Actress;
CREATE TABLE Actress(
    ActressID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    ActressFirstName VARCHAR(255) NOT NULL,
    ActressLastName VARCHAR(255) NOT NULL
);

#Verify table Actress
SELECT * FROM Actress;

# Insert Actress information into Actress table from movies table
# Using DISTINCT to eliminate duplicate subject name
# Only inserting Name, letting ID to auto increment
TRUNCATE table Actress;
INSERT INTO Actress
(ActressFirstName,ActressLastName)
SELECT DISTINCT ActressFirstName,ActressLastName
FROM movies where ActressFirstName IS NOT NULL
AND ActressLastName is NOT NULL;
###
SELECT * FROM Actress;
##
#Create a foreign key in movies to link Actress
#This can allow nulls
ALTER TABLE movies 
ADD COLUMN ActressID INT NULL;
#Verify the column
SELECT * from movies;
#Update ActressID values in movies with the ID values in Actress table
# Match records by Actress first and last name
UPDATE movies m, Actress g
SET m.ActressID = g.ActressID
WHERE m.ActressFirstName = g.ActressFirstName
AND m.ActressLastName = g.ActressLastName
AND m.MovieID <> 0;

#Check the updates
SELECT ActressID,ActressFirstName,ActressLastName from movies;

#Remove redundant columns from movies
ALTER TABLE movies
DROP COLUMN ActressFirstName, 
DROP COLUMN ActressLastName;
#Check if the column is dropped
SELECT * FROM movies;
# Create 1:M relations between movies and Actress
# by specifying to RDBMS that ActressID in the movies table
# Is a FK which points to field ActressID in the Actress table
ALTER TABLE movies
ADD FOREIGN KEY (ActressID) REFERENCES Actress(ActressID);

#Do a join to check if the referencing is correct
SELECT m.Title,m.Year, g.ActressFirstName,g.ActressLastName from movies m 
LEFT join Actress g
ON m.ActressID = g.ActressID;

#Director details can be stored in a separate table
##### Non-prime attribute Director last name and Director first name depends on MovieID but not movie title
# Create a table for Director
DROP TABLE IF EXISTS Director;

CREATE TABLE Director(
    DirectorID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    DirectorFirstName VARCHAR(255) NOT NULL,
    DirectorLastName VARCHAR(255) NOT NULL
);
#Verify table Director
SELECT * FROM Director;
# Insert Director information into Director table from movies table
# Using DISTINCT to eliminate duplicate subject name
# Only inserting Name, letting ID to auto increment
TRUNCATE table Director;
INSERT INTO Director
(DirectorFirstName,DirectorLastName)
SELECT DISTINCT DirectorFirstName,DirectorLastName
FROM movies where DirectorFirstName IS NOT NULL
AND DirectorLastName is NOT NULL;
###
SELECT * FROM Director;
##
#Create a foreign key in movies to link Director
#This can allow nulls
ALTER TABLE movies 
ADD COLUMN DirectorID INT NULL;
#Verify the column
SELECT * from movies;

#Update DirectorID values in movies with the ID values in Director table
# Match records by Director first and last name
UPDATE movies m, Director g
SET m.DirectorID = g.DirectorID
WHERE m.DirectorFirstName = g.DirectorFirstName
AND m.DirectorLastName = g.DirectorLastName
AND m.MovieID <> 0;

#Check the updates
SELECT DirectorFirstName,DirectorLastName,DirectorID from movies;

#Remove redundant columns from movies
ALTER TABLE movies
DROP COLUMN DirectorFirstName,
DROP COLUMN DirectorLastName;
#Check if the column is dropped
SELECT * FROM movies;

# Create 1:M relations between movies and Director
# by specifying to RDBMS that DirectorID in the movies table
# Is a FK which points to field DirectorID in the Director table
ALTER TABLE movies
ADD FOREIGN KEY (DirectorID) REFERENCES Director(DirectorID);
##Do a select joining both tables
SELECT m.Title,m.Year, g.DirectorFirstName,g.DirectorLastName from movies m 
LEFT join Director g
ON m.DirectorID = g.DirectorID;

###Third normal Form 3 NF
#Performing a select to find transitive dependency
SELECT Title,Awards,Count(*)  as Occurance
FROM movies
GROUP BY Title,Awards
HAVING Count(*) > 1;
##
# There is no dependence on popularity and title
	SELECT year,Title,Popularity,Count(*)  as Occurance
	FROM movies
	GROUP BY year,Title,Popularity
	HAVING Count(*) > 1;

######SQL queries
##How many movies released between 1950 and 1960 that were in the comedy genre and was directed by Boisrond, Michel
SELECT m.Title FROM
movies m
INNER JOIN Genre g
ON m.GenreID = g.GenreID
INNER JOIN director d
ON d.DirectorID = m.DirectorID
WHERE g.GenreName = 'Comedy'
AND d.DirectorLastName LIKE '%Boisrond%'
AND d.DirectorFirstName LIKE '%Michel%'
AND m.Year BETWEEN 1950 and 1960;
###
#2)	Select all movies in which Sean Connery acted, group by year,genre and title having popularity < 50.
SELECT m.Year,g.GenreName AS Subject,m.Title,m.Popularity  FROM
movies m
INNER JOIN Genre g
ON m.GenreID = g.GenreID
LEFT JOIN Actor d
ON d.ActorID = m.ActorID
WHERE d.ActorLastName LIKE '%Connery%'
AND d.ActorFirstName LIKE '%Sean%'
GROUP BY m.Year,g.GenreName,m.Title,m.Popularity
HAVING m.Popularity < 50 
ORDER BY m.Year,g.GenreName,m.Title,m.Popularity;

###3) Who were the directors whose movie won awards? Show the records in ascending year of release and grouped by genre.
SELECT m.Year,g.GenreName AS Subject,m.Title,
	   d.DirectorFirstName as 'Director First Name',
       d.DirectorLastName as 'Director Last Name' FROM
movies m
INNER JOIN Genre g
ON m.GenreID = g.GenreID
INNER JOIN Director d
ON d.DirectorID = m.DirectorID
WHERE m.Awards like '%Yes%'
GROUP BY m.Year,g.GenreName,m.Title,d.DirectorFirstName,d.DirectorLastName
ORDER BY m.Year,g.GenreName,m.Title,d.DirectorFirstName,d.DirectorLastName;
####
