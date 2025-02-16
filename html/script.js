// Configuração do tempo inicial em minutos (modifique conforme necessário)
let initialTimeInMinutes = 30; // Tempo inicial em minutos (altere conforme necessário)
let totalTimeInSeconds = initialTimeInMinutes * 60; // Tempo total em segundos
let timerInterval = null; // Variável para armazenar o timer


// Escuta eventos vindos do client.lua para abrir ou fechar a NUI
window.addEventListener("message", function (event) {
    var data = event.data;
    if (data.action === "showUI") {
        showFarmMenu();
    } else if (data.action === "hideUI") {
        hideFarmMenu();
    }
});

// Captura a tecla "ESC" para fechar a NUI e resetar o timer
$(document).keyup((event) => {
    if (event.key === "Escape") {
        sendDataToClient("closeCurrentNUI", null);
        resetTimer(); // Reseta o timer ao fechar a NUI
    }
});

// Exibe o menu da NUI
function showFarmMenu() {
    var panel = document.getElementById("my_container");
    panel.style.display = "flex";
}

// Esconde o menu da NUI e reseta o timer
function hideFarmMenu() {
    var panel = document.getElementById("my_container");
    panel.style.display = "none";
    resetTimer(); // Garante que o tempo seja resetado ao fechar a NUI
}

// Formata o tempo para exibição no formato minutos:segundos (mm:ss)
function formatTime(totalSeconds) {
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
}

// Função chamada ao iniciar o farm
function startTimer() {
    timeStarted(); // Envia a hora de início ao servidor
    const display = document.getElementById("timerDisplay");

    // Atualiza o display imediatamente
    display.value = formatTime(totalTimeInSeconds);

    // Desabilita o botão para evitar múltiplos cliques
    document.getElementById("startButton").disabled = true;

    // Para qualquer intervalo de tempo existente antes de iniciar um novo
    if (timerInterval) clearInterval(timerInterval);

    // Inicia o contador regressivo
    timerInterval = setInterval(() => {
        if (totalTimeInSeconds === 0) {
            display.value = formatTime(totalTimeInSeconds);
            onTimerEnd(); // Aciona evento ao zerar o tempo
        } else {
            totalTimeInSeconds--;
            display.value = formatTime(totalTimeInSeconds);
        }
    }, 1000);
}

// Envia ao servidor o timestamp do início do farm
function timeStarted() {
    const startTime = Math.floor(Date.now() / 1000); // Captura o timestamp atual em segundos
    sendDataToClient("startFarm", startTime);
}

// Função chamada quando o timer chega a zero
function onTimerEnd() {
    const startTime = Math.floor(Date.now() / 1000); // Captura o tempo atual

    // Envia ao servidor o tempo final para verificar se o farm pode continuar
    sendDataToClient("checkFarmTime", startTime);

    // Reinicia automaticamente o farm
    totalTimeInSeconds = initialTimeInMinutes * 60;
}

// Reseta o timer ao fechar a NUI ou pressionar ESC
function resetTimer() {
    if (timerInterval) {
        clearInterval(timerInterval); // Para o contador se estiver rodando
        timerInterval = null;
    }
    totalTimeInSeconds = initialTimeInMinutes * 60; // Reinicia o tempo
    document.getElementById("timerDisplay").value = formatTime(totalTimeInSeconds);
    document.getElementById("startButton").disabled = false; // Reativa o botão iniciar
}

// Vincula a função startTimer ao clique do botão "Iniciar"
document.getElementById("startButton").addEventListener("click", startTimer);

// Envia os dados para o servidor via fetch (usado para comunicação entre NUI e client.lua)
function sendDataToClient(url, data) {
    let config = {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify(data),
    };

    fetch(`https://${GetParentResourceName()}/${url}`, config)
        .then(() => {
            console.log("Mensagem enviada ao client.lua:", url, data);
        })
        .catch((error) => {
            console.log("Erro ao enviar mensagem ao client.lua:", error);
        });
}
