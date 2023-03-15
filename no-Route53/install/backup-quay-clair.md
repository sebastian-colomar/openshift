### How to backup Quay:

```
oc exec -it $( oc get pod -n quay-enterprise | awk /quay-postgresql/'{ print $1 }' ) -n quay-enterprise sh
sh-4.4$
database=quay
date=$( date +%F_%H%M%S )
dir=/var/lib/pgsql/data/backup/postgres
mkdir -p $dir/$date
pg_dump $database > $dir/$date/$database.sql
pg_dumpall > $dir/$date/$database-all.sql
tar -C $dir -cf $dir/$database-$date.tar $date
gzip $dir/$database-$date.tar
rm -rf $dir/$date


```

### How to backup Clair:

```
oc exec -it $( oc get pod -n quay-enterprise | awk /clair-postgresql/'{ print $1 }' ) -n quay-enterprise sh
sh-4.4$
database=clair
date=$( date +%F_%H%M%S )
dir=/var/lib/pgsql/data/backup/postgres
mkdir -p $dir/$date
pg_dump $database > $dir/$date/$database.sql
pg_dumpall > $dir/$date/$database-all.sql
tar -C $dir -cf $dir/$database-$date.tar $date
gzip $dir/$database-$date.tar
rm -rf $dir/$date


```
