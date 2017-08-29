START TRANSACTION;

DROP SCHEMA util CASCADE;

SET search_path = api, pg_catalog;

DROP VIEW clients;

DROP VIEW comments;

DROP VIEW projects;

DROP VIEW tasks;

DROP VIEW todos;

CREATE VIEW todos AS
	SELECT ('#'::text || (todo.id)::text) AS id,
    ('do this: '::text || todo.todo) AS todo,
    todo.private,
    (todo.owner_id = request.user_id()) AS mine
   FROM data.todo;
REVOKE ALL ON TABLE todos FROM webuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE todos TO webuser;

SET search_path = data, pg_catalog;

DROP TABLE client;

DROP TABLE project_comment;

DROP TABLE task_comment;

DROP TABLE project;

DROP TABLE task;

DROP SEQUENCE client_id_seq;

DROP SEQUENCE project_comment_id_seq;

DROP SEQUENCE project_id_seq;

DROP SEQUENCE task_comment_id_seq;

DROP SEQUENCE task_id_seq;

COMMIT TRANSACTION;
