START TRANSACTION;

CREATE SCHEMA util;

SET search_path = api, pg_catalog;

CREATE TABLE client (
	id integer NOT NULL,
	name text NOT NULL,
	address text,
	user_id integer DEFAULT request.user_id() NOT NULL,
	created_on timestamp with time zone DEFAULT now() NOT NULL,
	updated_on timestamp with time zone
);

REVOKE ALL ON TABLE client FROM api;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE client TO api;
ALTER TABLE client  ENABLE ROW LEVEL SECURITY;

CREATE TABLE project_comment (
	id integer NOT NULL,
	body text NOT NULL,
	project_id integer NOT NULL,
	user_id integer DEFAULT request.user_id() NOT NULL,
	created_on timestamp with time zone DEFAULT now() NOT NULL,
	updated_on timestamp with time zone
);

REVOKE ALL ON TABLE project_comment FROM api;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE project_comment TO api;
ALTER TABLE project_comment  ENABLE ROW LEVEL SECURITY;

CREATE TABLE task_comment (
	id integer NOT NULL,
	body text NOT NULL,
	task_id integer NOT NULL,
	user_id integer DEFAULT request.user_id() NOT NULL,
	created_on timestamp with time zone DEFAULT now() NOT NULL,
	updated_on timestamp with time zone
);

REVOKE ALL ON TABLE task_comment FROM api;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE task_comment TO api;
ALTER TABLE task_comment  ENABLE ROW LEVEL SECURITY;

CREATE TABLE project (
	id integer NOT NULL,
	name text NOT NULL,
	client_id integer NOT NULL,
	user_id integer DEFAULT request.user_id() NOT NULL,
	created_on timestamp with time zone DEFAULT now() NOT NULL,
	updated_on timestamp with time zone
);

REVOKE ALL ON TABLE project FROM api;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE project TO api;
ALTER TABLE project  ENABLE ROW LEVEL SECURITY;

CREATE TABLE task (
	id integer NOT NULL,
	name text NOT NULL,
	completed boolean DEFAULT false NOT NULL,
	project_id integer NOT NULL,
	user_id integer DEFAULT request.user_id() NOT NULL,
	created_on timestamp with time zone DEFAULT now() NOT NULL,
	updated_on timestamp with time zone
);

REVOKE ALL ON TABLE task FROM api;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE task TO api;
ALTER TABLE task  ENABLE ROW LEVEL SECURITY;

DROP VIEW todos;

CREATE TRIGGER comments_mutation
	INSTEAD OF INSERT OR UPDATE OR DELETE ON comments
	FOR EACH ROW
	EXECUTE PROCEDURE util.mutation_comments_view();

CREATE VIEW clients AS
	SELECT client.id,
    client.name,
    client.address,
    client.created_on,
    client.updated_on
   FROM data.client;
REVOKE ALL ON TABLE clients FROM webuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE clients TO webuser;

CREATE VIEW comments AS
	SELECT project_comment.id,
    project_comment.body,
    'project'::text AS parent_type,
    project_comment.project_id AS parent_id,
    project_comment.project_id,
    NULL::integer AS task_id,
    project_comment.created_on,
    project_comment.updated_on
   FROM data.project_comment
UNION
 SELECT task_comment.id,
    task_comment.body,
    'task'::text AS parent_type,
    task_comment.task_id AS parent_id,
    NULL::integer AS project_id,
    task_comment.task_id,
    task_comment.created_on,
    task_comment.updated_on
   FROM data.task_comment;
REVOKE ALL ON TABLE comments FROM webuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE comments TO webuser;

CREATE VIEW projects AS
	SELECT project.id,
    project.name,
    project.client_id,
    project.created_on,
    project.updated_on
   FROM data.project;
REVOKE ALL ON TABLE projects FROM webuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE projects TO webuser;

CREATE VIEW tasks AS
	SELECT task.id,
    task.name,
    task.completed,
    task.project_id,
    task.created_on,
    task.updated_on
   FROM data.task;
REVOKE ALL ON TABLE tasks FROM webuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE tasks TO webuser;

CREATE VIEW todos AS
	SELECT todo.id,
    todo.todo,
    todo.private,
    (todo.owner_id = request.user_id()) AS mine
   FROM data.todo;
REVOKE ALL ON TABLE todos FROM webuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE todos TO webuser;

SET search_path = data, pg_catalog;

CREATE SEQUENCE client_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;
REVOKE ALL ON SEQUENCE client_id_seq FROM webuser;
GRANT USAGE ON SEQUENCE client_id_seq TO webuser;

CREATE SEQUENCE project_comment_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;
REVOKE ALL ON SEQUENCE project_comment_id_seq FROM webuser;
GRANT USAGE ON SEQUENCE project_comment_id_seq TO webuser;

CREATE SEQUENCE project_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;
REVOKE ALL ON SEQUENCE project_id_seq FROM webuser;
GRANT USAGE ON SEQUENCE project_id_seq TO webuser;

CREATE SEQUENCE task_comment_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;
REVOKE ALL ON SEQUENCE task_comment_id_seq FROM webuser;
GRANT USAGE ON SEQUENCE task_comment_id_seq TO webuser;

CREATE SEQUENCE task_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;
REVOKE ALL ON SEQUENCE task_id_seq FROM webuser;
GRANT USAGE ON SEQUENCE task_id_seq TO webuser;

ALTER SEQUENCE client_id_seq
	OWNED BY client.id;

ALTER SEQUENCE project_comment_id_seq
	OWNED BY project_comment.id;

ALTER SEQUENCE project_id_seq
	OWNED BY project.id;

ALTER SEQUENCE task_comment_id_seq
	OWNED BY task_comment.id;

ALTER SEQUENCE task_id_seq
	OWNED BY task.id;

ALTER TABLE client
	ADD CONSTRAINT client_pkey PRIMARY KEY (id);

ALTER TABLE project_comment
	ADD CONSTRAINT project_comment_pkey PRIMARY KEY (id);

ALTER TABLE task_comment
	ADD CONSTRAINT task_comment_pkey PRIMARY KEY (id);

ALTER TABLE project
	ADD CONSTRAINT project_pkey PRIMARY KEY (id);

ALTER TABLE task
	ADD CONSTRAINT task_pkey PRIMARY KEY (id);

ALTER TABLE client
	ADD CONSTRAINT client_check CHECK (((updated_on IS NULL) OR (updated_on > created_on)));

ALTER TABLE client
	ADD CONSTRAINT client_name_check CHECK (((length(name) > 2) AND (length(name) < 100)));

ALTER TABLE client
	ADD CONSTRAINT client_user_id_fkey FOREIGN KEY (user_id) REFERENCES "user"(id);

ALTER TABLE project_comment
	ADD CONSTRAINT project_comment_body_check CHECK ((length(body) > 2));

ALTER TABLE project_comment
	ADD CONSTRAINT project_comment_check CHECK (((updated_on IS NULL) OR (updated_on > created_on)));

ALTER TABLE project_comment
	ADD CONSTRAINT project_comment_project_id_fkey FOREIGN KEY (project_id) REFERENCES project(id);

ALTER TABLE project_comment
	ADD CONSTRAINT project_comment_user_id_fkey FOREIGN KEY (user_id) REFERENCES "user"(id);

ALTER TABLE task_comment
	ADD CONSTRAINT task_comment_body_check CHECK ((length(body) > 2));

ALTER TABLE task_comment
	ADD CONSTRAINT task_comment_check CHECK (((updated_on IS NULL) OR (updated_on > created_on)));

ALTER TABLE task_comment
	ADD CONSTRAINT task_comment_task_id_fkey FOREIGN KEY (task_id) REFERENCES task(id);

ALTER TABLE task_comment
	ADD CONSTRAINT task_comment_user_id_fkey FOREIGN KEY (user_id) REFERENCES "user"(id);

ALTER TABLE project
	ADD CONSTRAINT project_check CHECK (((updated_on IS NULL) OR (updated_on > created_on)));

ALTER TABLE project
	ADD CONSTRAINT project_name_check CHECK ((length(name) > 2));

ALTER TABLE project
	ADD CONSTRAINT project_client_id_fkey FOREIGN KEY (client_id) REFERENCES client(id);

ALTER TABLE project
	ADD CONSTRAINT project_user_id_fkey FOREIGN KEY (user_id) REFERENCES "user"(id);

ALTER TABLE task
	ADD CONSTRAINT task_check CHECK (((updated_on IS NULL) OR (updated_on > created_on)));

ALTER TABLE task
	ADD CONSTRAINT task_name_check CHECK ((length(name) > 2));

ALTER TABLE task
	ADD CONSTRAINT task_project_id_fkey FOREIGN KEY (project_id) REFERENCES project(id);

ALTER TABLE task
	ADD CONSTRAINT task_user_id_fkey FOREIGN KEY (user_id) REFERENCES "user"(id);

CREATE INDEX client_user_id_index ON client USING btree (user_id);

CREATE INDEX project_comment_project_id_index ON project_comment USING btree (project_id);

CREATE INDEX project_comment_user_id_index ON project_comment USING btree (user_id);

CREATE INDEX task_comment_task_id_index ON task_comment USING btree (task_id);

CREATE INDEX task_comment_user_id_index ON task_comment USING btree (user_id);

CREATE INDEX project_client_id_index ON project USING btree (client_id);

CREATE INDEX project_user_id_index ON project USING btree (user_id);

CREATE INDEX task_project_id_index ON task USING btree (project_id);

CREATE INDEX task_user_id_index ON task USING btree (user_id);
CREATE POLICY access_own_rows ON client FOR ALL TO api
USING (
  ((request.user_role() = 'webuser'::text) AND (request.user_id() = user_id))
)
WITH CHECK (
  ((request.user_role() = 'webuser'::text) AND (request.user_id() = user_id))
);
CREATE POLICY access_own_rows ON project_comment FOR ALL TO api
USING (
  ((request.user_role() = 'webuser'::text) AND (request.user_id() = user_id))
)
WITH CHECK (
  ((request.user_role() = 'webuser'::text) AND (request.user_id() = user_id))
);
CREATE POLICY access_own_rows ON task_comment FOR ALL TO api
USING (
  ((request.user_role() = 'webuser'::text) AND (request.user_id() = user_id))
)
WITH CHECK (
  ((request.user_role() = 'webuser'::text) AND (request.user_id() = user_id))
);
CREATE POLICY access_own_rows ON project FOR ALL TO api
USING (
  ((request.user_role() = 'webuser'::text) AND (request.user_id() = user_id))
)
WITH CHECK (
  ((request.user_role() = 'webuser'::text) AND (request.user_id() = user_id))
);
CREATE POLICY access_own_rows ON task FOR ALL TO api
USING (
  ((request.user_role() = 'webuser'::text) AND (request.user_id() = user_id))
)
WITH CHECK (
  ((request.user_role() = 'webuser'::text) AND (request.user_id() = user_id))
);

SET search_path = util, pg_catalog;

CREATE OR REPLACE FUNCTION mutation_comments_view() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
    c record;
    parent_type text;
begin
    if (tg_op = 'DELETE') then
        if old.parent_type = 'task' then
            delete from data.task_comment where id = old.id;
            if not found then return null; end if;
        elsif old.parent_type = 'project' then
            delete from data.project_comment where id = old.id;
            if not found then return null; end if;
        end if;
        return old;
    elsif (tg_op = 'UPDATE') then
        if (new.parent_type = 'task' or old.parent_type = 'task') then
            update data.task_comment 
            set 
                body = coalesce(new.body, old.body),
                task_id = coalesce(new.task_id, old.task_id)
            where id = old.id
            returning * into c;
            if not found then return null; end if;
            return (c.id, c.body, 'task'::text, c.task_id, null::int, c.task_id, c.created_on, c.updated_on);
        elsif (new.parent_type = 'project' or old.parent_type = 'project') then
            update data.project_comment 
            set 
                body = coalesce(new.body, old.body),
                project_id = coalesce(new.project_id, old.project_id)
            where id = old.id
            returning * into c;
            if not found then return null; end if;
            return (c.id, c.body, 'project'::text, c.project_id, c.project_id, null::int, c.created_on, c.updated_on);
        end if;
    elsif (tg_op = 'INSERT') then
        if new.parent_type = 'task' then
            insert into data.task_comment (body, task_id)
            values(new.body, new.task_id)
            returning * into c;
            return (c.id, c.body, 'task'::text, c.task_id, null::int, c.task_id, c.created_on, c.updated_on);
        elsif new.parent_type = 'project' then
            insert into data.project_comment (body, project_id)
            values(new.body, new.project_id)
            returning * into c;
            return (c.id, c.body, 'project'::text, c.project_id, c.project_id, null::int, c.created_on, c.updated_on);
        end if;
        
    end if;
    return null;
end;
$$;

COMMIT TRANSACTION;
