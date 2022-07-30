
/* For debugging/rego - DROP ALL TABLES */

-- Remove foreign keys from all tables

--EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT all'

-- --remove from information_schema
--DECLARE @sql1 NVARCHAR(max)=''SELECT @sql1 += ' Drop table ' + QUOTENAME(TABLE_SCHEMA) + '.'+ QUOTENAME(TABLE_NAME) + '; '

--FROM   INFORMATION_SCHEMA.TABLES

--WHERE  TABLE_TYPE = 'BASE TABLE'

--Exec Sp_executesql @sql1


--DECLARE @sql2 NVARCHAR(max)=''SELECT @sql2 += ' Drop table ' + QUOTENAME(s.NAME) + '.' + QUOTENAME(t.NAME) + '; '

--FROM   sys.tables t

--       JOIN sys.schemas s

--         ON t.[schema_id] = s.[schema_id]

--WHERE  t.type = 'U'

--Exec sp_executesql @sql2

/* END: Drop all tables */



CREATE TABLE Companies (
    company_id    INTEGER identity(1,1) NOT NULL,
	company_name VARCHAR(150) NOT NULL,
    mailing_address    varchar(100) NOT NULL,
    contact_email    varchar(100) NOT NULL,
    PRIMARY KEY(company_id),
);
/*
Mailing address and contact email is varchar 100 is because the address is not expected to be too long
*/


CREATE TABLE Users (
    user_id varchar(15) NOT NULL,
    fullname varchar(255) NOT NULL,
    sex varchar(1) NOT NULL,                         
    birthday DATE NOT NULL,                         
    hometown varchar(100) NOT NULL,
    phone_number varchar(50) NOT NULL,
    email varchar(100) NOT NULL,
    company_id INTEGER identity(1,1),
    PRIMARY KEY(user_id),
    FOREIGN KEY(company_id) REFERENCES Companies(company_id)
);

SELECT *
FROM Users

/*
Explanation for choice of data type: 
User_id is varchar of 15 character because of possible foreigner nric
name is varchar of 255 character because of longest malaysia name is 63, 255 is safe.
Phone number is varchar of 50 phone number can be a very big number so cannot use integer and need to put country code
Sex is varchar(1) because the available options are : �F�, �M� or �O� which stands for female, male or others.
*/

CREATE TABLE Relationships(
	rs_id INT identity(1,1),
	relationship_str VARCHAR(20),
	PRIMARY KEY(rs_id)
);

/* Relationships are a list of constant strings like "father", "mother", "sister", "husband", "wife", etc. */

CREATE TABLE FamilyMembers(
	user_id varchar(15) NOT NULL,
	family_member_id VARCHAR(15) NOT NULL,
	rs_id INT NOT NULL,
	CONSTRAINT PK_FamilyMembers PRIMARY KEY (user_id, family_member_id),
	FOREIGN KEY(user_id) REFERENCES Users(user_id)
		ON DELETE NO ACTION, 
	FOREIGN KEY(family_member_id) REFERENCES Users(user_id)
		ON DELETE NO ACTION,
	FOREIGN KEY(rs_id) REFERENCES Relationships(rs_id)
);

/*  
	FamilyMembers is a self-referencing relationship, if we were to choose ON DELETE CASCADE,
	deleting one user_id will result in a cyclic deletion of FamilyMembers since FamilyMembers
	have a one to many relationshi i.e. a user can have many family members.

	A tuple in relationships should never be updated or deleted since it's just named constants, hence,
	nothing is set for ON DELETE and ON UPDATE.
*/

CREATE TABLE Coordinates(
	user_id varchar(15) NOT NULL,
	time_stamp DATETIME NOT NULL, 
	x_coords   DECIMAL(9,6)  NOT NULL, 
	y_coords   DECIMAL(8,6)  NOT NULL,
	CONSTRAINT PK_Coordinates PRIMARY KEY (user_id, time_stamp),
	FOREIGN KEY(user_id) REFERENCES Users(user_id)
		ON DELETE CASCADE,
);

/*
PK_Coordinates is the primary key attribute referencing composite keys (user_id, time_stamp)
https://www.w3schools.com/sql/sql_primarykey.ASP
*/


CREATE TABLE TestResults(
	ts_id tinyint identity(1,1),
	result_string varchar(16)
	PRIMARY KEY(ts_id)
);

/*
	results _string: �positive�, �negative�, �inconclusive�, 'to-be-scheduled', 'test-to-be-taken'
*/


CREATE TABLE Schedules(
	user_id varchar(15) NOT NULL,
	scheduled_time TIME NOT NULL, 
	clinic_location varchar(100) NOT NULL, 
	test_result TINYINT NULL, 
	CONSTRAINT PK_Schedules PRIMARY KEY (user_id, scheduled_time), 
	FOREIGN KEY(user_id) REFERENCES Users(user_id)
		ON DELETE CASCADE,
	FOREIGN KEY(test_result) REFERENCES TestResults(ts_id )
		ON DELETE CASCADE
); 
/*
	clinic_location is varchar of 100 character to account for longer clinic names
	test_result is varchar of 16 character because of longest char 'test-to-be-taken'
*/

CREATE TABLE TemperatureDeclarations(
	user_id varchar(15) NOT NULL,
	time_stamp DATETIME NOT NULL,
	temperature DECIMAL(3,1) NOT NULL,
	CONSTRAINT PK_Temp PRIMARY KEY (user_id, time_stamp),
	FOREIGN KEY(user_id) REFERENCES Users(user_id)
		ON DELETE CASCADE,
);
/*
	Temperature is not expected to rise above 2 digits
*/


CREATE TABLE Admins
(
   admin_id VARCHAR(15) NOT NULL,
   PRIMARY KEY (admin_id ),
);


CREATE TABLE ContactPersons (
    contact_person_id VARCHAR(15) NOT NULL,
    company_id    INTEGER NOT NULL,
    PRIMARY KEY (contact_person_id), 
    FOREIGN KEY(company_id) REFERENCES Companies(company_id)
ON DELETE CASCADE,
    FOREIGN KEY(contact_person_id) REFERENCES Users(user_id)
	ON DELETE CASCADE,
);
/*
	We allow Delete Cascade because if their references changes , contactPerson attribute should be changed as well
*/


CREATE TABLE Locations (
    location_id   INTEGER  identity(1,1) NOT NULL,
    loc_address varchar(100),
    loc_name varchar(100),
    description varchar(255),
    x_coords DECIMAL(9,6) NOT NULL,
    y_coords DECIMAL(8,6) NOT NULL,
    PRIMARY KEY(location_id)
);
/*
	Address having 100 varchar is a safe allocation
	Longitude and latitude need a high precision, so 6 digit precision is needed. They are not null since it is needed to define a location
*/

/*
	Address having 100 varchar is a safe allocation
	Longitude and latitude need a high precision, so 6 digit precision is needed. They are not null since it is needed to define a location
*/

CREATE TABLE CompanyLocations(
    location_id  INT NOT NULL,
    company_id  INT NOT NULL,
    CONSTRAINT PK_CompanyLocations PRIMARY KEY (location_id, company_id),
    FOREIGN KEY(company_id) REFERENCES Companies(company_id)
		ON DELETE CASCADE,
    FOREIGN KEY(location_id) REFERENCES Locations(location_id)
   		ON DELETE CASCADE
);

/*
	We allow Delete Cascade because if their references changes , companylocation attribute should be changed as well
*/


CREATE TABLE Categories
(
   category_name varchar(50) NOT NULL,
   PRIMARY KEY (category_name),
);


CREATE TABLE LocationCategories
(
   location_id int NOT NULL,
   category_name varchar(50) NOT NULL,
   CONSTRAINT PK_LocationCategories PRIMARY KEY (location_id, category_name), 
   FOREIGN KEY (location_id) REFERENCES Locations(location_id)
   	ON DELETE CASCADE,
   FOREIGN KEY (category_name) REFERENCES Categories(category_name)
   	ON DELETE CASCADE,
);

/*
	We allow Delete Cascade because if their references changes , LocationCategories attribute should be changed as well
*/


CREATE TABLE CategoriesSubcategories
(
	category_name varchar(50) NOT NULL,
	subcategory_name varchar(50) NOT NULL,
	PRIMARY KEY (category_name, subcategory_name),
	FOREIGN KEY (category_name) REFERENCES Categories(category_name)
   		ON UPDATE NO ACTION
   		ON DELETE NO ACTION,
	FOREIGN KEY (subcategory_name ) REFERENCES Categories(category_name)
   		ON UPDATE NO ACTION
   		ON DELETE NO ACTION
);

/*
	We allow Update and Delete NO ACTION to prevent cyclic updates and deletes
	since both category and subcategory refers to same category_name in Categories.
*/

CREATE TABLE CheckInOuts(
	user_id VARCHAR(15) NOT NULL,
	check_in_time DATETIME NOT NULL,
	location_id INT NOT NULL,
	check_out_time DATETIME,
	CONSTRAINT PK_CheckInOut PRIMARY KEY(user_id, check_in_time),
	FOREIGN KEY (user_id) REFERENCES Users(user_id)
		ON DELETE CASCADE,
	FOREIGN KEY (location_id) REFERENCES Locations(location_Id)
		ON DELETE CASCADE,
);
/*
	On Delete is set to Cascade because if the user_id is deleted from the database,
	there's no point in keeping his/her CheckInOuts records. If a location is deleted from the database,
	there's no pint in keeping the CheckInOuts in the database.
*/


CREATE TABLE Ratings(
	user_id VARCHAR(15),
	check_in_time DATETIME NOT NULL,
	location_id INT NOT NULL,
	rate TINYINT NOT NULL,
	review VARCHAR(500),
	CONSTRAINT PK_Ratings PRIMARY KEY(user_id, check_in_time),
	FOREIGN KEY (user_id) REFERENCES Users(user_id)
		ON DELETE CASCADE,
	FOREIGN KEY (location_id) REFERENCES Locations(location_id)
		ON DELETE CASCADE,
);
/*
	TINYINT (which takes only 1 byte) for rate is big enough for rating of 1 star to 5 stars
	Review varchar 500 as we are setting a maximum of 500 characters per review.
	We allow Delete Cascade because if their references changes , Ratings attribute should be changed as well
*/

CREATE TABLE Messages (
	msg_id INT NOT NULL IDENTITY(1,1),
	msg_time DATETIME NOT NULL,
	msg_text VARCHAR(500) NOT NULL, 
	location_id INT NOT NULL,
	user_id VARCHAR(15) NOT NULL,
	PRIMARY KEY (msg_id),
	FOREIGN KEY (location_id) REFERENCES Locations(location_id)
		ON DELETE CASCADE,
	FOREIGN KEY (user_id) REFERENCES Users(user_id)
		ON DELETE NO ACTION
);
/*
	msg_text has 500 char because we are setting a maximum of 500 characters per message.
	We allow Delete Cascade because if the user_id is deleted from the database, there's no point 
	in keeping the user's messages in the database.
*/

CREATE TABLE AdminMessages(
	admin_id VARCHAR(15) NOT NULL ,
	msg_id INT NOT NULL,
	CONSTRAINT PK_AdminMessages PRIMARY KEY(admin_id , msg_id),
	FOREIGN KEY (admin_id ) REFERENCES Admins(admin_id)
		ON DELETE CASCADE,
	FOREIGN KEY (msg_id ) REFERENCES Messages(msg_id )
		ON DELETE CASCADE
);


CREATE TABLE ContactPersonsMessages(
	contact_person_id VARCHAR(15) NOT NULL ,
	msg_id INT NOT NULL,
	CONSTRAINT PK_ContactPersonsMessages PRIMARY KEY(contact_person_id  , msg_id),
	FOREIGN KEY (contact_person_id ) REFERENCES ContactPersons(contact_person_id)
		ON DELETE NO ACTION,
	FOREIGN KEY (msg_id) REFERENCES Messages(msg_id)
		ON DELETE NO ACTION
);

CREATE TABLE Comments (
	user_id VARCHAR(15) NOT NULL,
	msg_id INT NOT NULL,
	time_stamp DATETIME NOT NULL,
msg_text VARCHAR(500) NOT NULL,
	CONSTRAINT PK_Comments PRIMARY KEY(user_id, msg_id),
	FOREIGN KEY (user_id) REFERENCES Users(user_id)
		ON DELETE NO ACTION,
	FOREIGN KEY (msg_id) REFERENCES Messages(msg_id)
		ON DELETE NO ACTION
)

/*
	msg_txt is 500 characters as we are only allowing comments to be at maximum, 500 characters long.
	We allow Delete Cascade because if their references changes , Comments attribute should be changed as well
*/
