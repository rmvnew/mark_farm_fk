local display = false
local startTime = nil -- Guarda o tempo inicial do farm em milissegundos
local farmItems = {} -- Guarda os itens que serão farmados
local farm_started = false
local current_data = nil

-- Função para desenhar texto 3D
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
    end
end

-- Verificar proximidade e exibir o marker
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000

        for category, data in pairs(Config.data.orgType) do
            for _, org in pairs(data.orgs) do
                local x, y, z = table.unpack(org.coords)
                local distance = #(playerCoords - vector3(x, y, z))

                if distance < 7 then
                    sleep = 0
                    -- DrawMarker(27, x, y, z - 0.9, 0, 0, 0, 0, 0, 0, 0.7, 0.7, 0.7, 255, 0, 0, 200, false, false, 2, false, nil, nil, false)
                    DrawMarker(27, x, y, z - 0.9,  0, 0, 0, 0, 0, 130.0, 1.0, 1.0, 1.0, 150, 0, 0, 255, 0, 0, 0, 1)
                    DrawText3D(x, y, z, "[E] - Farm FK")

                    if distance < 2 then

                        ShowHelpText("Pressione ~INPUT_CONTEXT~ para abrir \no painel do FARM FK")
                        if distance < 1.5 and IsControlJustPressed(0, 38) then -- Pressionou "E"
                            -- startTime = GetGameTimer() -- Usa GetGameTimer() para armazenar o tempo
                            -- farmItems = data.itensFarm -- Define os itens do farm conforme a facção
                            -- SetDisplay(true) -- Abrir NUI
                            current_data = data.itensFarm
                            TriggerServerEvent("mark_fk:checkpermission",org.permission)
                        end

                    end

                end
            end
        end
        Citizen.Wait(sleep)
    end
end)


RegisterNetEvent("mark_fk:autorized")
AddEventHandler("mark_fk:autorized", function()

        startTime = GetGameTimer() -- Usa GetGameTimer() para armazenar o tempo
        SetDisplay(true) -- Abrir NUI

end)



RegisterNetEvent("mark_fk:notAutorized")
AddEventHandler("mark_fk:notAutorized", function()

    print("❌ Permissão negada!")
    TriggerEvent("Notify", "negado", "Você não tem permissão para acessar esse blip!")
    PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    SetDisplay(false)
end)

function ShowHelpText(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

-- Mostrar ou esconder a NUI
function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = bool and "showUI" or "hideUI"
    })
end



RegisterNUICallback("startFarm", function(data, cb)
    startTime = GetGameTimer() -- Obtém o tempo de início
    farm_started = true -- Define que o farm foi iniciado
    TriggerServerEvent("startFarm", startTime) -- Envia para o servidor iniciar a contagem
    cb("ok")
end)


-- RegisterNUICallback("startFarm", function(data, cb)
--     if data then
--         farm_started = true
--         TriggerServerEvent("mark_fk:updateFarmStatus", true) -- Envia status para o servidor
--     end
--     cb("ok")
-- end)

RegisterNUICallback("closeCurrentNUI", function(data, cb)
    SetDisplay(false)
    farm_started = false
    startTime = nil -- Reseta o tempo do farm
    current_data = nil
    TriggerServerEvent("mark_fk:updateFarmStatus", false) -- Envia status para o servidor
    cb("ok")
end)


-- Quando o tempo do farm acabar, validar no servidor antes de entregar itens
RegisterNUICallback("checkFarmTime", function(data, cb)

    if data then
        TriggerServerEvent("checkFarmTime", data, current_data)
    end
    cb("ok")
end)


exports("farmStatus",function ()
    return farm_started
end)