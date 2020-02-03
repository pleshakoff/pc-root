let stompClient = null;
const token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbkBtYWlsLmNvbSIsInVzZXIiOiJhZG1pbkBtYWlsLmNvbSIsImlkVXNlciI6MSwiaWRHcm91cCI6MjEsImlkU3R1ZGVudCI6MzEsImF1dGhvcml0aWVzIjoiUk9MRV9BRE1JTiIsImlhdCI6MTU3NjMyMDc5NywiZXhwIjoxNjA3ODU2Nzk3fQ.qEfk5Jxdc7lNpJq_AF5gjn985FZMHhnHYNroM2Thu7kVz04OucBSEWcT0dKRHytWXmr6IsVX28BuNZEfN0Z8zg';
const host = '127.0.0.1:8087';//сервис pc-notifier_agent_websocket
const idUser = 1;//подписаны на сообщения только для пользователя с этим идентификатором

function setConnected(connected) {
    $("#connect").prop("disabled", connected);
    $("#connectError").prop("disabled", connected);
    $("#disconnect").prop("disabled", !connected);
    if (connected) {
        $("#notification-table").show();
    }
    else {
        $("#notification-table").hide();
    }
    $("#notifications").html("");
}

//самое важное здесь
async function connect(success) {
    //создаем соединение
    let socket = new WebSocket('ws://' + host + '/api/v1/pusher');
    console.log("Successful handshake");
    stompClient = Stomp.over(socket);
    const header = {
        "X-Auth-Token": token
    };
    if (!success)
    {
        console.log("waiting");
        await new Promise(r => setTimeout(r, 2000));
    }
    console.log("Connection..");
    stompClient.connect(header, function (frame) {
        setConnected(true);
        console.log('Connected: ' + frame);
        //idUser - текущий идентификатор пользователя из контекста клиентского приложения
        stompClient.subscribe('/topic/notifications/'+idUser, function (notification) {

            let parsed = JSON.parse(notification.body);
            addNotification(parsed.title,parsed.message);
        });
    });
}

function disconnect() {
    if (stompClient !== null) {
        stompClient.disconnect();
    }
    setConnected(false);
    console.log("Disconnected");
}



function addNotification(title,message) {
    $("#notifications").append("<tr><td>" + title+"</td><td>" + message+"</td></tr>");
}

$(function () {
    $("form").on('submit', function (e) {
        e.preventDefault();
    });
    $( "#connect" ).click(function() { connect(true); });
    $( "#connectError" ).click(function() { connect(false); });
    $( "#disconnect" ).click(function() { disconnect(); });
    $( "#send" ).click(function() { sendName(); });
});

