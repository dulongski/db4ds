with cantidades as(
	select o.customer_id as cliente, o.order_id as orden, od.unit_price*od.quantity as pq, o.order_date as fecha
	from order_details od 
	join orders o 
	using (order_id)
	), deltas as (
	select extract(year from c.fecha) as ano, extract(month from c.fecha) as mes, c.cliente as cliente,(pq-lag(pq) over (partition by c.cliente order by fecha asc)) as delta 
	from cantidades c)

select d.ano,
d.mes, 
d.cliente, avg(d.delta) from deltas d 
group by d.mes, d.ano, d.cliente order by d.cliente asc, d.ano asc, d.mes asc
--si sale null es que no habia al menos dos para sacar el promedio