# Build

## Create Database

```bash
sqlite3 "ami.db" < create.sql
```

## Import Images

```bash
mkdir -p "./import/"
jq -r '.[].owner' "operating-systems.json" | while read -r MY_OWNER_ID; do
	aws ec2 describe-images --owner "$MY_OWNER_ID" --region "us-east-1" --output json > "./import/$MY_OWNER_ID.json"
	perl ami.pl < "./import/$MY_OWNER_ID.json"
done
```

## Websites

```bash
perl web.pl
```

Run:

```bash
plackup --host "127.0.0.1" --port "8080"
```

## SQL Snippets

Names:

```sql
SELECT COUNT("imageId") AS imageCount, MAX("imageId"), "name" FROM images WHERE "state" = "available" GROUP BY "name" ORDER BY imageCount DESC;
```

Platform Details:

```sql
SELECT COUNT("imageId") AS imageCount, "platformDetails" FROM images WHERE "state" = "available" GROUP BY "platformDetails" ORDER BY imageCount DESC;
```

Architectures:

```sql
SELECT COUNT("imageId") AS imageCount, "architecture" FROM images WHERE "state" = "available" GROUP BY "architecture" ORDER BY imageCount DESC;
```

States:

```sql
SELECT COUNT("imageId") AS imageCount, "imageType" FROM images GROUP BY "imageType" ORDER BY imageCount DESC;
``