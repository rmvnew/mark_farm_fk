local display = false
local startTime = nil -- Guarda o tempo inicial do farm em milissegundos
local farmItems = {} -- Guarda os itens que serão farmados

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

                if distance < 4 then
                    sleep = 0
                    -- DrawMarker(27, x, y, z - 0.9, 0, 0, 0, 0, 0, 0, 0.7, 0.7, 0.7, 255, 0, 0, 200, false, false, 2, false, nil, nil, false)
                    DrawMarker(27, x, y, z - 0.9,  0, 0, 0, 0, 0, 130.0, 1.0, 1.0, 1.0, 150, 0, 0, 255, 0, 0, 0, 1)
                    DrawText3D(x, y, z, "[E] - Farm FK")

                    if distance < 2 then

                        ShowHelpText("Pressione ~INPUT_CONTEXT~ para abrir \no painel do FARM FK")
                        if distance < 1.5 and IsControlJustPressed(0, 38) then -- Pressionou "E"
                            startTime = GetGameTimer() -- Usa GetGameTimer() para armazenar o tempo
                            farmItems = data.itensFarm -- Define os itens do farm conforme a facção
                            SetDisplay(true) -- Abrir NUI
                        end

                    end

                end
            end
        end
        Citizen.Wait(sleep)
    end
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

-- Fechar NUI e resetar tempo
RegisterNUICallback("closeCurrentNUI", function(data, cb)
    SetDisplay(false)
    startTime = nil -- Reseta o tempo do farm
    cb("ok")
end)


RegisterNUICallback("startFarm", function(data, cb)

    if data then
        TriggerServerEvent("startFarm", data) 
    end
    cb("ok")
end)

-- Quando o tempo do farm acabar, validar no servidor antes de entregar itens
RegisterNUICallback("checkFarmTime", function(data, cb)

    if data then
        TriggerServerEvent("checkFarmTime", data, farmItems)
    end
    cb("ok")
end)
