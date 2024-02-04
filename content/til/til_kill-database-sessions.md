+++

title = "Kill Database Sessions"
date = "2024-01-21"
draft = false

[taxonomies]
tags = ["database", "til"]
categories = ["Today I Learned", "PostgreSQL"]


[extra]
lang = "en"
toc = false

+++

The following snippet kills all connected database sessions except the current connected connection.

```sql
SELECT
  pg_terminate_backend(pid)
FROM
  pg_stat_activity
WHERE
  pid <> pg_backend_pid()
  AND datname = 'database_name';
```
