-- Tarea 1 -- 
-- 1 --


create table pago as (
with t as (
	select p.payment_date as fecha, p.payment_id as id from payment p
	where p.payment_id > 1), 
	s as(
	select sum(age(t.fecha, pa.payment_date)) as tiempo, pa.customer_id as id2, count(pa.payment_id) as suma 
	from payment pa join t on (pa.payment_id = t.id-1)
	where age(t.fecha, pa.payment_date)>'00:00'::interval
	group by pa.customer_id 
) 
select concat(c.first_name, ' ', c.last_name) as "nombre", (s.tiempo/s.suma) as "Tiempo promedio de pago", c.customer_id as id 
from customer c join s on (c.customer_id = s.id2)
group by c.customer_id,(s.tiempo/s.suma),concat(c.first_name, ' ', c.last_name) order by c.customer_id asc
)

select * from pago;

-- 2 --
select * from histogram('pago', 'extract(epoch from
"Tiempo promedio de pago")') 

-- vemos que no sigue la campana de gauss por lo tanto no es distribución normal

-- 3 --
create sequence seq minvalue 1 maxvalue 300000 increment by 1

create sequence seq2 minvalue 2 maxvalue 300000 increment by 1

-- drop sequence seq,seq2 --para cuando la riego

create table renta as(
with r as (
	select nextval ('seq') as "secuencia", r2.rental_date as fecha, r2.rental_id as id from rental r2
	where r2.rental_id <>76 order by r2.customer_id, r2.rental_date asc), 
	x as (
	select nextval ('seq2') as "secuencia2", r2.customer_id, r2.rental_date as fecha, r2.rental_id as id from rental r2
	order by r2.customer_id, r2.rental_date asc ),
	 w as(
	select sum(age(r.fecha, x.fecha)) as tiempo, x.customer_id as id2, count(x.id) as suma 
	from x join r on (r."secuencia" = x."secuencia2"-1)
	where age(r.fecha, x.fecha)>'00:00'::interval
	group by x.customer_id
)
select concat(c.first_name, ' ', c.last_name) as "nombre", (w.tiempo/w.suma) as "Tiempo promedio de renta", c.customer_id as id 
from customer c join w on (c.customer_id=w.id2)
group by c.customer_id,(w.tiempo/w.suma),concat(c.first_name, ' ', c.last_name)
)
select * from renta

-- cuanto difieren

select p."nombre", (p."Tiempo promedio de pago"-r."Tiempo promedio de renta") as "diferencia", p.id 
from pago p 
join renta r using (id) 
order by p.id asc; 
------------------------------------------------
--los diferentes a 0 solo por chisme

select p."nombre", (p."Tiempo promedio de pago"-r."Tiempo promedio de renta") as "diferencia", p.id 
from pago p 
join renta r using (id) 
where (p."Tiempo promedio de pago"-r."Tiempo promedio de renta")<>'00:00:00'::interval 
order by p.id asc; 

------------------------------------------------
-- Tarea 2 --
--saco el num de cajas de películas por tienda--

with movies_per_store as (select store_id, count(i.film_id) as "num pels" from inventory i group by store_id),

--num max de peliculas por cilindro, 50 kg entre .5 kg por película ya con todo y arnés
	nummax as (select 50/.5 as "pels por cilindro"),

--altura del cilindro, aquí suponemos que están pegadas todas las películas, 
-- si les quisiéramos dar una separación de 1 cm entre c/u sería algo como 
-- select 2.5*nm."pels por cilindro"-1 as "altura"  from nummax nm, el -1 porque para el techo ya no necesitas separación
	ht as (select 1.5*nm."pels por cilindro" as "altura"  from nummax nm),

--radio de la base del cilindro, entrarán exacto si el radio es igual a la mitad de una diagonal de una película, 
-- si queremos que estén más holgadas le podemos poner +2 al final para que las esquinas estén a 1 cm del perímetro del círculo
	rad as (select sqrt(power(30/2,2) + power(21/2,2)) as "radio")

--volumen del cilindro
 select pi()*power(r."radio",2)*h."altura" as "volumen" from rad r, ht h;

--cilindros necesarios por tienda

select store_id, ceil(mps."num pels"/100) as "cilindros necesarios por tienda" from movies_per_store mps





