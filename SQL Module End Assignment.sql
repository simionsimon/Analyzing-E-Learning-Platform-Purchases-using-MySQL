-- Create Database
CREATE DATABASE IF NOT EXISTS elearning_db;
USE elearning_db;

-- Table 1: learners
create table learners (
    learner_id int primary key auto_increment,
    full_name varchar(100) not null,
    country varchar(50) not null
);

-- Table 2: courses
create table courses (
    course_id int primary key auto_increment,
    course_name varchar(100) not null,
    category varchar(50) not null,
    unit_price decimal(10, 2) not null
);

-- Table 3: purchases
create table purchases (
    purchase_id int primary key auto_increment,
    learner_id int not null,
    course_id int not null,
    quantity int not null check (quantity > 0),
    purchase_date date not null,
    foreign key (learner_id) references learners(learner_id),
    foreign key (course_id) references courses(course_id)
);

-- Insert Learners
insert into learners (full_name, country) values
('John Smith', 'USA'),
('Priya Sharma', 'India'),
('Maria Garcia', 'Spain'),
('David Kim', 'South Korea'),
('Ahmed Hassan', 'UAE');
select * from learners;


-- Insert Courses
insert into courses (course_name, category, unit_price) values
('Python for Beginners', 'Programming', 49.99),
('Data Science Masterclass', 'Data Science', 89.99),
('Digital Marketing', 'Marketing', 39.99),
('Web Development', 'Programming', 79.99),
('Data Analytics', 'Data Science', 69.99),
('Share Market', 'Data Science', 69.99);
select * from courses;

-- Insert Purchases
insert into purchases (learner_id, course_id, quantity, purchase_date) values
-- John Smith (USA)
(1, 1, 1, '2026-01-15'),
(1, 3, 1, '2026-02-10'),
-- Priya Sharma (India)
(2, 1, 1, '2026-01-20'),
(2, 2, 1, '2026-01-25'),
(2, 4, 1, '2026-02-15'),
-- Maria Garcia (Spain)
(3, 2, 1, '2026-02-01'),
(3, 5, 1, '2026-02-20'),
-- David Kim (South Korea)
(4, 4, 1, '2026-01-10'),
-- Ahmed Hassan (UAE)
(5, 3, 2, '2026-02-28');
select * from purchases;

-- DATA EXPLORATION USING JOINS

-- INNER JOIN:
select
    l.full_name as learner_name,
    l.country,
    c.course_name,
    c.category,
    p.quantity,
    format(c.unit_price, 2) as unit_price,
    format(p.quantity * c.unit_price, 2) as total_revenue,
    date_format(p.purchase_date, '%Y-%m-%d') AS purchase_date
from purchases p
inner join learners l on p.learner_id = l.learner_id
inner join courses c on p.course_id = c.course_id
order by p.purchase_date desc;

-- LEFT JOIN:
select 
    l.full_name as learner_name,
    l.country,
    coalesce(c.course_name, 'No Purchase') as course_name,
    coalesce(p.quantity, 0) as quantity,
    coalesce(format(p.quantity * c.unit_price, 2), '0.00') as total_spent
from learners l
left join purchases p on l.learner_id = p.learner_id
left join courses c on p.course_id = c.course_id
order by total_spent;

-- RIGHT JOIN:
select 
    c.course_name,
    c.category,
    coalesce(sum(p.quantity), 0) as total_quantity_sold,
    coalesce(format(sum(p.quantity * c.unit_price), 2), '0.00') as total_revenue
from purchases p
right join courses c on p.course_id = c.course_id
group by c.course_id, c.course_name, c.category
order by total_quantity_sold desc;


-- ANALYTICAL QUERIES (Q1 - Q5)

-- Q1: Display each learner's total spending along with their country
select 
    l.full_name as learner_name,
    l.country,
    format(coalesce(sum(p.quantity * c.unit_price), 0), 2) as total_spending
from learners l
left join purchases p on l.learner_id = p.learner_id
left join courses c on p.course_id = c.course_id
group by l.learner_id, l.full_name, l.country
order by coalesce(sum(p.quantity * c.unit_price), 0) desc;

-- Q2: Find the top 3 most purchased courses based on total quantity sold
select 
    c.course_name,
    c.category,
    sum(p.quantity) as total_quantity_sold,
    format(sum(p.quantity * c.unit_price), 2) as total_revenue
from courses c
inner join purchases p on c.course_id = p.course_id
group by c.course_id, c.course_name, c.category
order by total_quantity_sold desc
limit 3;

-- Q3: Show each course category's total revenue and number of unique learners
SELECT 
    c.category,
    format(sum(p.quantity * c.unit_price), 2) as total_revenue,
    count(distinct p.learner_id) as unique_learners
from courses c
inner join purchases p on c.course_id = p.course_id
group by  c.category
order by sum(p.quantity * c.unit_price) desc;

-- Q4: List all learners who have purchased courses from more than one category
select 
    l.full_name as learner_name,
    l.country,
    count(distinct c.category) as categories_purchased,
    c.category
from learners l
inner join purchases p on l.learner_id = p.learner_id
inner join courses c on p.course_id = c.course_id
group by l.learner_id, l.full_name, l.country
having count(distinct c.category) > 1
order by categories_purchased desc;

-- Q5: Identify courses that have not been purchased at all
select 
    c.course_id,
    c.course_name,
    c.category,
    FORMAT(c.unit_price, 2) AS unit_price
FROM courses c
LEFT JOIN purchases p ON c.course_id = p.course_id
WHERE p.purchase_id IS NULL
ORDER BY c.course_name;