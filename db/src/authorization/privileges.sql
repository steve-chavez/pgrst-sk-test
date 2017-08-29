\echo # Loading roles privilege

-- this file contains the privileges of all aplications roles to each database entity
-- if it gets too long, you can split it one file per entity

-- set default privileges to all the entities created by the auth lib
select auth.set_auth_endpoints_privileges('api', :'anonymous', enum_range(null::data.user_role)::text[]);

-- specify which application roles can access this api (you'll probably list them all)
-- remember to list all the values of user_role type here
grant usage on schema api to anonymous, webuser;

-- define the who can access todo model data
-- enable RLS on the table holding the data
alter table data.todo enable row level security;
-- define the RLS policy controlling what rows are visible to a particular application user
create policy todo_access_policy on data.todo to api 
using (
	-- the authenticated users can see all his todo items
	-- notice how the rule changes based on the current user_id
	-- which is specific to each individual request
	(request.user_role() = 'webuser' and request.user_id() = owner_id)

	or
	-- everyone can see public todo
	(private = false)
)
with check (
	-- authenticated users can only update/delete their todos
	(request.user_role() = 'webuser' and request.user_id() = owner_id)
);


-- give access to the view owner to this table
grant select, insert, update, delete on data.todo to api;
grant usage on data.todo_id_seq to webuser;


-- While grants to the view owner and the RLS policy on the underlying table 
-- takes care of what rows the view can see, we still need to define what 
-- are the rights of our application user in regard to this api view.

-- authenticated users can request/change all the columns for this view
grant select, insert, update, delete on api.todos to webuser;

-- anonymous users can only request specific columns from this view
grant select (id, todo) on api.todos to anonymous;
-------------------------------------------------------------------------------
grant select, insert, update, delete 
on api.clients, api.projects, api.tasks, api.comments
to webuser;

set search_path = data, public;

alter table client enable row level security;
grant select, insert, update, delete on client to api;
create policy access_own_rows on client to api
using ( request.user_role() = 'webuser' and request.user_id() = user_id )
with check ( request.user_role() = 'webuser' and request.user_id() = user_id);


alter table project enable row level security;
grant select, insert, update, delete on project to api;
create policy access_own_rows on project to api
using ( request.user_role() = 'webuser' and request.user_id() = user_id )
with check ( request.user_role() = 'webuser' and request.user_id() = user_id);


alter table task enable row level security;
grant select, insert, update, delete on task to api;
create policy access_own_rows on task to api
using ( request.user_role() = 'webuser' and request.user_id() = user_id )
with check ( request.user_role() = 'webuser' and request.user_id() = user_id);


alter table project_comment enable row level security;
grant select, insert, update, delete on project_comment to api;
create policy access_own_rows on project_comment to api
using ( request.user_role() = 'webuser' and request.user_id() = user_id )
with check ( request.user_role() = 'webuser' and request.user_id() = user_id);

alter table task_comment enable row level security;
grant select, insert, update, delete on task_comment to api;
create policy access_own_rows on task_comment to api
using ( request.user_role() = 'webuser' and request.user_id() = user_id )
with check ( request.user_role() = 'webuser' and request.user_id() = user_id);

grant usage on sequence data.client_id_seq to webuser;
grant usage on sequence data.project_id_seq to webuser;
grant usage on sequence data.task_id_seq to webuser;
grant usage on sequence data.task_comment_id_seq to webuser;
grant usage on sequence data.project_comment_id_seq to webuser;
