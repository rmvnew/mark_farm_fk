
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

START_TIME = nil


RegisterNetEvent("startFarm")
AddEventHandler("startFarm", function(startTime)

    START_TIME = startTime
    
    
end)


RegisterNetEvent("checkFarmTime")
AddEventHandler("checkFarmTime", function(finaltime, farmItems)

    local source = source
    
    print("StartTime: ",START_TIME)
    print("Finaltime: ",finaltime)

    local elapsedTime = finaltime - START_TIME -- Calcula o tempo passado

    print("elapsedTime: ",elapsedTime)

    -- if elapsedTime >= 1800000 then -- 30 minutos passaram? (1800000 ms = 30 min)
    if elapsedTime >= 60 then -- 30 minutos passaram? (1800000 ms = 30 min)
        for _, itemData in ipairs(farmItems) do
            print("[FARM] Player " .. source .. " recebeu " .. itemData.item)
            -- Aqui você pode adicionar a lógica para dar os itens ao jogador:
            -- Exemplo: vRP.giveInventoryItem(source, itemData.item, quantidade)
        end

        print("[FARM] Player " .. source .. " completou o farm e recebeu os itens.")
        TriggerClientEvent("continueFarm", source) -- Continua automaticamente

    else
        print("[FARM] Player " .. source .. " tentou pegar os itens antes do tempo.")
    end
end)

