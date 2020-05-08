-- Resource Metadata
fx_version 'bodacious'
games { 'gta5' }



-- What to run
client_scripts {
    'client.lua'
}
server_script 'server.lua'



server_exports {
'getIdentity'
}

server_exports {
'getIdentifierByPhoneNumber'
}