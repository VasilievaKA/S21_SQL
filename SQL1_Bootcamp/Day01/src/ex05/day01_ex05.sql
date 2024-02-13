select pe.id, pe.name, pe.age, pe.gender, pe.address, pi.id, pi.name, pi.rating 
from person as pe cross join pizzeria as pi
order by pe.id, pi.id