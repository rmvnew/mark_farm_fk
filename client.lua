local display = false

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

-- Criar blips e markers
Citizen.CreateThread(function()
    for category, data in pairs(Config.data.orgType) do
        for _, org in pairs(data.orgs) do
            local x, y, z = table.unpack(org.coords)

            -- Criar Blip
            local blip = AddBlipForCoord(x, y, z)
            SetBlipSprite(blip, 84) -- Ícone do blip (pode mudar)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 1)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Ponto de Farm - " .. org.name)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

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

                if distance < 5 then
                    sleep = 0
                    -- DrawMarker(27, x, y, z - 0.9, 0, 0, 0, 0, 0, 0, 0.7, 0.7, 0.7, 255, 0, 0, 200, false, false, 2, false, nil, nil, false)
                    DrawMarker(27, x, y, z - 0.95,  0, 0, 0, 0, 0, 130.0, 1.0, 1.0, 1.0, 255, 0, 0, 255, 0, 0, 0, 1)
                    DrawText3D(x, y, z, "[E] - Farm FK")

                    if distance < 1.5 then
                        if IsControlJustPressed(0, 38) then -- Pressionou "E"
                            SetDisplay(true) -- Abrir NUI
                        end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

-- Função para mostrar a NUI
function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = bool and "showUI" or "hideUI"
    })
end

-- Fechar a NUI com ESC
RegisterNUICallback("closeCurrentNUI", function()
    SetDisplay(false)
end)
