local models = Config.models

Citizen.CreateThread(function()
    local options = {
        {
            name = 'ox:option9',
            icon = 'fa-solid fa-microphone',
            label = 'Utiliser le micro',
            distance = 1,
            onSelect = function(data)
                createMicPoly(GetEntityModel(data.entity))
            end
        }
    }
    exports.ox_target:addModel(models, options)
end)

