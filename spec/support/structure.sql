SET search_path = 'public';


CREATE TABLE posts (
    id integer NOT NULL,
    title character varying NOT NULL,
    description character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE posts_id_seq OWNED BY posts.id;

ALTER TABLE ONLY posts ALTER COLUMN id SET DEFAULT nextval('posts_id_seq'::regclass);

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);
