-- This is required for TSFAC to run, please dont remove!
shared_script '@TSF_AC/shared/resource.lua'

fx_version('cerulean')
game('gta5')
lua54('yes')

name('benny-bridge')
author('Benny Scripts')
version('1.2.0')
description('Shared framework + inventory + target + shop bridge for Benny Scripts')

shared_scripts({
    'config.lua',
    'shared/debug.lua',
})

client_scripts({
    'client/modules/target/target.lua',
    'client/modules/inventory/inventory.lua',
    'client/main.lua',
    'client/modules/dispatch/dispatch.lua',
    'client/modules/medical/medical.lua',
})

server_scripts({
    'server/modules/core/utils.lua',
    'server/modules/core/version.lua',
    'server/modules/framework/providers/esx.lua',
    'server/modules/framework/providers/qb.lua',
    'server/modules/framework/providers/qbx.lua',
    'server/modules/framework/providers/ox.lua',
    'server/modules/framework/providers/standalone.lua',
    'server/modules/framework/init.lua',
    'server/modules/inventory/providers/_items_util.lua',
    'server/modules/inventory/providers/ox.lua',
    'server/modules/inventory/providers/qs.lua',
    'server/modules/inventory/providers/codem.lua',
    'server/modules/inventory/providers/tgiann.lua',
    'server/modules/inventory/providers/core.lua',
    'server/modules/inventory/providers/ps.lua',
    'server/modules/inventory/providers/lj.lua',
    'server/modules/inventory/providers/qb.lua',
    'server/modules/inventory/providers/none.lua',
    'server/modules/inventory/init.lua',
    'server/modules/inventory/shops.lua',
    'server/modules/inventory/useables.lua',
    'server/modules/dispatch/dispatch.lua',
    'server/modules/medical/medical.lua',
    'server/main.lua',
})

escrow_ignore({
    'config.lua',
    'shared/**/*',
    'server/modules/**/*',
    'client/**/*',
})
