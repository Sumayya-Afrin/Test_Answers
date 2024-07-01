use exam_dB
CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks (
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists (artist_id, name, country, birth_year) VALUES
(1, 'Vincent van Gogh', 'Netherlands', 1853),
(2, 'Pablo Picasso', 'Spain', 1881),
(3, 'Leonardo da Vinci', 'Italy', 1452),
(4, 'Claude Monet', 'France', 1840),
(5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks (artwork_id, title, artist_id, genre, price) VALUES
(1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
(2, 'Guernica', 2, 'Cubism', 2000000.00),
(3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
(4, 'Water Lilies', 4, 'Impressionism', 500000.00),
(5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales (sale_id, artwork_id, sale_date, quantity, total_amount) VALUES
(1, 1, '2024-01-15', 1, 1000000.00),
(2, 2, '2024-02-10', 1, 2000000.00),
(3, 3, '2024-03-05', 1, 3000000.00),
(4, 4, '2024-04-20', 2, 1000000.00);

select * from artists
select * from artworks
select * from sales
--### Section 1: 1 mark each

--1. Write a query to display the artist names in uppercase.

select  upper([name]) from artists
--2. Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.
select top(2) artworks.artwork_id ,  title , quantity , price
from artworks
join sales on artworks.artwork_id=sales.artwork_id
order by price
--3 . Write a query to find the total amount of sales for the artwork 'Mona Lisa'.
select total_amount
from sales
where artwork_id=(select artwork_id from artworks where title='Mona Lisa')

-- 4. Write a query to extract the year from the sale date of 'Guernica'.
select datepart(year,sale_date) from sales
where artwork_id=(select artwork_id from artworks where title='Guernica')
--### Section 2: 2 marks each
--5. Write a query to find the artworks that have the highest sale total for each genre.
with CTE_HighSales
as
(
select artworks.artwork_id , title , DENSE_RANK() OVER (partition by genre order by total_amount desc) as HighestSales , genre
from artworks
join sales on artworks.artwork_id=sales.artwork_id
)

select * from CTE_Highsales
where HighestSales=1

--6. Write a query to rank artists by their total sales amount and display the top 3 artists.
select * from artists
select * from artworks
select * from sales
select artists.artist_id , [name] ,artists.total_amount , DENSE_RANK() OVER (order by sum(total_amount) desc) as SalesRank
from artists
join artworks on artists.artwork_id=artworks.artwork_id
join sales on artworks.artwork_id=sales.artwork_id

--7. Write a query to display artists who have artworks in multiple genres.
select artists.artist_id , artists.[name] 
from artists
join artworks on artists.artist_id=artworks.artist_id
group by artists.artist_id,artists.[name] 
having count(genre)>1
--8. Write a query to find the average price of artworks for each artist.
select artists.artist_id , artists.[name] , avg(price) as Avg_price
from artists
join artworks on artists.artist_id=artworks.artist_id
group by artists.artist_id,artists.[name]

--9. Write a query to create a non-clustered index on the `sales` table to improve query performance for queries filtering by `artwork_id`.
create NONCLUSTERED INDEX on sales[artwork_id]

select * from artists
select * from artworks
select * from sales

--10. Write a query to find the artists who have sold more artworks than the average number of artworks sold per artist.
select artists.artist_id , artists.[name] , count(artwork_id) as CountOfArtworks
from artists
join artworks on artists.artist_id=artworks.artist_id
group by artists.artist_id ,artists.[name]

--11. Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.
select artist_id , [name] 
from artists
where artist_id IN ( select artist_id from artworks where genre='Cubism'
                   union
				   select artist_id from artworks where genre='Surrealism')

--12. Write a query to display artists whose birth year is earlier than the average birth year of artists from their country.
select artist_id , [name] 
from artists o
where birth_year < ( select avg(birth_year) 
                     from artists e
					 where e.country=o.country)
select * from artists
select * from artworks
select * from sales

--13. Write a query to find the artworks that have been sold in both January and February 2024.
select artwork_id , title 
from artworks
where artwork_id IN ( select artwork_id from sales where datepart(mm,sale_date)=1 and datepart(year,sale_date)=2024
                      union
					  select artwork_id from sales where datepart(mm,sale_date)=2 and datepart(year,sale_date)=2024)

--14. Write a query to calculate the price of 'Starry Night' plus 10% tax.
 select * ,1.1*price as Tax
 from artworks
 where title='Starry Night'
--15. Write a query to display the artists whose average artwork price is higher than every artwork price in the 'Renaissance' genre.
select * from artists
select * from artworks
select * from sales

select artists.artist_id , [name]
from artists
join artworks on artists.artist_id=artists.artist_id
group by artists.artist_id , [name]
having avg(price)> all (
select price 
from artworks
where genre='Renaissance')

--### Section 3: 3 Marks Questions

--16. Write a query to find artworks that have a higher price than the average price of artworks by the same artist.
select artwork_id , title 
from artworks o
where price > ( select avg(price) from artworks i
                where i.artist_id=o.artist_id)
select * from artists
select * from artworks
select * from sales

--17. Write a query to find the average price of artworks for each artist and only include artists whose average artwork price is higher than the overall average artwork price.
select artists.artist_id , artists.[name] , avg(price)
from artists 
join artworks on artists.artist_id=artworks.artist_id
group by artists.artist_id, artists.[name] 
having avg(price) > ( select avg(price) from artworks)

--18. Write a query to create a view that shows artists who have created artworks in multiple genres.
go
create view ArtworksGenre
@
as
select artists.artist_id ,artists.[name]
from artists
artist_id IN ( select artist_id from artworks
                     group by  artist_id
					 having count(genre)>1)
go

--### Section 4: 4 Marks Questions

--19. Write a query to convert the artists and their artworks into JSON format.
select artists.artist_id as 'Artists.Artis_id',
artists.[name] as 'Artists.Name', 
artworks.artwork_id as 'ArtWorks.Artwork_ID', 
title as 'ArtWorks.Title'
from artists
join artworks on artists.artist_id=artworks.artist_id
for json path , root('Arts_Artists')

--20. Write a query to export the artists and their artworks into XML format.
select artists.artist_id as [Artists/Artis_id],
artists.[name] as [Artists/Name], 
artworks.artwork_id as [ArtWorks/Artwork_ID], 
title as [ArtWorks.Title]
from artists
join artworks on artists.artist_id=artworks.artist_id
for xml path , root('Arts_Artists')

--### Section 5: 5 Marks Questions

--21. Create a trigger to log changes to the `artworks` table into an `artworks_log` table, capturing the `artwork_id`, `title`, and a change description.

select * from artists
select * from artworks
select * from sales


create trigger trg_LogArtworks
on artworks
after update
as
begin
Insert into artworks_log
select artwort_id , title  , genre 
from artworks
end
go

update artworks
set title='Hello'
where artwork_id=1



--22. Create a scalar function to calculate the average sales amount for artworks in a given genre and write a query to use this function for 'Impressionism'.
go
create function dbo.AvgSalesAmt(@genre nvarchar(30))
returns int
as
begin
declare @result int
set @result=(select avg(total_amount) as AvgAmt
from artworks
join sales on artworks.artwork_id=sales.artwork_id
group by genre
having genre =@genre)
return @result
end
go

select dbo.AvgSalesAmt('Cubism')

--23. Create a stored procedure to add a new sale and update the total sales for the artwork. Ensure the quantity is positive, and use transactions to maintain data integrity.
go
create procedure SalesUpdate
 @Newsale_id int,
 @Newartwork_id int,
 @Newsalesdate date,
 @Quantity int ,
 @Newtotal_amount decimal(10,2)
 as
 begin 
 begin transaction
 begin try
  if @Quantity<1
  throw 600000,'Quantity should be positive !!' , 1;

  Insert into sales values (@Newsale_id,@Newartwork_id,@Newsalesdate,@Quantity,@Newtotal_amount)
   update sales
   set total_amount=@Newtotal_amount
   where sale_id=@Newsale_id
 commit transaction;
 end try
 begin catch
 rollback;
 print (error_number())
 print(error_message())
 print(error_state())
 end catch
 end

 exec SalesUpdate @Newsale_id=6,@Newartwork_id=6,@Newsalesdate='2024-07-01',@Quantity=-4,@Newtotal_amount=600.00


--24. Create a multi-statement table-valued function (MTVF) to return the total quantity sold for each genre and use it in a query to display the results.
go
create function dbo.TotalQuantity()
returns @QuantityPerGenre table (@artwork_id,@genre,@quantity)
as
begin
Insert into @QuantityPerGenre
select  genre , sum(quantity) as TotalQuantity
from artworks
join sales on artworks.artwork_id=sales.artwork_id
group by genre
returns;
end
go

select * from dbo.TotalQuantity();

--25. Write a query to create an NTILE distribution of artists based on their total sales, divided into 4 tiles.

select artists.artist_id , artists.[name] , ntile(4) over (order by sum(total_amount)) as Tiles
from artists
join artworks on artists.artist_id=artworks.artist_id
join sales on artworks.artwork_id=sales.artwork_id
group by artists.artist_id , artists.[name]

select * from artists
select * from artworks
select * from sales



--### Normalization (5 Marks)

--26. **Question:**
 --Given the denormalized table `ecommerce_data` with sample data:

| id  | customer_name | customer_email      | product_name | product_category | product_price | order_date | order_quantity | order_total_amount |
| --- | ------------- | ------------------- | ------------ | ---------------- | ------------- | ---------- | -------------- | ------------------ |
| 1   | Alice Johnson | alice@example.com   | Laptop       | Electronics      | 1200.00       | 2023-01-10 | 1              | 1200.00            |
| 2   | Bob Smith     | bob@example.com     | Smartphone   | Electronics      | 800.00        | 2023-01-15 | 2              | 1600.00            |
| 3   | Alice Johnson | alice@example.com   | Headphones   | Accessories      | 150.00        | 2023-01-20 | 2              | 300.00             |
| 4   | Charlie Brown | charlie@example.com | Desk Chair   | Furniture        | 200.00        | 2023-02-10 | 1              | 200.00             |

--Normalize this table into 3NF (Third Normal Form). Specify all primary keys, foreign key constraints, unique constraints, not null constraints, and check constraints.

--### ER Diagram (5 Marks)

--27. Using the normalized tables from Question 26, create an ER diagram. Include the entities, relationships, primary keys, foreign keys, unique constraints, not null constraints, and check constraints. Indicate the associations using proper ER diagram notation.