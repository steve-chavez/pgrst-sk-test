drop schema if exists util cascade;
create schema util;
set search_path = util, public;
\ir mutation_comments_view.sql;
