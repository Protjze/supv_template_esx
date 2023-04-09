Config = {}

Config.Locale = GetConvar('esx:locale', 'en')
Config.EnableESXIdentity = true
Config.MaxSalary = 3500

Config.DoubleJob = ESX.GetConfig().DoubleJob.enable == true and ESX.GetConfig().DoubleJob or false