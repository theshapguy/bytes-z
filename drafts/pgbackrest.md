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














