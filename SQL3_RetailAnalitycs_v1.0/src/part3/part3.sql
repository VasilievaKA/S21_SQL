DROP ROLE IF EXISTS Administrator;
CREATE ROLE Administrator WITH LOGIN PASSWORD '111';

-- Предоставляем роли "Администратор" все права на все таблицы в схеме "public"
GRANT ALL ON ALL TABLES IN SCHEMA public TO Administrator;
-- Предоставляем роли "Администратор" право использования схемы "public"
GRANT USAGE ON SCHEMA public TO Administrator;
-- Предоставляем роли "Администратор" право выполнения всех функций в схеме "public"
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO Administrator;
-- Предоставляем роли "Администратор" все права на все последовательности в схеме "public"
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO Administrator;

-- Устанавливаем права по умолчанию для роли "Администратор" на все будущие таблицы в схеме "public"
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO Administrator;

DROP ROLE IF EXISTS Visitor;
CREATE ROLE Visitor WITH LOGIN PASSWORD '111';

-- Предоставляем роли "Посетитель" право выборки данных на все таблицы в схеме "public"
GRANT SELECT ON ALL TABLES IN SCHEMA public TO Visitor;
-- Предоставляем роли "Посетитель" право использования схемы "public"
GRANT USAGE ON SCHEMA public TO Visitor;

DROP OWNED BY Administrator CASCADE;
DROP OWNED BY Visitor CASCADE;


-- a - разрешение на доступ к объекту (таблице, представлению и т. д.)
-- r - разрешение на чтение (SELECT)
-- w - разрешение на запись (INSERT, UPDATE)
-- d - разрешение на удаление (DELETE)
-- D - разрешение на удаление строк, не связанных с ключом (TRUNCATE)
-- x - разрешение на выполнение (EXECUTE)
-- t - разрешение на управление данными (право изменять структуру объекта, например, ALTER)

-- /dp public.* (command got checking privileges)