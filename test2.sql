-- Create the database
CREATE DATABASE IF NOT EXISTS AdvancedSQLDemoDB;
USE AdvancedSQLDemoDB;

-- Drop tables if they exist to start fresh
DROP TABLE IF EXISTS DepartmentEmployees;
DROP TABLE IF EXISTS PerformanceReviews;
DROP TABLE IF EXISTS Benefits;
DROP TABLE IF EXISTS Training;
DROP TABLE IF EXISTS Positions;
DROP TABLE IF EXISTS Locations;
DROP TABLE IF EXISTS EmployeeProjects;
DROP TABLE IF EXISTS Projects;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Departments;

-- Create tables
CREATE TABLE Departments (
    DepartmentID INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentName VARCHAR(50) NOT NULL
);

CREATE TABLE Employees (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Salary DECIMAL(10, 2) NOT NULL,
    HireDate DATE NOT NULL
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

CREATE TABLE DepartmentEmployees (
    DepartmentID INT,
    EmployeeID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Insert sample data
INSERT INTO Departments (DepartmentName) VALUES 
('HR'), ('Finance'), ('Engineering');

INSERT INTO Employees (FirstName, LastName, Salary, HireDate) VALUES 
('Alice', 'Smith', 60000.00, '2022-03-15'),
('Bob', 'Johnson', 70000.00, '2021-07-23'),
('Charlie', 'Williams', 80000.00, '2020-11-30'),
('David', 'Brown', 65000.00, '2019-06-11'),
('Eve', 'Jones', 72000.00, '2022-01-18');

INSERT INTO Projects (ProjectName, StartDate, EndDate, Budget) VALUES 
('Project Alpha', '2024-01-01', '2024-12-31', 500000.00),
('Project Beta', '2024-06-01', '2024-11-30', 300000.00),
('Project Gamma', '2024-03-01', '2024-09-30', 250000.00),
('Project Delta', '2024-04-01', '2024-10-31', 400000.00');

INSERT INTO Locations (LocationName) VALUES 
('New York'), ('San Francisco'), ('Austin'), ('Seattle'), ('Chicago');

INSERT INTO Positions (PositionTitle) VALUES 
('Software Engineer'), ('Product Manager'), ('Data Analyst'), ('HR Specialist'), ('Sales Executive');

INSERT INTO PerformanceReviews (EmployeeID, ReviewDate, Rating) VALUES 
(1, '2024-01-15', 4),
(2, '2024-02-20', 5),
(3, '2024-03-30', 3);

INSERT INTO DepartmentEmployees (DepartmentID, EmployeeID) VALUES 
(1, 1),
(1, 2),
(2, 3),
(2, 4),
(3, 5);

-- 1. Subqueries
-- Subquery to find employees with above average salary
SELECT 
    FirstName, 
    LastName, 
    Salary
FROM Employees
WHERE Salary > (SELECT AVG(Salary) FROM Employees);

-- 2. Common Table Expressions (CTEs)
-- CTE to calculate total salary by department and use it in the main query
WITH DepartmentSalaries AS (
    SELECT 
        d.DepartmentName,
        SUM(e.Salary) AS TotalSalary
    FROM DepartmentEmployees de
    JOIN Employees e ON de.EmployeeID = e.EmployeeID
    JOIN Departments d ON de.DepartmentID = d.DepartmentID
    GROUP BY d.DepartmentName
)
SELECT 
    DepartmentName,
    TotalSalary
FROM DepartmentSalaries;

-- 3. Window Functions
-- Window function to rank employees by salary within each department
WITH EmployeeRanks AS (
    SELECT 
        e.FirstName,
        e.LastName,
        e.Salary,
        d.DepartmentName,
        RANK() OVER (PARTITION BY d.DepartmentName ORDER BY e.Salary DESC) AS SalaryRank
    FROM DepartmentEmployees de
    JOIN Employees e ON de.EmployeeID = e.EmployeeID
    JOIN Departments d ON de.DepartmentID = d.DepartmentID
)
SELECT 
    FirstName,
    LastName,
    Salary,
    DepartmentName,
    SalaryRank
FROM EmployeeRanks;

-- 4. Advanced Joins
-- INNER JOIN to show employees, their departments, and projects they are assigned to
SELECT 
    e.FirstName,
    e.LastName,
    d.DepartmentName,
    p.ProjectName
FROM Employees e
INNER JOIN DepartmentEmployees de ON e.EmployeeID = de.EmployeeID
INNER JOIN Departments d ON de.DepartmentID = d.DepartmentID
LEFT JOIN EmployeeProjects ep ON e.EmployeeID = ep.EmployeeID
LEFT JOIN Projects p ON ep.ProjectID = p.ProjectID;

-- 5. UNION and INTERSECT
-- UNION to combine results of two different queries
SELECT FirstName, LastName, 'Employee' AS Source
FROM Employees
UNION
SELECT 'N/A', 'N/A', 'Project' AS Source
FROM Projects;

-- INTERSECT to find common records between two queries
-- Note: INTERSECT is supported in databases like PostgreSQL but not in MySQL. This is for demonstration.
SELECT FirstName, LastName
FROM Employees
INTERSECT
SELECT 'Alice', 'Smith';

-- 6. Advanced Aggregation with GROUP BY and HAVING
-- Aggregate salaries and filter departments with average salary above a certain threshold
SELECT 
    d.DepartmentName,
    AVG(e.Salary) AS AverageSalary,
    MAX(e.Salary) AS MaxSalary
FROM DepartmentEmployees de
JOIN Employees e ON de.EmployeeID = e.EmployeeID
JOIN Departments d ON de.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName
HAVING AVG(e.Salary) > 65000;

-- 7. PIVOT (using CASE for SQL databases without native PIVOT support)
-- Pivot table to show salaries by department
SELECT 
    DepartmentName,
    SUM(CASE WHEN Salary BETWEEN 50000 AND 60000 THEN Salary ELSE 0 END) AS '50000-60000',
    SUM(CASE WHEN Salary BETWEEN 60001 AND 70000 THEN Salary ELSE 0 END) AS '60001-70000',
    SUM(CASE WHEN Salary > 70000 THEN Salary ELSE 0 END) AS 'Above 70000'
FROM DepartmentEmployees de
JOIN Employees e ON de.EmployeeID = e.EmployeeID
JOIN Departments d ON de.DepartmentID = d.DepartmentID
GROUP BY DepartmentName;
