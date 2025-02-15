
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")



RegisterNetEvent("startFarm")
AddEventHandler("startFarm", function(startTime, farmItems)

    local source = source


    -- local novoTimestamp = startTime + (30 * 60) -- 30 minutos em segundos
    -- print("Nova Data (+30 min):", os.date("%d/%m/%Y %H:%M:%S", novoTimestamp))


    print("[FARM] Player " .. source .. " iniciou o farm às " ..  os.date("%d/%m/%Y %H:%M:%S", startTime))
end)

RegisterNetEvent("checkFarmTime")
AddEventHandler("checkFarmTime", function(startTime, farmItems)
    local source = source
    local currentTime = os.time() * 1000 -- Tempo atual em milissegundos
    local elapsedTime = currentTime - startTime -- Calcula o tempo passado

    if elapsedTime >= 1800000 then -- 30 minutos passaram? (1800000 ms = 30 min)
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

