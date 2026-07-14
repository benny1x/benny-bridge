Config = {}

Config.Debug = false

Config.Framework = 'auto'
Config.Inventory = 'auto'
Config.Target = 'auto'
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
