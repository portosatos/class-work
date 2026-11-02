--
-- PostgreSQL database dump
--

\restrict 8f4dm9OsZEqR0phaBdugPE8vLBi8QxwxGPzDHQoab4jXrTMpbdHCFi1jrybnNpE

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
-- Name: departments department_id; Type: DEFAULT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.departments ALTER COLUMN department_id SET DEFAULT nextval('public.departments_department_id_seq'::regclass);


--
-- Name: employees employee_id; Type: DEFAULT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.employees ALTER COLUMN employee_id SET DEFAULT nextval('public.employees_employee_id_seq'::regclass);


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
-- Name: departments_department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ulan
--

SELECT pg_catalog.setval('public.departments_department_id_seq', 3, true);


--
-- Name: employees_employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ulan
--

SELECT pg_catalog.setval('public.employees_employee_id_seq', 7, true);


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
-- PostgreSQL database dump complete
--

\unrestrict 8f4dm9OsZEqR0phaBdugPE8vLBi8QxwxGPzDHQoab4jXrTMpbdHCFi1jrybnNpE

