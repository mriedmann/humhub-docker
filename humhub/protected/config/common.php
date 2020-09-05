<?php
/**
 * This file provides to overwrite the default HumHub / Yii configuration by your local common (Console and Web) environments
 * @see http://www.yiiframework.com/doc-2.0/guide-concept-configurations.html
 * @see http://docs.humhub.org/admin-installation-configuration.html
 * @see http://docs.humhub.org/dev-environment.html
 */
return [
	'params' => [
        'enablePjax' => false
    ],
    'components' => [
        'urlManager' => [
            'showScriptName' => false,
            'enablePrettyUrl' => true,
        ],
        'redis' => [
            'class' => 'yii\redis\Connection',
            'hostname' => 'redis',
            'port' => 6379,
            'database' => 0,
            //'password' => 'redis_password',
        ],
        'cache' => [
            'class' => 'yii\redis\Cache',
        ],
        'queue' => [
            'class' => 'humhub\modules\queue\driver\Redis',
        ],
        //'push' => [
        //    'class' => 'humhub\modules\live\driver\Push',
        //    'url' => '/socket.io',
        //    'jwtKey' => 'somethingrandomlygenerated',
        //],
    ]
];
