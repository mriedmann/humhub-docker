# Alpine-based PHP-FPM and NGINX HumHub docker-container

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/e2c25ed0c4ce479aa9a97be05d1d5b20)](https://app.codacy.com/app/mriedmann/humhub-docker?utm_source=github.com&utm_medium=referral&utm_content=mriedmann/humhub-docker&utm_campaign=Badge_Grade_Dashboard)

![Docker Image CI](https://github.com/mriedmann/humhub-docker/workflows/Docker%20Image%20CI/badge.svg)

[HumHub](https://github.com/humhub/humhub) is a feature rich and highly flexible OpenSource Social Network Kit written in PHP.
This container provides a quick, flexible and lightweight way to set up a proof-of-concept for detailed evaluation.
Using this in production is possible, but please note that there is currently no official support available for this kind of setup.

## Versions

- [![dockerimage badge (latest)](https://images.microbadger.com/badges/version/mriedmann/humhub:latest.svg)](https://microbadger.com/images/mriedmann/humhub:latest "Get your own version badge on microbadger.com") `latest` : unstable master build (use with caution, might be unstable!)
- [![dockerimage badge (1.5.x)](https://images.microbadger.com/badges/version/mriedmann/humhub:1.5.2.svg)](https://microbadger.com/images/mriedmann/humhub:1.5.2 "Get your own version badge on microbadger.com") `1.5.2` : latest legacy release
- [![dockerimage badge (1.6.x)](https://images.microbadger.com/badges/version/mriedmann/humhub:1.6.2.svg)](https://microbadger.com/images/mriedmann/humhub:1.6.2 "Get your own version badge on microbadger.com") `1.6.2` : latest stable release (recommended)
- [![dockerimage badge (experimental)](https://images.microbadger.com/badges/version/mriedmann/humhub:experimental.svg)](https://microbadger.com/images/mriedmann/humhub:experimental "Get your own version badge on microbadger.com") `experimental` : test build (testing only)

## Quickstart

No database integrated. For persistency look at the Compose-File example.

1. `docker run -d --name humhub_db -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=humhub mariadb:10.2`
2. `docker run -d --name humhub -p 80:80 --link humhub_db:db mriedmann/humhub:1.2.0`
3. open <http://localhost/> in browser
4. complete the installation wizard (use `db` as database hostname and `humhub` as database name)
5. finished

## Composer File Example

```Dockerfile
version: '3.1'
services:
  humhub:
    image: mriedmann/humhub:1.6.2
    links:
      - "db:db"
    ports:
      - "8080:80"
    volumes:
      - "config:/var/www/localhost/htdocs/protected/config"
      - "uploads:/var/www/localhost/htdocs/uploads"
      - "modules:/var/www/localhost/htdocs/protected/modules"
    environment:
      HUMHUB_DB_USER: humhub
      HUMHUB_DB_PASSWORD: humhub

  db:
    image: mariadb:10.2
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: humhub
      MYSQL_USER: humhub
      MYSQL_PASSWORD: humhub

volumes:
  config: {}
  uploads: {}
  modules: {}
```

> In some situations (e.g. with [podman-compose](https://github.com/containers/podman-compose)) you have to run compose `up` twice to give it some time to create the named volumes.

## Advanced Config

This container supports some further options which can be configured via environment variables. Look at the [docker-compose.yml](https://github.com/mriedmann/humhub-docker/blob/master/docker-compose.yml) for some inspiration.

### `HUMHUB_DB_USER` & `HUMHUB_DB_PASSWORD`

**default: `""`**

This username and password will be used to connect to the database. Please do not set the HUMHUB_DB_PASSWORD without HUMHUB_DB_USER to avoid problems. If this is not set, the visual installer will show up at the first startup.

### `HUMHUB_DB_NAME`

**default: `humhub`**

Defines the name of the database where HumHub is installed.

### `HUMHUB_DB_HOST`

**default: `db`**

Defines the mysql/mariadb-database-host. If you use the `--link` argument please specify the name of the link as host or use `db` as linkname ( `--link <container>:db` ).

### `HUMHUB_AUTO_INSTALL`

**default: `false`**

If this and `HUMHUB_DB_USER` are set an automated installation will run during the first startup. This feature utilities a hidden installer-feature used for integration testing ( [see code file](https://github.com/humhub/humhub/blob/master/protected/humhub/modules/installer/commands/InstallController.php) ).

### `HUMHUB_PROTO` & `HUMHUB_HOST`

**default: `http`, `localhost`**

If these are defined during auto-installation, HumHub will be installed and configured to use urls with those details. (i.e. If they are set as `HUMHUB_PROTO=https`, `HUMHUB_HOST=example.com`, HumHub will be installed and configured so that the base url is `https://example.com/`. Leaving these as default will result in HumHub being installed and configured to be at `http://localhost/`.

### `HUMHUB_ADMIN_LOGIN` & `HUMHUB_ADMIN_EMAIL` & `HUMHUB_ADMIN_PASSWORD`

**default: `admin`, `humhub@example.com`, `test`**

If these are defined during auto-installation, HumHub admin will be created with those credentials.

### `INTEGRITY_CHECK`

**default: `1`**

This can be set to `"false"` to disable the startup integrity check. Use with caution!

### `WAIT_FOR_DB`

**default: `1`**

Can be used to let the startup fail if the db host is unavailable. To disable this, set it to `"false"`. Can be useful if an external db-host is used, avoid when using a linked container.

### `SET_PJAX`

**default: `1`**

PJAX is a jQuery plugin that uses AJAX and pushState to deliver a fast browsing experience with real permalinks, page titles, and a working back button. ([ref](https://github.com/yiisoft/jquery-pjax)) This library is known to cause problems with some browsers during installation. This container starts with PJAX disabled to improve the installation reliability. If this is set (default), PJAX is **enabled** during the **second** startup. Set this to `"false"` to permanently disable PJAX. Please note that changing this after container-creation has no effect on this behavior.

### Mailer Config

It is possible to configure HumHub email settings using the following environment variables:

```plaintext
HUMHUB_MAILER_SYSTEM_EMAIL_ADDRESS    [noreply@example.com]
HUMHUB_MAILER_SYSTEM_EMAIL_NAME       [HumHub]
HUMHUB_MAILER_TRANSPORT_TYPE          [php]
HUMHUB_MAILER_HOSTNAME                []
HUMHUB_MAILER_PORT                    []
HUMHUB_MAILER_USERNAME                []
HUMHUB_MAILER_PASSWORD                []
HUMHUB_MAILER_ENCRYPTION              []
HUMHUB_MAILER_ALLOW_SELF_SIGNED_CERTS []
```

### LDAP Config

It is possible to configure HumHub LDAP authentication settings using the following environment variables:

```plaintext
HUMHUB_LDAP_ENABLED            [0]
HUMHUB_LDAP_HOSTNAME           []
HUMHUB_LDAP_PORT               []
HUMHUB_LDAP_ENCRYPTION         []
HUMHUB_LDAP_USERNAME           []
HUMHUB_LDAP_PASSWORD           []
HUMHUB_LDAP_BASE_DN            []
HUMHUB_LDAP_LOGIN_FILTER       []
HUMHUB_LDAP_USER_FILTER        []
HUMHUB_LDAP_USERNAME_ATTRIBUTE []
HUMHUB_LDAP_EMAIL_ATTRIBUTE    []
HUMHUB_LDAP_ID_ATTRIBUTE       []
HUMHUB_LDAP_REFRESH_USERS      []
```

### PHP Config

It is also possible to change some php-config-settings. This comes in handy if you have to scale this container vertically.

Following environment variables can be used (default values in angle brackets):

```plaintext
PHP_POST_MAX_SIZE       [16M]
PHP_UPLOAD_MAX_FILESIZE [10M]
PHP_MAX_EXECUTION_TIME  [60]
PHP_MEMORY_LIMIT        [1G]
PHP_TIMEZONE            [UTC]
```

### NGINX Config

Following variables can be used to configure the embedded Nginx. The config-file gets rewritten on every container startup and is not persisted. Avoid changing it by hand.

```plaintext
NGINX_CLIENT_MAX_BODY_SIZE [10m]
NGINX_KEEPALIVE_TIMEOUT    [65]
```

## Contribution

Please use the issues-page for bugs or suggestions. Pull-requests are highly welcomed.

## Special Thanks

Special thanks go to following contributors for there incredible work on this image:

- @madmath03
- @ArchBlood
- @pascalberger
- @bkmeneguello

And also to @luke- and his team for providing, building and maintaining HumHub.
