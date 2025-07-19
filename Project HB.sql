
-- Personal Finance Tracker SQL Script (Corrected View)

-- Drop tables if they exist
DROP TABLE IF EXISTS Income;
DROP TABLE IF EXISTS Expenses;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Users;
DROP VIEW IF EXISTS UserMonthlyBalance;

-- Users table
CREATE TABLE Users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL
);

-- Categories table
CREATE TABLE Categories (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT CHECK(type IN ('Income', 'Expense')) NOT NULL
);

-- Income table
CREATE TABLE Income (
    income_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    category_id INTEGER,
    amount DECIMAL(10,2),
    date DATE,
    description TEXT,
    FOREIGN KEY(user_id) REFERENCES Users(user_id),
    FOREIGN KEY(category_id) REFERENCES Categories(category_id)
);

-- Expenses table
CREATE TABLE Expenses (
    expense_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    category_id INTEGER,
    amount DECIMAL(10,2),
    date DATE,
    description TEXT,
    FOREIGN KEY(user_id) REFERENCES Users(user_id),
    FOREIGN KEY(category_id) REFERENCES Categories(category_id)
);

-- Dummy data: Users
INSERT INTO Users (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com');

-- Dummy data: Categories
INSERT INTO Categories (name, type) VALUES
('Salary', 'Income'),
('Freelancing', 'Income'),
('Groceries', 'Expense'),
('Rent', 'Expense'),
('Entertainment', 'Expense'),
('Utilities', 'Expense');

-- Dummy data: Income
INSERT INTO Income (user_id, category_id, amount, date, description) VALUES
(1, 1, 50000, '2025-07-01', 'Monthly Salary'),
(1, 2, 10000, '2025-07-10', 'Freelance Project');

-- Dummy data: Expenses
INSERT INTO Expenses (user_id, category_id, amount, date, description) VALUES
(1, 3, 4000, '2025-07-02', 'Grocery Shopping'),
(1, 4, 15000, '2025-07-03', 'Monthly Rent'),
(1, 5, 3000, '2025-07-06', 'Movies and Dining'),
(1, 6, 2000, '2025-07-08', 'Electricity Bill');

-- Corrected View: Monthly Balance Summary
CREATE VIEW UserMonthlyBalance AS
WITH MonthlyData AS (
    SELECT user_id, strftime('%Y-%m', date) AS month FROM Income
    UNION
    SELECT user_id, strftime('%Y-%m', date) AS month FROM Expenses
)
SELECT 
    md.user_id,
    md.month,
    COALESCE(SUM(i.amount), 0) AS total_income,
    COALESCE(SUM(e.amount), 0) AS total_expense,
    COALESCE(SUM(i.amount), 0) - COALESCE(SUM(e.amount), 0) AS balance
FROM MonthlyData md
LEFT JOIN Income i 
    ON i.user_id = md.user_id AND strftime('%Y-%m', i.date) = md.month
LEFT JOIN Expenses e 
    ON e.user_id = md.user_id AND strftime('%Y-%m', e.date) = md.month
GROUP BY md.user_id, md.month;
