// Configuração do tempo inicial em minutos (modifique conforme necessário)
let initialTimeInMinutes = 1;
let totalTimeInSeconds = initialTimeInMinutes * 60;
let timerInterval = null;

window.addEventListener('message', function (event) {
    var data = event.data;
    if (data.action === "showUI") {
        showFarmMenu();
    } else if (data.action === "hideUI") {
        hideFarmMenu();
    }
});

$(document).keyup((event) => {
    if (event.key === 'Escape') {
        sendDataToClient('closeCurrentNUI', null);
    }
});

function showFarmMenu() {
    var panel = document.getElementById("my_container");
    panel.style.display = "flex";
}

function hideFarmMenu() {
    var panel = document.getElementById("my_container");
    panel.style.display = "none";
    resetTimer(); // Garante que o tempo seja resetado ao fechar a NUI
}

// Função para formatar o tempo no formato minutos:segundos (mm:ss)
function formatTime(totalSeconds) {
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return minutes + ':' + (seconds < 10 ? '0' : '') + seconds;
}



// Função para iniciar o timer
function startTimer() {
    timeStarted()
    const display = document.getElementById('timerDisplay');

    // Atualiza o display imediatamente
    display.value = formatTime(totalTimeInSeconds);

    // Desabilita o botão para evitar múltiplos cliques
    document.getElementById('startButton').disabled = true;

    timerInterval = setInterval(() => {
        if (totalTimeInSeconds === 0) {
            display.value = formatTime(totalTimeInSeconds);
            onTimerEnd();
            resetTimer();
        } else {
            totalTimeInSeconds--;
            display.value = formatTime(totalTimeInSeconds);
        }
    }, 1000);
}


function timeStarted(){

   const timestamp = Math.floor(Date.now() / 1000);

   sendDataToClient("startFarm",timestamp)
   
   
}

// Função que é chamada quando o timer chega a zero
function onTimerEnd() {
    
    const timestamp = Math.floor(Date.now() / 1000);
    
    sendDataToClient("checkFarmTime",timestamp)
    

}

// Função para resetar o timer ao fechar a NUI
function resetTimer() {
    if (timerInterval) {
        clearInterval(timerInterval);
        timerInterval = null;
    }
    totalTimeInSeconds = initialTimeInMinutes * 60;
    document.getElementById('timerDisplay').value = formatTime(totalTimeInSeconds);
    document.getElementById('startButton').disabled = false; // Reativa o botão iniciar
}

// Vincula a função startTimer ao clique do botão
document.getElementById('startButton').addEventListener('click', startTimer);

function sendDataToClient(url, data) {
    let current_data = data ? data : 'ok';

    let config = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(current_data)
    };

    fetch(`https://${GetParentResourceName()}/${url}`, config)
        .then(() => {
            console.log("Mensagem enviada ao client.lua");
        })
        .catch(error => {
            console.log('Error: ', error);
        });
}
