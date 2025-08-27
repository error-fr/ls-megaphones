fx_version 'cerulean'
game 'gta5'

name 'fd-megaphones'
author 'pen'
description 'A simple free megaphone resource for FiveM'
repository 'https://github.com/FD-Scripts/fd-megaphones'
version '1.0.6'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/framework.lua',
    'client/functions.lua',
    'client/megaphone.lua',
    'client/microphones.lua'
}

server_scripts {
    'server/framework.lua',
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'pma-voice'
}