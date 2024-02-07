+++

title = "Find PostgreSQL Data Directory"
date = "2024-01-19"
draft = false

[taxonomies]
tags = ["database", "til"]
categories = ["Today I Learned", "PostgreSQL"]


[extra]
lang = "en"
toc = false

+++

The following snippet finds where the PostgreSQL database directory is located.

```bash
psql -U postgres -c 'SHOW data_directory';
```