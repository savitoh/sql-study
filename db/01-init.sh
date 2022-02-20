#!/bin/bash
set -e
export PGPASSWORD=$POSTGRES_PASSWORD;
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  
  SELECT 'CREATE DATABASE $OLIST_DB' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$OLIST_DB')\gexec
  
  \connect $OLIST_DB $POSTGRES_USER

  BEGIN;
    CREATE TABLE IF NOT EXISTS orders
    (
        order_id character varying(10000) COLLATE pg_catalog."default" NOT NULL,
        customer_id character varying(10000) COLLATE pg_catalog."default",
        order_status character varying(10000) COLLATE pg_catalog."default",
        order_purchase_timestamp timestamp without time zone,
        order_approved_at timestamp without time zone,
        order_delivered_carrier_date timestamp without time zone,
        order_delivered_customer_date timestamp without time zone,
        order_estimated_delivery_date timestamp without time zone,
        CONSTRAINT orders_pkey PRIMARY KEY (order_id)
    );

    
    CREATE TABLE IF NOT EXISTS order_reviews
    (
        review_id character varying(10000) COLLATE pg_catalog."default",
        order_id character varying(10000) COLLATE pg_catalog."default",
        review_score integer,
        review_comment_title character varying(10000) COLLATE pg_catalog."default",
        review_comment_message character varying(10000) COLLATE pg_catalog."default",
        review_creation_date timestamp without time zone,
        review_answer_timestamp timestamp without time zone,
        CONSTRAINT order_reviews_order_id_fkey FOREIGN KEY (order_id)
            REFERENCES orders (order_id) MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE CASCADE
    );


    CREATE TABLE IF NOT EXISTS order_payments
    (
        order_id character varying(10000) COLLATE pg_catalog."default",
        payment_sequential integer,
        payment_type character varying(10000) COLLATE pg_catalog."default",
        payment_installments integer,
        payment_value double precision,
        CONSTRAINT order_payments_order_id_fkey FOREIGN KEY (order_id)
            REFERENCES orders (order_id) MATCH SIMPLE
            ON UPDATE NO ACTION
            ON DELETE CASCADE
    );


    CREATE TABLE IF NOT EXISTS customers
    (
        customer_id character varying(10000) COLLATE pg_catalog."default" NOT NULL,
        customer_unique_id character varying(10000) COLLATE pg_catalog."default",
        customer_zip_code_prefix integer,
        customer_city character varying(10000) COLLATE pg_catalog."default",
        customer_state character varying(10000) COLLATE pg_catalog."default",
        CONSTRAINT customers_pkey PRIMARY KEY (customer_id)
    );


    CREATE TABLE IF NOT EXISTS geolocation
    (
        geolocation_zip_code_prefix integer,
        geolocation_lat double precision,
        geolocation_lng double precision,
        geolocation_city character varying(10000) COLLATE pg_catalog."default",
        geolocation_state character varying(10000) COLLATE pg_catalog."default"
    );


    CREATE TABLE IF NOT EXISTS products
    (
        product_id character varying(10000) COLLATE pg_catalog."default" NOT NULL,
        product_category_name character varying(10000) COLLATE pg_catalog."default",
        product_name_lenght double precision,
        product_description_lenght double precision,
        product_photos_qty double precision,
        product_weight_g double precision,
        product_length_cm double precision,
        product_height_cm double precision,
        product_width_cm double precision,
        CONSTRAINT products_pkey PRIMARY KEY (product_id)
    );


    CREATE TABLE IF NOT EXISTS sellers
    (
        seller_id character varying(10000) COLLATE pg_catalog."default" NOT NULL,
        seller_zip_code_prefix integer,
        seller_city character varying(10000) COLLATE pg_catalog."default",
        seller_state character varying(10000) COLLATE pg_catalog."default",
        CONSTRAINT sellers_pkey PRIMARY KEY (seller_id)
    );


    CREATE TABLE IF NOT EXISTS order_items
    (
        order_id character varying(10000) COLLATE pg_catalog."default",
        order_item_id integer,
        product_id character varying(10000) COLLATE pg_catalog."default",
        seller_id character varying(10000) COLLATE pg_catalog."default",
        shipping_limit_date timestamp without time zone,
        price double precision,
        freight_value double precision,
        CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id)
            REFERENCES orders (order_id) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id)
            REFERENCES products (product_id) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION,
        CONSTRAINT order_items_seller_id_fkey FOREIGN KEY (seller_id)
            REFERENCES sellers (seller_id) MATCH SIMPLE
            ON UPDATE CASCADE
            ON DELETE NO ACTION
    );


  COMMIT;
EOSQL