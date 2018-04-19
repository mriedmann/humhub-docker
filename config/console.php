<?php 

return [
    'controllerMap' => [
        'installer' => 'humhub\modules\installer\commands\InstallController'
],
'components' => [
    'urlManager' => [
        'baseUrl' => 'http://localhost:80',
        'hostInfo' => 'http://localhost:80',
    ]
]];