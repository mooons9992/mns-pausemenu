fx_version 'cerulean'
game 'gta5'

name 'mns-pausemenu'
author 'MoonSystems'
description 'Advanced Pause Menu for QBCore'
version '2.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/*.lua'
}

client_scripts {
    'client/config_cl.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',  -- Updated from mysql-async to oxmysql
    'server/*.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/css/*.css',
    'ui/js/*.js',
    'ui/fonts/*.ttf',
    'ui/fonts/*.woff',
    'ui/fonts/*.woff2',
    'ui/images/*.png',
    'ui/images/*.jpg',
    'ui/images/*.svg',
    'ui/images/*.webp',
}

dependencies {
    'qb-core',
    'ox_lib'
}

escrow_ignore {
    'config.lua',
    'client/config_cl.lua',
    'shared/*.lua'
}