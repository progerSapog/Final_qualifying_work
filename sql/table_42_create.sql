CREATE DATABASE VKR_DISCIPLINE_CONTENT;

-- Словарь форм обучения:
--  очная, очно-заочная, вечерняя
CREATE TABLE DISCIPLINE_TYPE_DICTIONARY
(
    name VARCHAR(150) NOT NULL PRIMARY KEY
);
INSERT INTO DISCIPLINE_TYPE_DICTIONARY (name) VALUES
('очная'), ('очно-заочная'), ('заочная');

-- таблица дисциплин
--  связана с разделами дисциплин через таблицу DISCIPLINE_SECTION_JOIN_TABLE
CREATE TABLE DISCIPLINE
(
    id SERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    discipline_type VARCHAR(20) NOT NULL,

    CONSTRAINT discipline_type_fk
        FOREIGN KEY (discipline_type)
        REFERENCES DISCIPLINE_TYPE_DICTIONARY(name)
);
INSERT INTO DISCIPLINE VALUES
(1, 'Шаблоны проектирования программного обеспечения', 'очная');

-- Словарь типов раделов:
--  раздел, тема, практическая работа, лабораторная работа, семинар и тд.
CREATE TABLE SECTION_TYPE_DICTIONARY(
    name VARCHAR(150) NOT NULL PRIMARY KEY
);
INSERT INTO SECTION_TYPE_DICTIONARY (name) VALUES
('Тема'), ('Раздел'), ('Практическая работа'), ('Лабораторная работа');

-- Таблица разделов дисциплин
--  содержит дерево дисциплин
--  связана с дисциплинами через таблицу DISCIPLINE_SECTION_JOIN_TABLE
CREATE TABLE DISCIPLINE_SECTION
(
    id SERIAL NOT NULL PRIMARY KEY,
    parent_id INTEGER,
    section_type VARCHAR(50) NOT NULL,
    name VARCHAR(150) NOT NULL,

    CONSTRAINT parent_id_fk
        FOREIGN KEY (parent_id)
        REFERENCES DISCIPLINE_SECTION(id),
    CONSTRAINT section_type_fk
        FOREIGN KEY (section_type)
        REFERENCES SECTION_TYPE_DICTIONARY(name)
);
INSERT INTO DISCIPLINE_SECTION VALUES
(1, NULL, 'Тема', 'Объектно-оринтированный подход к программированию'),
(2, 1, 'Тема', 'Основные (фундоментальные) шаблоны GoF'),
(3, 1, 'Тема', 'Порождающие шаблоны GoF');

-- Словарь видов учебной работы:
--  лекции, лабораторные, практические, семинары, самостоятельная работа и тд.
CREATE TABLE JOBS_TYPE_DICTIONARY
(
    name VARCHAR(150) NOT NULL PRIMARY KEY
);
INSERT INTO JOBS_TYPE_DICTIONARY VALUES
('Лекции'),
('Лабораторные работы'),
('Практические занятия'),
('КСР'),
('Самостоятельная работа');

-- Виды учебной работы
CREATE TABLE JOBS_TYPE
(
    id SERIAL NOT NULL PRIMARY KEY,
    section_id INTEGER NOT NULL,
    hours INTEGER NOT NULL,
    type VARCHAR(150) NOT NULL,
    independent_flag BOOL NOT NULL,

    CONSTRAINT section_fk
        FOREIGN KEY (section_id)
        REFERENCES DISCIPLINE_SECTION(id),
    CONSTRAINT jobs_type_fk
        FOREIGN KEY (type)
        REFERENCES JOBS_TYPE_DICTIONARY(name)
);
INSERT INTO JOBS_TYPE VALUES
(1, 1, 1, 'Лекции', false),
(2, 1, 1, 'Лабораторные работы', false),
(3, 1, 5, 'Самостоятельная работа', true);

-- Таблицы связи дисциплины и секций
--  указываем id только раздела (без потомоков)
--  чтобы уменьшить кол-во записей в данной таблице
--
--  пример: id дисциплины, id раздела, а потомки раздела
--    приятгиваются автоматически
CREATE TABLE DISCIPLINE_SECTION_JOIN_TABLE
(
    discipline_id INTEGER NOT NULL,
    section_id    INTEGER NOT NULL,
    CONSTRAINT discipline_section_pk
      PRIMARY KEY (discipline_id, section_id),

    CONSTRAINT discipline_fk
        FOREIGN KEY (discipline_id)
        REFERENCES DISCIPLINE(id),
    CONSTRAINT discipline_section_fk
        FOREIGN KEY (section_id)
        REFERENCES discipline_section(id)
);
INSERT INTO DISCIPLINE_SECTION_JOIN_TABLE VALUES
(1,1);

-- Самостоятельная работа студентов вынеса в отдельную
-- таблицы из за её разреженности относительно таблицы разделов
CREATE TABLE CPC
(
    id SERIAL NOT NULL PRIMARY KEY,
    section_id INTEGER NOT NULL,
    text VARCHAR(250),

    CONSTRAINT section_fk
        FOREIGN KEY (section_id)
        REFERENCES DISCIPLINE_SECTION(id)
);
INSERT INTO CPC VALUES
(1, 1, 'CPC1'),
(2, 3, 'CPC2');

-- Наименование используемых активных ресурсов вынесено
-- в отдельную таблицу из за её разреженности относительно
-- разделов и СРС
CREATE TABLE EDUCATION_TECHNOLOGY
(
    id SERIAL NOT NULL PRIMARY KEY,
    section_id INTEGER NOT NULL,
    name VARCHAR(250),

    CONSTRAINT section_fk
        FOREIGN KEY (section_id)
        REFERENCES DISCIPLINE_SECTION(id)
);
INSERT INTO EDUCATION_TECHNOLOGY VALUES
(1, 1, 'Активный ресурс1'),
(2, 2, 'Активный ресурс2');

--Словарь видов подготовки:
-- практическая подготовка, электронный курс и тд.
CREATE TABLE TRAINING_TYPE_DICTIONARY
(
    type VARCHAR(150) NOT NULL PRIMARY KEY
);
INSERT INTO TRAINING_TYPE_DICTIONARY VALUES
('Практическая подготовка'),
('Электронный курс');

-- Наименование используемых активных ресурсов вынесено
-- в отдельную таблицу из за её разреженности относительно
-- разделов
CREATE TABLE TRAINING_TYPE
(
    id SERIAL NOT NULL PRIMARY KEY,
    section_id INTEGER NOT NULL,
    type VARCHAR(150) NOT NULL,
    hours INTEGER NOT NULL,

    CONSTRAINT section_fk
        FOREIGN KEY (section_id)
        REFERENCES DISCIPLINE_SECTION(id),
    CONSTRAINT training_type_fk
        FOREIGN KEY (type)
        REFERENCES TRAINING_TYPE_DICTIONARY(type)
);
INSERT INTO TRAINING_TYPE VALUES
(1, 1, 'Практическая подготовка', 6),
(2, 3, 'Электронный курс', 9);

COMMIT;