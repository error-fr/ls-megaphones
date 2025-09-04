function setProximity(distance)
    exports["pma-voice"]:overrideProximityRange(distance, true)
    printDebug('[Proximity] Changed To ' .. distance)
end

function toggleMegaphone(micType, status)
    local srcSrv = GetPlayerServerId(PlayerId())

    local proximity = Config.proximityDistances[micType]

    if proximity and status then
        setProximity(proximity)
        MumbleSetAudioInputIntent(`music`)

        if Config.volume ~= -1.0 then
            MumbleSetVolumeOverrideByServerId( srcSrv, Config.volume )
        end
        
        notify('Mégaphone sortie')

        if micType ~= 'stage' then
            TriggerServerEvent('fd-megaphones:server:addsubmix', srcSrv)
        end
    else
        exports["pma-voice"]:clearProximityOverride()
        MumbleSetAudioInputIntent(`speech`)
        notify('Mégaphone rangé')
        if Config.volume ~= -1.0 then
            MumbleSetVolumeOverrideByServerId( srcSrv, -1.0 )
        end
        TriggerServerEvent('fd-megaphones:server:removesubmix', srcSrv)
        printDebug('[Megaphone] Proximity reset to default')
    end

    if micType == 'handHeld' then
        handleMegaphoneAnimation(status)
    end
end

function createMicPoly(model)
    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)
    local micEntity = GetClosestObjectOfType(pCoords.x, pCoords.y, pCoords.z, 20.0, model, false, false, false)
    if micEntity == 0 then
        printDebug('[Error] Microphone object not found nearby.')
        return
    end

    local coords = GetEntityCoords(micEntity)
    local micZone = lib.zones.box({
        coords = vec3(coords.x, coords.y, coords.z),
        size = vec3(1.5, 1.0, 4.0),
        rotation = GetEntityHeading(micEntity),
        onEnter = function(micZone) 
            handleMicInteraction(true, micZone)
        end,
        onExit = function(micZone)
            handleMicInteraction(false, micZone)
        end,
        debug = Config.debug
    })
end

function handleMicInteraction(isPointInside, micZone)
    local srcSrv = GetPlayerServerId(PlayerId())

    if isPointInside then
        toggleMegaphone('stage', true)
    else
        toggleMegaphone('stage', false)
        micZone:remove()
    end
end

function handleMegaphoneAnimation(enable)
    local ped = PlayerPedId()

    if enable then
        loadAnimDict("amb@world_human_mobile_film_shocking@female@base")
        attachProp("prop_megaphone_01", 28422, 0.04, -0.01, 0.0, 22.0, -4.0, 87.0, 2, false)
        if not IsEntityPlayingAnim(ped, "amb@world_human_mobile_film_shocking@female@base", "base", 3) then
            TaskPlayAnim(ped, "amb@world_human_mobile_film_shocking@female@base", "base", 1.0, 1.0, GetAnimDuration("amb@world_human_mobile_film_shocking@female@base", "base"), 49, 0, 0, 0, 0)
        end
    else
        StopAnimTask(ped, "amb@world_human_mobile_film_shocking@female@base", "base", 3.0)
        removeAttachedProp()
    end
end

function removeAttachedProp()
    if DoesEntityExist(attachedProp) then
        DeleteEntity(attachedProp)
        attachedProp = 0
    end
end

function attachProp(model, boneNumber, x, y, z, xR, yR, zR, vertexIndex, disableCollision)
    removeAttachedProp()

    local attachModel = GetHashKey(model)
    local ped = PlayerPedId()
    local boneIndex = GetPedBoneIndex(ped, boneNumber)

    RequestModel(attachModel)
    while not HasModelLoaded(attachModel) do
        Citizen.Wait(10)
    end

    attachedProp = CreateObject(attachModel, 1.0, 1.0, 1.0, true, true, false)
    if disableCollision then
        SetEntityCollision(attachedProp, false, false)
    end

    AttachEntityToEntity(
        attachedProp,
        ped,
        boneIndex,
        x, y, z,
        xR, yR, zR,
        true, true, false, false,
        vertexIndex or 2,
        true
    )

    SetModelAsNoLongerNeeded(attachModel)
end

function loadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(5)
        end
    end
end

RegisterNetEvent('fd-megaphones:client:addsubmix', function(id)
	megaphoneEffectId = CreateAudioSubmix('megaphone')
	SetAudioSubmixEffectRadioFx(megaphoneEffectId, 1)
	SetAudioSubmixEffectParamInt(megaphoneEffectId, 1, GetHashKey('default'), 1)
	SetAudioSubmixEffectParamFloat(megaphoneEffectId, 1, GetHashKey('freq_low'), 10.0)
	SetAudioSubmixEffectParamFloat(megaphoneEffectId, 1, GetHashKey('freq_hi'), 10000.0)
	SetAudioSubmixEffectParamFloat(megaphoneEffectId, 1, GetHashKey('rm_mod_freq'), 300.0)
	SetAudioSubmixEffectParamFloat(megaphoneEffectId, 1, GetHashKey('rm_mix'), 0.2)
	SetAudioSubmixEffectParamFloat(megaphoneEffectId, 1, GetHashKey('fudge'), 0.0)
	SetAudioSubmixEffectParamFloat(megaphoneEffectId, 1, GetHashKey('o_freq_lo'), 200.0)
	SetAudioSubmixEffectParamFloat(megaphoneEffectId, 1, GetHashKey('o_freq_hi'), 5000.0)
	AddAudioSubmixOutput(megaphoneEffectId, 1)

    MumbleSetSubmixForServerId(id, megaphoneEffectId)

	printDebug('[Submix] Changing Submix For ID: ' .. id ..' | Megaphone')
end)

RegisterNetEvent('fd-megaphones:client:removesubmix', function(id)
	MumbleSetSubmixForServerId(id, -1)

	printDebug('[Submix] Changing Submix For ID: ' .. id ..' | Default')
end)

function printDebug(text)
    if not Config.debug then return end
    print(text)
end
