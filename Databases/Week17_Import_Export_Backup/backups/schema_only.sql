--
-- PostgreSQL database dump
--

\restrict vcDFabys4kgIjGi2BmUD8adCywkZdyBqvMF2kP2PKVlZqkBHOCko1QoKy9doe9d

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
-- Name: log_table; Type: TABLE; Schema: public; Owner: ulan
--

CREATE TABLE public.log_table (
    id integer NOT NULL,
    message text
);


ALTER TABLE public.log_table OWNER TO ulan;

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
-- Name: log_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ulan
--

ALTER SEQUENCE public.log_table_id_seq OWNED BY public.log_table.id;


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
-- Name: log_table id; Type: DEFAULT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.log_table ALTER COLUMN id SET DEFAULT nextval('public.log_table_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


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
-- Name: log_table log_table_pkey; Type: CONSTRAINT; Schema: public; Owner: ulan
--

ALTER TABLE ONLY public.log_table
    ADD CONSTRAINT log_table_pkey PRIMARY KEY (id);


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

\unrestrict vcDFabys4kgIjGi2BmUD8adCywkZdyBqvMF2kP2PKVlZqkBHOCko1QoKy9doe9d

