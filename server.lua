

local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

-- Tabela para armazenar o tempo inicial do farm de cada jogador
local farmPlayers = {}
local farm_started = false

-- Verifica se o jogador tem permissão para farmar
RegisterNetEvent("mark_fk:checkpermission")
AddEventHandler("mark_fk:checkpermission", function(permission)
    local source = source
    local user_id = vRP.getUserId(source)

    if vRP.hasPermission(user_id, permission) then
        TriggerClientEvent("mark_fk:autorized", source)
    else
        TriggerClientEvent("mark_fk:notAutorized", source)
    end
end)


local farmPlayers = {} -- Armazena os dados do farm de cada jogador

-- 🔥 O tempo só começa quando o jogador clica em "Iniciar" na NUI
RegisterNetEvent("startFarm")
AddEventHandler("startFarm", function(startTime)
    local source = source
    local user_id = vRP.getUserId(source)

    if user_id then
        farmPlayers[user_id] = { startTime = startTime }
        print("[FARM] Player " .. user_id .. " iniciou o farm em " .. os.date("%X", startTime))
        TriggerClientEvent("Notify", source, "sucesso", "Farm iniciado com sucesso!")
    end
end)


-- ✅ Verifica se o tempo passou antes de entregar os itens
RegisterNetEvent("checkFarmTime")
AddEventHandler("checkFarmTime", function(finaltime, farmItems)
    local source = source
    local user_id = vRP.getUserId(source)

    if not user_id then return end

    -- 🔍 Verifica se o jogador iniciou o farm corretamente
    if not farmPlayers[user_id] or not farmPlayers[user_id].startTime then
        print("[FARM] Erro: Jogador " .. user_id .. " não tem um farm ativo.")
        TriggerClientEvent("Notify", source, "negado", "Você não iniciou um farm ativo!")
        return
    end

    local startTime = farmPlayers[user_id].startTime
    local elapsedTime = finaltime - startTime

    print("[FARM] Player: " .. user_id .. " | StartTime: " .. startTime .. " | FinalTime: " .. finaltime .. " | elapsedTime: " .. elapsedTime)

    -- ⏳ Verifica se 30 minutos passaram
    if elapsedTime >= 1800 then
        local currentWeight = tonumber(vRP.computeInvWeight(user_id)) or 0
        local maxWeight = tonumber(vRP.getInventoryMaxWeight(user_id)) or 0

        -- 📌 Se o peso do inventário for inválido, cancela a coleta
        if not currentWeight or not maxWeight then
            TriggerClientEvent("Notify", source, "negado", "Erro ao verificar o espaço da mochila.")
            return
        end

        print("🎒 Peso atual:", currentWeight, "/", maxWeight)

        local coletouAlgo = false
        local quantidadeFixada = 30 -- Quantidade fixa de itens que o jogador recebe

        -- 🔥 Verifica espaço no inventário antes de dar os itens
        for _, itemData in ipairs(farmItems) do
            local itemWeight = vRP.getItemWeight(itemData.item) or 0
            local totalWeight = currentWeight + (itemWeight * quantidadeFixada)

            if totalWeight <= maxWeight then
                vRP.giveInventoryItem(user_id, itemData.item, quantidadeFixada, true)
                print("[FARM] Player " .. user_id .. " recebeu " .. quantidadeFixada .. "x " .. itemData.item)
                coletouAlgo = true
                currentWeight = tonumber(vRP.computeInvWeight(user_id)) or 0
            end
        end

        -- ✅ Se o jogador recebeu os itens, o farm continua e o tempo é atualizado
        if coletouAlgo then
            vRP.giveInventoryItem(user_id, "dinheirosujo", 2000, true)
            farmPlayers[user_id].startTime = finaltime -- Atualiza o tempo do farm
            print("[FARM] Player " .. user_id .. " completou o farm e recebeu os itens.")
            TriggerClientEvent("continueFarm", source) -- Continua automaticamente
        else
            -- 🚨 Caso contrário, avisa que a mochila está cheia
            TriggerClientEvent("Notify", source, "negado", "Mochila cheia! Esvazie antes de continuar o farm.")
        end
    else
        print("[FARM] Player " .. user_id .. " tentou pegar os itens antes do tempo.")
    end
end)


-- Atualiza o status de farm do jogador (ativo/inativo)
RegisterNetEvent("mark_fk:updateFarmStatus")
AddEventHandler("mark_fk:updateFarmStatus", function(status)
    local user_id = vRP.getUserId(source)
    if user_id then
        farmPlayers[user_id] = farmPlayers[user_id] or {}
        farmPlayers[user_id].isActive = status
        farm_started = status
    end
end)

-- Exporta a função para verificar se o jogador está farmando
exports("farmStatus", function(source)
    local user_id = vRP.getUserId(source)
    return farmPlayers[user_id] and farmPlayers[user_id].isActive or false
end)

exports("farmStatus",function ()
    -- print("Status: ",farm_started)
    return farm_started
end)