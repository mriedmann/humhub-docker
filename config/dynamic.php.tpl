<?php return array (
  'components' =>
  array (
    'db' =>
    array (
      'class' => 'yii\\db\\Connection',
      'dsn' => 'mysql:host=%%HUMHUB_DB_HOST%%;dbname=%%HUMHUB_DB_NAME%%',
      'username' => '%%HUMHUB_DB_USER%%',
      'password' => '%%HUMHUB_DB_PASSWORD%%',
      'charset' => 'utf8',
    ),
    'user' =>
    array (
    ),
    'mailer' =>
    array (
      'transport' =>
      array (
        'class' => 'Swift_MailTransport',
      ),
      'view' =>
      array (
        'theme' =>
        array (
          'name' => 'HumHub',
          'basePath' => '/var/www/localhost/htdocs/themes/HumHub',
          'publishResources' => false,
        ),
      ),
    ),
    'cache' =>
    array (
      'class' => 'yii\\caching\\FileCache',
      'keyPrefix' => 'humhub',
    ),
    'view' =>
    array (
      'theme' =>
      array (
        'name' => 'HumHub',
        'basePath' => '/var/www/localhost/htdocs/themes/HumHub',
        'publishResources' => false,
      ),
    ),
  ),
  'params' =>
  array (
    'installer' =>
    array (
      'db' =>
      array (
        'installer_hostname' => '%%HUMHUB_DB_HOST%%',
        'installer_database' => '%%HUMHUB_DB_NAME%%',
      ),
    ),
    'config_created_at' => 1514918914,
    'horImageScrollOnMobile' => '1',
    'databaseInstalled' => true,
    'installed' => false,
  ),
  'name' => '%%HUMHUB_NAME%%',
  'language' => '%%HUMHUB_LANG%%',
);