# gcloud-datomic-backup

A tool that helps to do Datomic backups on Google Cloud.

There are several obstacles to overcome, if you like to do a backup of
your Datomic database that is running on Google Cloud:

- It is not allowed to redistribute Datomic Pro, which includes the
  Datomic backup tool.

- Datomic only supports to backup to the file system or AWS S3, which
  makes incremental backups on Google Cloud difficult.

- The backup process should not overload the database that is used as
  Datomic storage.

- Access to Google Cloud SQL is often only possible via Cloud SQL
  Proxy


This tool tries to overcome these obstacles. The `bin/build.clj`
script builds a Docker container that includes all necessary tools to
execute the backup:

- The Docker image should be pushed to your private container
  registry (like http://gcr.io/), so that you do not redistribute
  Datomic Pro to a public Docker repository.

- [gcsfuse](https://github.com/GoogleCloudPlatform/gcsfuse/) is used
  to mount the Google Cloud Storage bucket to the local file
  system. Thereby it is possible to do incremental Datomic backups in
  combination with Google Cloud storage.

- `-Ddatomic.backupPaceMsec=5` is used as option to slow down the
  Datomic `backup-db` process and decrease the load on the storage
  database.

- [Cloud SQL proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy)
  is included in the image to allow the connection to Google Cloud SQL.

## Building the Docker image

Clone this Git repository and create a `config.edn` in top-level folder:

```clojure
{:datomic-credentials "%%email:password%%"
 :datomic-version "0.9.5561"
 :container-registry "eu.gcr.io/%%gcloud-project-id%%"
 :extra-libs ["https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.39/mysql-connector-java-5.1.39.jar"]}
```

- Replace `%%email:password%%` and fill in your email and password that
you use to log into
[https://my.datomic.com/](https://my.datomic.com/).

- Replace `%%gcloud-project-id%%` with the project-id of your Google
  Cloud project. Replace the complete `:container-registry` value, if
  you are using another Docker image repo than gcr.io (or adapt the
  region).

- Fill in the Datomic version you are using (`:datomic-version`).

- The `:extra-libs` can contain a list of URLs to jar files that
  should be copied to the `lib` folder of the Datomic folder. This is
  for example necessary, if you are using MySQL as storage database.


Invoke `bin/build.clj` and wait until it prints out the 'Docker tag:'
of the image.


## Usage

TODO
