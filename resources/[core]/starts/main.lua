if MySQL.ready then
    MySQL.ready(function()
        ExecuteCommand('exec resources.cfg')
    end)
else
    print("Erreur : Vous ne pouvez pas lancé les scripts!")
end