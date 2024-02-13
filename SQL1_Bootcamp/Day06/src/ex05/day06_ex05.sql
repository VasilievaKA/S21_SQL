comment on table person_discounts
    is 'Данная таблица предназначена для хранения скидок пользователей в пиццериях в зависимости от количества заказов';
comment on column person_discounts.id is 'Первичный ключ, предназначен для однозначной идентификации строки';
comment on column person_discounts.person_id is 'Внешний ключ, связывает таблицу person_discounts и person';
comment on column person_discounts.pizzeria_id is 'Внешний ключ, связывает таблицу person_discounts и pizzeria';
comment on column person_discounts.discount is 'Атрибут, указывающий размер скидки в процентах';
