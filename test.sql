-- Create the database
CREATE DATABASE EmployeeDB;
USE EmployeeDB;

-- Create tables
CREATE TABLE Departments (
    DepartmentID INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentName VARCHAR(50) NOT NULL
);

CREATE TABLE Employees (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    HireDate DATE NOT NULL,
    Salary DECIMAL(10, 2) NOT NULL,
    DepartmentID INT,
    LocationID INT,
    PositionID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),
    FOREIGN KEY (PositionID) REFERENCES Positions(PositionID)
);

CREATE TABLE Projects (
    ProjectID INT AUTO_INCREMENT PRIMARY KEY,
    ProjectName VARCHAR(100) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE,
    Budget DECIMAL(15, 2)
);

CREATE TABLE EmployeeProjects (
    EmployeeID INT,
    ProjectID INT,
    PRIMARY KEY (EmployeeID, ProjectID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID)
);

CREATE TABLE Locations (
    LocationID INT AUTO_INCREMENT PRIMARY KEY,
    LocationName VARCHAR(100) NOT NULL
);

CREATE TABLE Positions (
    PositionID INT AUTO_INCREMENT PRIMARY KEY,
    PositionTitle VARCHAR(100) NOT NULL
);

CREATE TABLE Training (
    TrainingID INT AUTO_INCREMENT PRIMARY KEY,
    TrainingName VARCHAR(100) NOT NULL,
    TrainingDate DATE NOT NULL
);

CREATE TABLE Benefits (
    BenefitID INT AUTO_INCREMENT PRIMARY KEY,
    BenefitName VARCHAR(100) NOT NULL
);

CREATE TABLE PerformanceReviews (
    ReviewID INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeID INT,
    ReviewDate DATE NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Insert sample data into tables
INSERT INTO Departments (DepartmentName) VALUES ('HR'), ('Finance'), ('Engineering'), ('Sales'), ('Marketing');

INSERT INTO Locations (LocationName) VALUES ('New York'), ('San Francisco'), ('Austin'), ('Seattle'), ('Chicago');

INSERT INTO Positions (PositionTitle) VALUES ('Software Engineer'), ('Product Manager'), ('Data Analyst'), ('HR Specialist'), ('Sales Executive');

INSERT INTO Projects (ProjectName, StartDate, EndDate, Budget) VALUES 
('Project Alpha', '2024-01-01', '2024-12-31', 500000.00),
('Project Beta', '2024-06-01', '2024-11-30', 300000.00),
('Project Gamma', '2024-03-01', '2024-09-30', 250000.00),
('Project Delta', '2024-04-01', '2024-10-31', 400000.00);

INSERT INTO Training (TrainingName, TrainingDate) VALUES 
('Leadership Training', '2024-03-01'),
('Technical Skills Workshop', '2024-05-15'),
('Project Management Certification', '2024-07-20');

INSERT INTO Benefits (BenefitName) VALUES 
('Health Insurance'),
('Retirement Plan'),
('Paid Time Off'),
('Gym Membership'),
('Flexible Hours');

INSERT INTO PerformanceReviews (EmployeeID, ReviewDate, Rating) VALUES 
(1, '2024-01-15', 4),
(2, '2024-02-20', 5),
(3, '2024-03-30', 3);

-- Insert sample employees
INSERT INTO Employees (FirstName, LastName, HireDate, Salary, DepartmentID, LocationID, PositionID) VALUES 
('Alice', 'Smith', '2022-03-15', 60000.00, 1, 1, 1),
('Bob', 'Johnson', '2021-07-23', 70000.00, 2, 2, 2),
('Charlie', 'Williams', '2020-11-30', 80000.00, 3, 3, 3),
('David', 'Brown', '2019-06-11', 65000.00, 4, 4, 4),
('Eve', 'Jones', '2022-01-18', 72000.00, 5, 5, 5),
-- More employees here
('Zane', 'Hall', '2019-12-22', 72000.00, 1, 1, 1);

-- Insert sample employee-project assignments
INSERT INTO EmployeeProjects (EmployeeID, ProjectID) VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 1),
-- More assignments here
(50, 2);

-- Demonstrate INNER JOIN
SELECT e.FirstName, e.LastName, d.DepartmentName, l.LocationName, p.PositionTitle
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
INNER JOIN Locations l ON e.LocationID = l.LocationID
INNER JOIN Positions p ON e.PositionID = p.PositionID;

-- Demonstrate LEFT JOIN
SELECT e.FirstName, e.LastName, p.ProjectName
FROM Employees e
LEFT JOIN EmployeeProjects ep ON e.EmployeeID = ep.EmployeeID
LEFT JOIN Projects p ON ep.ProjectID = p.ProjectID;

-- Demonstrate RIGHT JOIN
SELECT p.ProjectName, e.FirstName, e.LastName
FROM Projects p
RIGHT JOIN EmployeeProjects ep ON p.ProjectID = ep.ProjectID
RIGHT JOIN Employees e ON ep.EmployeeID = e.EmployeeID;

-- Demonstrate FULL JOIN (using UNION for compatibility)
(
    SELECT e.FirstName, p.ProjectName
    FROM Employees e
    LEFT JOIN EmployeeProjects ep ON e.EmployeeID = ep.EmployeeID
    LEFT JOIN Projects p ON ep.ProjectID = p.ProjectID
)
UNION
(
    SELECT e.FirstName, p.ProjectName
    FROM Projects p
    RIGHT JOIN EmployeeProjects ep ON p.ProjectID = ep.ProjectID
    RIGHT JOIN Employees e ON ep.EmployeeID = e.EmployeeID
);

-- Demonstrate CROSS JOIN
SELECT e.FirstName, p.ProjectName
FROM Employees e
CROSS JOIN Projects p;
