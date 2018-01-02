# Alpine-based PHP-FPM and NGINX HumHub docker-container

[HumHub](https://github.com/humhub/humhub) is a feature rich and highly flexible OpenSource Social Network Kit written in PHP.
This container provides a quick, flexible and lightwight way to set-up a proof-of-concept for detailed evaluation. Using this in production is possible, but not recommended. 

## Versions

* `latest`:  unstable master build (use with caution! might be unstable)
* `1.2.4`: latest stable release (recommended)
* `1.0.1`: latest 1.0.x release (not recommended)
* `experimental`: test build (testing only) 

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

## Contribution

Please use the issues-page for bugs or suggestions. Pull-requests are highly welcomed.
