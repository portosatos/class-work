--
-- PostgreSQL database dump
--

\restrict HTivn4gSY9HVsBDFHyxlRtqTSdGo7opjcoKSqjJxqnC74iTBMGk71WyiYrjBWZI

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: customer_feedback; Type: TABLE; Schema: public; Owner: ulan
--

CREATE TABLE public.customer_feedback (
    id integer NOT NULL,
    author character varying(50),
    comment text
);


ALTER TABLE public.customer_feedback OWNER TO ulan;

--
-- Name: customer_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: ulan
--

CREATE SEQUENCE public.customer_feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_feedback_id_seq OWNER TO ulan;

--
-- Name: customer_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ulan
--

ALTER SEQUENCE public.customer_feedback_id_seq OWNED BY public.customer_feedback.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: ulan
--

CREATE TABLE public.customers (
    customer_id integer NOT NULL,
    name character varying(100),
    email character varying(100)
);


ALTER TABLE public.customers OWNER TO ulan;

--
-- Name: departments; Type: TABLE; Schema: public; Owner: ulan
--

CREATE TABLE public.departments (
    department_id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.departments OWNER TO ulan;

--
-- Name: departments_department_id_seq; Type: SEQUENCE; Schema: public; Owner: ulan
--

CREATE SEQUENCE public.departments_department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departments_department_id_seq OWNER TO ulan;

--
-- Name: departments_department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ulan
--

ALTER SEQUENCE public.departments_department_id_seq OWNED BY public.departments.department_id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: ulan
--

CREATE TABLE public.employees (
    employee_id integer NOT NULL,
    first_name character varying(50),
    last_name character varying(50),
    email character varying(100),
    department character varying(50),
    hire_date date
);


ALTER TABLE public.employees OWNER TO ulan;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: ulan
--

CREATE SEQUENCE public.employees_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employees_employee_id_seq OWNER TO ulan;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ulan
--

ALTER SEQUENCE public.employees_employee_id_seq OWNED BY public.employees.employee_id;


--
-- Name: log_table_id_seq; Type: SEQUENCE; Schema: public; Owner: ulan
--

CREATE SEQUENCE public.log_table_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.log_table_id_seq OWNER TO ulan;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: ulan
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    customer_id integer,
    order_date date,
    total numeric(10,2)
);


ALTER TABLE public.orders OWNER TO ulan;

--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: ulan
--

CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_order_id_seq OWNER TO ulan;

--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ulan
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: ulan
--

CREATE TABLE public.products (
    product_id integer NOT NULL,
    name character varying(50),
    category character varying(50),
    price numeric(10,2)
);


ALTER TABLE public.products OWNER TO ulan;

--
-- Name: sales_data; Type: TABLE; Schema: public; Owner: ulan
--

CREATE TABLE public.sales_data (
    sale_id integer NOT NULL,
    region character varying(20),
    amount numeric(10,2),
    note text
);


ALTER TABLE public.sales_data OWNER TO ulan;

--
-- Name: customer_feedback id; Type: DEFAULT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.customer_feedback ALTER COLUMN id SET DEFAULT nextval('public.customer_feedback_id_seq'::regclass);


--
-- Name: departments department_id; Type: DEFAULT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.departments ALTER COLUMN department_id SET DEFAULT nextval('public.departments_department_id_seq'::regclass);


--
-- Name: employees employee_id; Type: DEFAULT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.employees ALTER COLUMN employee_id SET DEFAULT nextval('public.employees_employee_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- Data for Name: customer_feedback; Type: TABLE DATA; Schema: public; Owner: ulan
--

COPY public.customer_feedback (id, author, comment) FROM stdin;
1	Aibek	Fast delivery, great price
2	Ainura	The box said "fragile", it was not packed well
3	Bakyt	Fine, thanks
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: ulan
--

COPY public.customers (customer_id, name, email) FROM stdin;
3	Bakyt Mamatov	bakyt@mail.kg
1	Aibek Sharshenov	aibek@mail.kg
2	Ainura Toktomamatova	ainura.new@mail.kg
5	Bermet Asanova	bermet@mail.kg
6	Kanykei Osmonova	kanykei@mail.kg
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: ulan
--

COPY public.departments (department_id, name) FROM stdin;
1	IT
2	Sales
3	HR
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: ulan
--

COPY public.employees (employee_id, first_name, last_name, email, department, hire_date) FROM stdin;
1	Aibek	Sharshenov	aibek@corp.kg	IT	2021-03-15
2	Ainura	Toktomamatova	\N	IT	2022-07-01
3	Bakyt	Mamatov	bakyt@corp.kg	Sales	2020-01-10
4	Gulzat	Sultanova	gulzat@corp.kg	HR	2023-05-05
5	Nursultan	Isakov	nursultan@corp.kg	\N	\N
6	Meerim	Bekova	meerim@corp.kg	\N	\N
7	Tilek	Usubaliev	tilek@corp.kg	\N	\N
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: ulan
--

COPY public.orders (order_id, customer_id, order_date, total) FROM stdin;
1	1	2026-10-01	1220.00
2	2	2026-10-03	300.00
3	1	2026-10-20	20.00
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: ulan
--

COPY public.products (product_id, name, category, price) FROM stdin;
1	Laptop	Electronics	1200.00
2	Mouse	Electronics	20.00
3	Desk	Furniture	300.00
10	Webcam	Electronics	59.90
12	Microphone	Electronics	120.00
13	Ring light	Accessories	35.50
\.


--
-- Data for Name: sales_data; Type: TABLE DATA; Schema: public; Owner: ulan
--

COPY public.sales_data (sale_id, region, amount, note) FROM stdin;
1	North	1200.00	\N
2	South	\N	late payment
3	East	560.50	\N
\.


--
-- Name: customer_feedback_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ulan
--

SELECT pg_catalog.setval('public.customer_feedback_id_seq', 3, true);


--
-- Name: departments_department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ulan
--

SELECT pg_catalog.setval('public.departments_department_id_seq', 3, true);


--
-- Name: employees_employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ulan
--

SELECT pg_catalog.setval('public.employees_employee_id_seq', 7, true);


--
-- Name: log_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ulan
--

SELECT pg_catalog.setval('public.log_table_id_seq', 1000, true);


--
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ulan
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 3, true);


--
-- Name: customer_feedback customer_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.customer_feedback
    ADD CONSTRAINT customer_feedback_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: departments departments_name_key; Type: CONSTRAINT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_name_key UNIQUE (name);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (department_id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (employee_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: sales_data sales_data_pkey; Type: CONSTRAINT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.sales_data
    ADD CONSTRAINT sales_data_pkey PRIMARY KEY (sale_id);


--
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- PostgreSQL database dump complete
--

\unrestrict HTivn4gSY9HVsBDFHyxlRtqTSdGo7opjcoKSqjJxqnC74iTBMGk71WyiYrjBWZI

