+++

title = "Find PostgreSQL Config Location"
date = "2024-01-18"
draft = false

[taxonomies]
tags = ["database", "til"]
categories = ["Today I Learned", "PostgreSQL"]


[extra]
lang = "en"
toc = false

+++

The following snippet finds where the PostgreSQL config file is located.

```bash
psql -U postgres -c 'SHOW config_file';
```