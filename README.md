# Alpine-based PHP-FPM and NGINX HumHub docker-container
[![Build Status](https://travis-ci.org/mriedmann/humhub-docker.svg?branch=master)](https://travis-ci.org/mriedmann/humhub-docker)

[HumHub](https://github.com/humhub/humhub) is a feature rich and highly flexible OpenSource Social Network Kit written in PHP.
This container provides a quick, flexible and lightwight way to set-up a proof-of-concept for detailed evaluation. Using this in production is possible, but not recommended. 

## Versions

* [![](https://images.microbadger.com/badges/version/mriedmann/humhub:latest.svg)](https://microbadger.com/images/mriedmann/humhub:latest "Get your own version badge on microbadger.com") `latest`:  unstable master build (use with caution! might be unstable) 
* [![](https://images.microbadger.com/badges/version/mriedmann/humhub:1.3.7.svg)](https://microbadger.com/images/mriedmann/humhub:1.2.8 "Get your own version badge on microbadger.com") `1.3.7`: latest stable release (recommended) 
* [![](https://images.microbadger.com/badges/version/mriedmann/humhub:1.0.1.svg)](https://microbadger.com/images/mriedmann/humhub:1.0.1 "Get your own version badge on microbadger.com") `1.0.1`: latest 1.0.x release (not recommended) 
* [![](https://images.microbadger.com/badges/version/mriedmann/humhub:experimental.svg)](https://microbadger.com/images/mriedmann/humhub:experimental "Get your own version badge on microbadger.com") `experimental`: test build (testing only) 

## Quickstart

No database integrated. For persistency look at the Compose-File example.

1. `docker run -d --name humhub_db -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=humhub mariadb:10.2`
1. `docker run -d --name humhub -p 80:80 --link humhub_db:db mriedmann/humhub:1.2.0`
1. open http://localhost/ in browser
1. complete the installation wizard (use `db` as database hostname and `humhub` as database name)
1. finished

## Known issues

* The installation wizard is sometimes not working with chrome. Workaround: Use other browser for installing. 

## Composer File Example

```
version: '3.1'
services:
  humhub:
    build: .
    links:
      - "db:db"
    ports:
      - "80:80"
    volumes:
      - "_data/config:/var/www/localhost/htdocs/protected/config"
      - "_data/uploads:/var/www/localhost/htdocs/protected/uploads"
  db:
    image: mariadb:10.2
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: humhub
```

## Advanced Config
This container supports some further options which can be configured via environment variables. Look at the [docker-compose.yml](https://github.com/mriedmann/humhub-docker/blob/master/docker-compose.yml) for some inspiration.

### `HUMHUB_DB_USER` & `HUMHUB_DB_PASSWORD`
**default: `""`**
  
This username and password will be used to connect to the database. Please do not set the HUMHUB_DB_PASSWORD without HUMHUB_DB_USER to avoid problems. If this is not set, the visual installer will show up at the first startup. 
  
### `HUMHUB_DB_NAME`
**default: `humhub`**

Defines the name of the database where humhub is installed.

### `HUMHUB_DB_HOST`
**default: `db`**

Defines the mysql/mariadb-database-host. If you use the `--link` argument please specify the name of the link as host or use `db` as linkname (`--link <container>:db`).

### `HUMHUB_AUTO_INSTALL`
**default: `false`**

If this and `HUMHUB_DB_USER` are set an autoinstallation will run during the first startup. The default login is `admin` with password `test`. This feature utilises a hidden installer-feature used for integration testing ( [see code file](https://github.com/humhub/humhub/blob/master/protected/humhub/modules/installer/commands/InstallController.php) ).

### `INTEGRITY_CHECK`
**default: `1`**

This can be set to `"false"` to disabled the startup integrity check. Use with caution!

### `WAIT_FOR_DB`
**default: `1`**

Can be used to let the startup fail if the db host is unavailable. To disable this, set it to `"false"`. Can be useful if an external db-host is used, avoid when using a linked container.

### `SET_PJAX`
**default: `1`**

PJAX is a jQuery plugin that uses ajax and pushState to deliver a fast browsing experience with real permalinks, page titles, and a working back button. ([ref](https://github.com/yiisoft/jquery-pjax)) This library is known to cause problems with some browsers during  installation. This container starts with PJAX disabled to improve the installation reliability. If this is set (default), PJAX is **enabled** during the **second** startup. Set this to `"false"` to permanently disable PJAX. Please note that changing this after container-creation has no effect on this behavior.

## Contribution

Please use the issues-page for bugs or suggestions. Pull-requests are highly welcomed.
