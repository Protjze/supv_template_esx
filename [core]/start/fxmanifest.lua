fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

server_only 'yes'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'main.lua'
}

dependencies {
    '/server:6116',
	'/onesync',
    'oxmysql',
}