-- Obter a hora atual (em segundos desde a época)
local agora = os.time()

-- Define a hora futura
-- Exemplo 1: 1 hora no futuro
-- local horaFutura = agora + (60 * 60)

-- Exemplo 2: 15 minutos no futuro (para testar a condição de menos de 20 minutos)
local horaFutura = agora + (15 * 60)

-- Calcula a diferença em segundos entre a hora futura e a hora atual
local diferenca = os.difftime(horaFutura, agora)

-- Converte a diferença para minutos (opcional)
local diferencaMinutos = diferenca / 60

-- Verifica se a diferença é menor que 20 minutos
if diferenca < (20 * 60) then
  print("Faltam menos de 20 minutos para a hora futura (" .. diferencaMinutos .. " minutos).")
else
  print("Ainda há mais de 20 minutos para a hora futura (" .. diferencaMinutos .. " minutos).")
end
