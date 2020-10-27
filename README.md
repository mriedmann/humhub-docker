# Alpine-based PHP-FPM and NGINX HumHub docker-container

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/e2c25ed0c4ce479aa9a97be05d1d5b20)](https://app.codacy.com/app/mriedmann/humhub-docker?utm_source=github.com&utm_medium=referral&utm_content=mriedmann/humhub-docker&utm_campaign=Badge_Grade_Dashboard)

![Docker Image CI](https://github.com/mriedmann/humhub-docker/workflows/Docker%20Image%20CI/badge.svg)

> :warning: **New Releases**: We are currently working on a new release pipeline to support multi-version and multi-variant releases! This should not affect the state of the current latest tag. Please feel free to open an issue if you are experiencing any problems.

[HumHub](https://github.com/humhub/humhub) is a feature rich and highly flexible OpenSource Social Network Kit written in PHP.
This container provides a quick, flexible and lightweight way to set up a proof-of-concept for detailed evaluation.
Using this in production is possible, but please note that there is currently no official support available for this kind of setup.

## Versions

This project provides different images and tags for different purposes. For evaluation use `humhub:stable`, for production consider using the newest minor-version tag (e.g. `humhub:1.6`).

- `latest` : unstable master build (not recommended for production; use with caution, might be unstable!)
- Minor (e.g `1.6`): Always points to latest release of given minor version. (Recommended)
- Build (e.g `1.6.3`): Always points to latest release of given build. Very stable but might be outdated.
- `stable`: Always points to latest stable version. Updates include minor-version changes which can include db-schema changes (higher risk).

### Variants

There are 3 different variants of this image. Use the unspecific tag (e.g. `humhub:1.6`) if you what a running installation as fast as possible. If plan to build some kind of hosted solution, have a look at `docker-compose.prod.yml` to understand how the variant images can be used.

- default / all-in-one (e.g. `humhub:1.6`): Multi-service image (nginx + php-fpm). Use this if you are not sure what you need.
- `nginx` (e.g. `humhub:1.6-nginx`): Only static files and nginx proxy config without php.
- `phponly` (e.g. `humhub:1.6-phponly`): HumHub sources bundled with php-fpm. Needs a fcgi application-server to be able to deliver http.

### Matrix

| Version  | Status       | AllInOne                                                                                                                                                           | Nginx                                                                                                                                                                          | PHP-Only                                                                                                                                                                           |
| -------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `1.4`    | EndOfLife    | [![dockerimage badge (1.4)](https://images.microbadger.com/badges/version/mriedmann/humhub:1.4.svg)](https://microbadger.com/images/mriedmann/humhub:1.4)          | [![dockerimage badge (1.4)](https://images.microbadger.com/badges/version/mriedmann/humhub:1.4-nginx.svg)](https://microbadger.com/images/mriedmann/humhub:1.4-nginx)          | [![dockerimage badge (1.4)](https://images.microbadger.com/badges/version/mriedmann/humhub:1.4-phponly.svg)](https://microbadger.com/images/mriedmann/humhub:1.4-phponly)          |
| `1.5`    | Deprecated   | [![dockerimage badge (1.5)](https://images.microbadger.com/badges/version/mriedmann/humhub:1.5.svg)](https://microbadger.com/images/mriedmann/humhub:1.5)          | [![dockerimage badge (1.5)](https://images.microbadger.com/badges/version/mriedmann/humhub:1.5-nginx.svg)](https://microbadger.com/images/mriedmann/humhub:1.5-nginx)          | [![dockerimage badge (1.5)](https://images.microbadger.com/badges/version/mriedmann/humhub:1.5-phponly.svg)](https://microbadger.com/images/mriedmann/humhub:1.5-phponly)          |
| `1.6`    | Stable       | [![dockerimage badge (1.6)](https://images.microbadger.com/badges/version/mriedmann/humhub:1.6.svg)](https://microbadger.com/images/mriedmann/humhub:1.6)          | [![dockerimage badge (1.6)](https://images.microbadger.com/badges/version/mriedmann/humhub:1.6-nginx.svg)](https://microbadger.com/images/mriedmann/humhub:1.6-nginx)          | [![dockerimage badge (1.6)](https://images.microbadger.com/badges/version/mriedmann/humhub:1.6-phponly.svg)](https://microbadger.com/images/mriedmann/humhub:1.6-phponly)          |
| `stable` | Stable       | [![dockerimage badge (stable)](https://images.microbadger.com/badges/version/mriedmann/humhub:stable.svg)](https://microbadger.com/images/mriedmann/humhub:stable) | [![dockerimage badge (stable)](https://images.microbadger.com/badges/version/mriedmann/humhub:stable-nginx.svg)](https://microbadger.com/images/mriedmann/humhub:stable-nginx) | [![dockerimage badge (stable)](https://images.microbadger.com/badges/version/mriedmann/humhub:stable-phponly.svg)](https://microbadger.com/images/mriedmann/humhub:stable-phponly) |
| `latest` | Experimental | [![dockerimage badge (latest)](https://images.microbadger.com/badges/version/mriedmann/humhub:latest.svg)](https://microbadger.com/images/mriedmann/humhub:latest) | [![dockerimage badge (latest)](https://images.microbadger.com/badges/version/mriedmann/humhub:latest-nginx.svg)](https://microbadger.com/images/mriedmann/humhub:latest-nginx) | [![dockerimage badge (latest)](https://images.microbadger.com/badges/version/mriedmann/humhub:latest-phponly.svg)](https://microbadger.com/images/mriedmann/humhub:latest-phponly) |

## Quickstart

No database integrated. For persistency look at the Compose-File example.

1. `docker run -d --name humhub_db -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=humhub mariadb:10.2`
2. `docker run -d --name humhub -p 80:80 --link humhub_db:db mriedmann/humhub:stable`
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

### Database Config

To avoid the visual installer at the first startup, set the HUMHUB_DB_PASSWORD **and** HUMHUB_DB_USER.
If you use the `--link` argument please specify the name of the link as host (via `HUMHUB_DB_HOST`) or use `db` as linkname ( `--link <container>:db` ).

```plaintext
HUMHUB_DB_USER     []
HUMHUB_DB_PASSWORD []
HUMHUB_DB_NAME     [humhub]
HUMHUB_DB_HOST     [db]
```

### Autoinstall Config

```plaintext
HUMHUB_AUTO_INSTALL [false]
```

If this and `HUMHUB_DB_USER` are set an automated installation will run during the first startup. This feature utilities a hidden installer-feature used for integration testing ( [see code file](https://github.com/humhub/humhub/blob/master/protected/humhub/modules/installer/commands/InstallController.php) ).

```plaintext
HUMHUB_PROTO [http]
HUMHUB_HOST  [localhost]
```

If these are defined during auto-installation, HumHub will be installed and configured to use urls with those details. (i.e. If they are set as `HUMHUB_PROTO=https`, `HUMHUB_HOST=example.com`, HumHub will be installed and configured so that the base url is `https://example.com/`. Leaving these as default will result in HumHub being installed and configured to be at `http://localhost/`.

```plaintext
HUMHUB_ADMIN_LOGIN    [admin]
HUMHUB_ADMIN_EMAIL    [humhub@example.com]
HUMHUB_ADMIN_PASSWORD [test]
```

If these are defined during auto-installation, HumHub admin will be created with those credentials.

### Startup Config

```plaintext
INTEGRITY_CHECK [1]
```

This can be set to `"false"` to disable the startup integrity check. Use with caution!

```plaintext
WAIT_FOR_DB [1]
```

Can be used to let the startup fail if the db host is unavailable. To disable this, set it to `"false"`. Can be useful if an external db-host is used, avoid when using a linked container.

```plaintext
SET_PJAX [1]
```

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
HUMHUB_LDAP_ENABLED                               [0]
HUMHUB_LDAP_HOSTNAME                              []
HUMHUB_LDAP_PORT                                  []
HUMHUB_LDAP_ENCRYPTION                            []
HUMHUB_LDAP_USERNAME                              []
HUMHUB_LDAP_PASSWORD                              []
HUMHUB_LDAP_BASE_DN                               []
HUMHUB_LDAP_LOGIN_FILTER                          []
HUMHUB_LDAP_USER_FILTER                           []
HUMHUB_LDAP_USERNAME_ATTRIBUTE                    []
HUMHUB_LDAP_EMAIL_ATTRIBUTE                       []
HUMHUB_LDAP_ID_ATTRIBUTE                          []
HUMHUB_LDAP_REFRESH_USERS                         []
HUMHUB_ADVANCED_LDAP_THUMBNAIL_SYNC_PROPERTY      [thumbnailphoto]
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
