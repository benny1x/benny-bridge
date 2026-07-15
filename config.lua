Config = {}

Config.Debug = true

Config.Framework = 'auto'

-- Inventory provider:
-- auto | ox | qs | codem | tgiann | core | ps | lj | qb | none
Config.Inventory = 'auto'

-- Target provider:
-- auto | ox | qb | qtarget | none
Config.Target = 'auto'

-- Dispatch provider:
-- auto | none | cd_dispatch | ps-dispatch | core_dispatch | qs-dispatch
-- rcore_dispatch | codem-dispatch | origen_police | lb-tablet | tk_dispatch
Config.Dispatch = 'auto'

Config.DispatchJobs = {
    'police',
}


Config.Medical = {
    Provider = 'auto',
    CustomReviveEvent = '', -- client event name if Provider = 'custom'
    CustomReviveExportResource = '', -- e.g. 'my_ambulance'
    CustomReviveExportName = '', -- e.g. 'RevivePlayer'
}

-- Compare installed Benny Scripts against https://github.com/benny1x/version-repo
Config.VersionCheck = true

