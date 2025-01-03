if Config.framework == 'none' then
    local megaphoneEnabled = false

    RegisterCommand('megaphone', function()
        megaphoneEnabled = not megaphoneEnabled
        toggleMegaphone('handHeld', megaphoneEnabled)
    end)
elseif Config.framework == 'qb' or 'qbox' then
    RegisterNetEvent('fd-megaphones:client:usemegaphone', function()
        megaphoneEnabled = not megaphoneEnabled
        toggleMegaphone('handHeld', megaphoneEnabled)
    end)
end


