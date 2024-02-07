## Backup & Restore using PGBackrest

#### Introduction to pgBackRest

While looking to expore options for postgresql backup, I looked into several options, `wal-g`,`pg_dump`, there were a magnitue of options available. I want to look into a simple option that allows me to backup the content on a standby server so that the primary would not be overloaded when the backup process is taking place. In all obviousness, I choose `pgbackrest`.

####PG Backrest Vocabulary
Backup: 
Differential Backup: 
Incremental Backup: 
Stanza: 
Host: 
pgbackrest.conf: 

###Create your first backup 

After installing `pgbackrest` for your respective OS, is to look into the `pgbackrest.conf` file. Let's expore this file.

```bash
[global]
repo1-path=/var/lib/pgbackrest
log-level-console=info
log-level-file=debug

[main]
pg1-path=/var/lib/postgresql/16/main
pg1-port=5432
```

### Senarious
- Backup/Restore via S3
- Backup/Restore via Another Server
- Backup/Restore via Standby Server
- 


Building docker images with the flag `--platform linux/amd64` allows you to create x86 images using docker

Which platform am I on?

```
> gcc -dumpmachine
arm64-apple-darwin23.2.0
```

####Let's run an image to build in the x86 world

```bash
> docker run -it --platform=linux/amd64 gcc:13.2.0 /bin/bash
(inside docker container)> gcc -dumpmachine
x86_64-linux-gnu
```

#### When to use this?

This is helpful to build cross platform images. i.e. in Elixir you can create a binary file with `mix release` however it only targets the current platform target triple. As my server runs on `linux/amd64` I would have to build the code again rather than just copying over the binary file. Hence, I use this script to build the binary for the x86 platform and copy over the binary file only.












