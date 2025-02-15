
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
    local user_id = vRP.getUserId(source)
    
    if not user_id then
        return
    end

    print("StartTime: ", START_TIME)
    print("Finaltime: ", finaltime)

    local elapsedTime = finaltime - START_TIME -- Calcula o tempo passado

    print("elapsedTime: ", elapsedTime)

    -- Verifica se o tempo necessário passou
    -- if elapsedTime >= 1800 then -- 1800 segundos = 30 minutos
    if elapsedTime >= 60 then -- 1800 segundos = 30 minutos
        local currentWeight = tonumber(vRP.computeInvWeight(user_id)) or 0
        local maxWeight = tonumber(vRP.getInventoryMaxWeight(user_id)) or 0

        -- Se os valores forem inválidos, avisa o jogador
        if not currentWeight or not maxWeight then
            TriggerClientEvent("Notify", source, "negado", "Erro ao verificar o espaço da mochila.")
            return
        end

        print("🎒 Peso atual:", currentWeight, "/", maxWeight)

        local coletouAlgo = false
        local quantidadeFixada = 40 -- Quantidade fixa de itens que o jogador receberá

        -- Verifica se há espaço no inventário para os itens do farm
        for _, itemData in ipairs(farmItems) do
            local itemWeight = vRP.getItemWeight(itemData.item) or 0
            local totalWeight = currentWeight + (itemWeight * quantidadeFixada)

            if totalWeight <= maxWeight then
                vRP.giveInventoryItem(user_id, itemData.item, quantidadeFixada, true)
                print("[FARM] Player " .. user_id .. " recebeu " .. quantidadeFixada .. "x " .. itemData.item)
                coletouAlgo = true

                -- Atualiza o peso do inventário
                currentWeight = tonumber(vRP.computeInvWeight(user_id)) or 0
            end
        end

        -- Se o jogador conseguiu coletar pelo menos 1 item, o farm continua
        if coletouAlgo then
            vRP.giveInventoryItem(user_id, "dinheirosujo", 1000, true)
            START_TIME = finaltime
            print("[FARM] Player " .. user_id .. " completou o farm e recebeu os itens.")
            TriggerClientEvent("continueFarm", source) -- Continua automaticamente
        else
            -- Caso contrário, notifica que a mochila está cheia
            TriggerClientEvent("Notify", source, "negado", "Mochila cheia! Esvazie antes de continuar o farm.")
        end
    else
        print("[FARM] Player " .. source .. " tentou pegar os itens antes do tempo.")
    end
end)
