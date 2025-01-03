local models = Config.models

Citizen.CreateThread(function()
    local options = {
        {
            name = 'ox:option9',
            icon = 'fa-solid fa-microphone',
            label = 'Use Microphone',
            distance = 1,
            onSelect = function(data)
                createMicPoly(GetEntityModel(data.entity))
            end
        }
    }
    exports.ox_target:addModel(models, options)
end)

