# Родительский комитет

1. [Описание системы](#desc)
2. [Логическая структура](#struct)
3. [Сервисы](#service)
4. [Мониторинг](#monitoring)
5. [Get started](#get-started)
6. [Домашнее задание №5 (realtime)](#hw5)
7. [Домашнее задание №6 (кэш)](#hw6)
8. [Домашнее задание №7 (очередь)](#hw7)
9. [Домашнее задание №8 (мониторинг)](#hw8)


<a name="desc"></a>
## Описание системы. 
Система предназначена для автоматизации работы родительского комитета в школе или детском саду.

##### Доступный функционал на текущий момент: 

* Авторизация и аутентификация. 
* Регистрация класса и учебного заведения
* Управление списком учеников
* Регистрация родителей и привязка к ученикам
* Публикация и чтение новостей
* Рассылка уведомлений родителям учеников

##### Планируемый функционал: 

* Проведение опросов среди родителй
* Учет сбора денег и закупок

Работа в системе для каждого пользователя ведется в рамках рабочего пространства (группы или класса).
 
Пользователи могут быть трех видов 
* Администратор 
* Член родительского комитета 
* Родитель

Для организации родительского комитета  в системе необходимо создать свою группу и пригласить туда других пользователей.
Пользователь, создавший группу, получает роль "Администратор" и может приглашать других членов родительского комитета или просто родителей.
Остальные пользователи могут присоединиться только получив приглашение от администратора или от члена родительского комитета.

На текущий момент для того чтобы зарегистрироваться как член родительского комитета, 
достаточно знать идентификтор класса.
Для того чтобы зарегистрироваться как родитель, надо знать идентификатор ученика.

Один и тот же пользователь может быть членом нескольких групп.  

В рамках группы, членами родительского комитета формируется список ученников. 
К одному ученику может быть привязано бесконечное количество пользователей.
Пользователь может быть родителем нескольких учеников из одной группы или  из разных групп.

При входе или в процессе работы пользователь должен выбрать текущего ученика из списка доступных ему, 
от лица которого он осуществляет операции.
 
Весь список учеников класса видят только члены родительского комитета.
Обычный родитель может видеть только своих детей. 

Члены родительского комитета могут публиковать новости. 
Обычные пользователи имеют доступ к ленте новостей. 
При публикации новости всем пользователям(родителям) рассылаются уведомления 

Члены родительского комитета могут создать опрос. Пока запрос активен родители могут выбрать один из вариантов ответов,
или поменять свой вариант. После закрытия опроса менять, ничего нельзя. 
Опрос может быть как общегрупповой, в котором участвуют все ученики группы, 
так и для для ограниченного перечня учеников.
Каждый родитель может голосовать за ученика,к которому он привязан. Если к ученику привязано несколько родителей, 
то оба могут менять результат, но только за своего ребенка.
Опросы могут быть публичные и анонимные. 
При созданнии опроса рассылаются уведомления. 

Для управления финансами родительского комитета в системе вводится понятие "Цель". 
В рамках цели задается необходимая сумма и перечень учеников, которые участвуют в достиженнии цели. 
Например на цель - "нужды класса" должны сдать все, а на цель "экскурсия" только часть учеников.
В рамках цели учитываются входящие платежи от учеников и исходящие с описанием на что потрачено и аттачем чека.
Член родительского комитета вносят данные о приходах и расходах и видят все движение по всем целям. 
Обычные родители видят доступные им цели, общую сумму цели и расходы.
Для членов родительского комитета доступны отчеты: списки должников, расходы по периодам и.т.д 
При формировании новой цели родителям детей рассылаются уведомления.  
            

<a name="struct"></a>
## Логическая структура 


![alt text](https://github.com/pleshakoff/pc-root/blob/master/pics/parcom_hw8.png?raw=true"")


Во всех сервисах работа ведется в контексте текущего ученика. Данные о текущем ученике пользователя 
зашифрованы в "self contained" токене, 
который формируется сервисом авторизации [Security](#Security) и должен передаваться во все запросы к сервисам.

Валидация токена осуществляется на стороне сервисов(sidecar).  

Авторизация тоже на стороне сервисов, путем определения доступа к методам для роли из токена
(у пользователя может быть всего одна роль и ее можно передать в токене)

Сервисы [Polls](#Polls) и [Money](#Money) есть на схеме, но они ее не реализованы. 

<a name="service"></a>
## Сервисы

* [Security](#Security)
* [Classroom](#Classroom)
* [News](#News)
* [Polls](#Polls)
* [Money](#Money)
* [Notifier](#Notifier)
* [Notifier Agent Email](#NotifierAgentEmail)
* [Notifier Agent Push](#NotifierAgentPush)
* [Notifier Agent Websocket](#NotifierAgentWebsocket)
* [User cache](#UserCache)

<a name="Security"></a>
### Security 

Репозиторий: https://github.com/pleshakoff/pc-security
Swagger: http://localhost:8081/api/v1/swagger-ui.html

Сервис управления учетными записями 

* Регистрация и хранение учетных записей 
* Аутентификация 
* Формирование "self contained" токена со сроком действия.
* Хранение и переключение текущего ученика и группы пользователя
* Смена пароля (не реализовано) 
* Подтверждение регистрации (не реализовано) 


#### Взаимодействие с другими сервисами     

 1. При сменее текущего студента или группы (​/auth​/context) в контесте которого планирутеся вестись работа,
   вызвает методы сервиса [Classroom](#Classroom)
 для проверки привязан ли пользователь к группе (GET /group/my) или студенту(GET /students/my).
 
 2. Методы регистрации (POST ​/users​/register) и удаления(DELETE /users​/{id}) учетной записи 
 не могут быть вызваны напрямую, т.к учетная запись привязана к родителю который зарегистрирован в сервисе 
 [Classroom](#Classroom).  Не выдают ошибку только если вызываются из сервиса [Classroom](#Classroom)   
 

<a name="Classroom"></a>
### Classroom 

Репозиторий: https://github.com/pleshakoff/pc-classroom

Swagger: http://localhost:8080/api/v1/swagger-ui.html

Сервис отвечает за управление рабочим пространством родительского комитета. 
И взаимосвязь основных участников бизнес процесса.   

* Регистрация группы/класса
* Управление списком учащихся
* Регистрация родителей 
* Привязка родителей к ученикам

#### Взаимодействие с другими сервисами     

 1. После регистрации новой группы (POST ​/add​/group), члена родительского комитета (POST /add/member) 
 или обычного родителя (POST /add/parent) вызывает метод регистрации новой учетной записи сервиса  
 [Security](#Security) (POST /users/register). Если вызов неудачен, то создание нового родителя или группы откатывается.   
 
 2. При удалении пользователя(родителя) (DELETE ​/users/{id}) вызывает метод удаления (DELETE ​/users​/{id}) 
 учетной записи сервиса  [Security](#Security) (DELETE /users/{id}). Если вызов неудачен, то удаление откатывается.  
 
 3. Является поставщиком информации о списке учеников. 
 При удалении или добавалении ученика отправляет сообщение в брокер сообщений для синхронизации 
 со списками учеников сервисах-потребителях. (Не реализовано) 
 
 4. При обновлении данных родителя вызывает метод сервиса кэширвоания [User cache](#UserCache), сбрасывающий 
    данные кэша по измененному пользователю (DELETE /users/reset/{id})
)  
 

<a name="News"></a>
### News  
Репозиторий: https://github.com/pleshakoff/pc-classroom

Swagger: http://localhost:8082/api/v1/swagger-ui.html

Сервис отвечающий за работу с новостями. 
На данный момент позволяет публиковать и читать новости пользователям в контексте группы.
Потенциально может агрегировать новости из других источников и показывать их родителям. 

* Публикация и хранение новостей
* Получение списка новостей 
* Обсуждение новостей (не реализовано)

#### Взаимодействие с другими сервисами     
 
 1. При публикации новости (POST​/news) помещается сообщение в брокер, которое обрабатываеся 
 сервисом [Notifier](#Notifier), который в свою очередь рассылает через агентов групповое сообщение. 
 Новость публикуется незвисимо от 
 того, удачно ли прошла рассылка уведомления.   
 2. Получение через брокер сообщений сигнала об удалении группы от сервиса [Classroom](#Classroom) (не реализовано). 


<a name="Polls"></a>
### Polls  

**НЕ РЕАЛИЗОВАН** 

Сервис предназначен для проведения отпросов среди родителей группы.

* создание опроса 
* выбор учеников для опроса 
* голосование 

#### Взаимодействие с другими сервисами     

 1. При создании опроса, если он общегрупповой, у сервиса [Classroom](#Classroom) запрашивается текущий состав группы,
 и список учеников привязывается к опросу. 
 
 2. Через брокер сообщений список учеников в активных опросах синхронизируется со списком учеников 
 группы, поставляемым сервисом [Classroom](#Classroom). Если в группе появился новый ученик, 
 то он добавляется в активные общегрупповые опросы. Если удаляется ученик, то он удаляется из любых активных 
 опросов.
 
 3. Получение через брокер сообщений сигнала об удалении группы от сервиса [Classroom](#Classroom). 
    
 4. При публикации опроса, помещается сообщение в брокер, которое обрабатываеся 
    сервисом [Notifier](#Notifier), который рассылает через агентов 
    общегрупповое сообщение или сообщение ограниченному списку пользователей, участников опроса. 
 

<a name="Money"></a>
### Money  

**НЕ РЕАЛИЗОВАН** 

Сервис учета денежных средств группы 

* управления целями сбора средств 
* учет входящих транзакций  
* учет исходящих транзакций
* выборки для отчетов (остатки, должники) 
 
#### Взаимодействие с другими сервисами    

 1. При создании цели сбора средств, если она общегрупповая, у сервиса [Classroom](#Classroom) 
 запрашивается текущий состав группы и список учеников привязывается к цели. 
 
 2. Через брокер сообщений список учеников в активных сборах средств синхронизируется со списком учеников 
 группы, поставляемым сервисом [Classroom](#Classroom). Если в группе появился новый ученик, 
 то он добавляется в активные общегрупповые сборы. Если удаляется ученик, то он удаляется из любых активных 
 сборов.
 
 3. Получение через брокер сообщений сигнала об удалении группы от сервиса [Classroom](#Classroom). 

 4. При создании цели сбора средств, помещается сообщение в брокер, которое обрабатываеся 
сервисом [Notifier](#Notifier), который рассылает через агентов групповое сообщение или сообщение списку пользователей, 
участников сбора средств. 


<a name="Notifier"></a>
### Notifier  

Репозиторий: https://github.com/pleshakoff/pc-notifier

Swagger: http://localhost:8083/api/v1/swagger-ui.html

Сервис отвечает за формирование списка получателей уведомлений и отправку уведомлений через брокер агентам. 

Поддерживает три вида уведомлений 

* Для всей группы. 
* Для отдельного пользователя 
* Для списка пользователей     

В зависимости от типа уведомления формирует список пользователей получателей 
и помещает сообщение для каждого получателя в брокер сообщений.   

#### Взаимодействие с другими сервисами    

1. Если сообщение общегрупповое (POST ​/send​/group), то запрашивает идентификаторы пользователей(родителей)
группы у сервиса [Classroom](#Classroom) (GET ​/users​/all)
 
2. Добавляет сообщения в очередь в брокере сообщений из которой её разбирают подписанные агенты. 


<a name="NotifierAgentEmail"></a>
### Notifier Agent Email    

Репозиторий: https://github.com/pleshakoff/pc-notifier-agent-email

Swagger: http://localhost:8084/api/v1/swagger-ui.html

Отправка письма пользователю. 

#### Взаимодействие с другими сервисами     
  
1. Получает  идентификатор пользователя и текст сообщения от сервиса [Notifier](#Notifier) через очередь в брокере, 
2. Запрашивает email пользователя у сервиса с кэшированными данными пользователя [User cache](#UserCache) (GET ​/users​/{id}) 
и отправляет письмо (в текущей версии просто пишет в лог) 

<a name="NotifierAgentPush"></a>
### Notifier Agent Push    

Репозиторий: https://github.com/pleshakoff/pc-notifier-agent-push

Swagger: http://localhost:8085/api/v1/swagger-ui.html

#### Взаимодействие с другими сервисами     
  
1. Получает  идентификатор пользователя и текст сообщения от сервиса [Notifier](#Notifier) через очередь в брокере 
2. Запрашивает телефон пользователя у сервиса с кэшированными данными пользователя [User cache](#UserCache) 
(GET ​/users​/{id}) и отправляет смс (в текущей версии просто пишет в лог) 


<a name="NotifierAgentWebsocket"></a>
### Notifier Agent Websocket    

Репозиторий: https://github.com/pleshakoff/pc-notifier-agent-websocket

Swagger: http://localhost:8087/api/v1/swagger-ui.html

Агент для realtime отправки уведомлений клинтам через websocket 

Клиентское приложение может подключиться к сокету и подписаться на получение уведомлений.

Endpoint для подключения к сокету `/pusher?token=валидный_jwt_токен`
Endpoint для подписки на уведомления `/topic/notifications/{idUser}`

При логине клиент получает jwt токен и идентификатор пользователя 
и должен использовать их для подключения и подписки на уведомления. 
Неавторизованное подключение будет отклонено.     


#### Взаимодействие с другими сервисами     
  
1. Получает  идентификатор пользователя и текст сообщения от сервиса [Notifier](#Notifier) через очередь в брокере


<a name="UserCache"></a>
### User cache    

Репозиторий: https://github.com/pleshakoff/pc-user-cache

Swagger: http://localhost:8086/api/v1/swagger-ui.html

Сервис для кэширования данных родителей(пользователей). 
Кэш сбрасывается по истечении ttl или при изменении данных родителя(пользователя) в сервисе [Classroom](#Classroom) 

#### Взаимодействие с другими сервисами     
  
1. Запрашивает данные пользователя у сервиса [Classroom](#Classroom) (GET ​/users​/{id}), если данные не найдены в кэше 
2. Сбрасывает данные пользователя при вызове другими сервисами специального эндпоинта (DELETE /users/reset/{id})   


<a name="monitoring"></a>
## Мониторинг 

Во всех сервисах созданы ендопинты для сбора метрик о состоянии процесса. 
**Prometheus** осуществляет сбор и хранение метрик. 
В качестве дашборда используется **Grafana**. 

Доступ к Grafana http://localhost:3000/

login:admin pass:admin

В базе уже есть преднастроенный дашборд: **PARCOM**.  На нем можно выбрать инстанс и посмотреть его метрики. 

![alt text](https://github.com/pleshakoff/pc-root/blob/master/pics/parcom_hw7_dashboard.png?raw=true"") 
 


<a name="get-started"></a>
## Get started 

Для развертывания сервисов необходимо выполнить `docker-compose up` из этого репозитория, запущены 
будут контейнеры с сервисами из публичного docker hub.

В систему загружены тестовые данные и можно пробовать вызывать API. 
Ссылки на swagger для каждого сервиса указаны в описании сервисов. 

### Логин 

Сейчас в системе созданы три пользователя с разными ролями, можно залогиниться одним из них, 
или же сразу использовать уже готовый тестовый токен 
http://localhost:8081/api/v1/auth/login

**Админ** 

logn: admin@mail.com

pass: 12345

token: eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbkBtYWlsLmNvbSIsInVzZXIiOiJhZG1pbkBtYWlsLmNvbSIsImlkVXNlciI6MSwiaWRHcm91cCI6MjEsImlkU3R1ZGVudCI6MzEsImF1dGhvcml0aWVzIjoiUk9MRV9BRE1JTiIsImlhdCI6MTU3NjMyMDc5NywiZXhwIjoxNjA3ODU2Nzk3fQ.qEfk5Jxdc7lNpJq_AF5gjn985FZMHhnHYNroM2Thu7kVz04OucBSEWcT0dKRHytWXmr6IsVX28BuNZEfN0Z8zg


**Член родительского комитета**
  
logn: molly@weasley.com

pass: 12345

token: eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJtb2xseUB3ZWFzbGV5LmNvbSIsInVzZXIiOiJtb2xseUB3ZWFzbGV5LmNvbSIsImlkVXNlciI6MiwiaWRHcm91cCI6MjEsImlkU3R1ZGVudCI6MzIsImF1dGhvcml0aWVzIjoiUk9MRV9NRU1CRVIiLCJpYXQiOjE1NzYzMjA3NDEsImV4cCI6MTYwNzg1Njc0MX0.lo9iJNR3XW-R8EzQKivIKEJD0nwvFAoIyT62lE2f3PvC6oP66jHDloC83wukTEcemmuI_Ant4bq1t4EF-r7WGg


**Простой родитель**
  
logn: artur@weasley.com

pass: 12345

token: eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhcnR1ckB3ZWFzbGV5LmNvbSIsInVzZXIiOiJhcnR1ckB3ZWFzbGV5LmNvbSIsImlkVXNlciI6MywiaWRHcm91cCI6MjEsImlkU3R1ZGVudCI6MzIsImF1dGhvcml0aWVzIjoiUk9MRV9QQVJFTlQiLCJpYXQiOjE1NzYzMjA2ODgsImV4cCI6MTYwNzg1NjY4OH0.E91aUr4OKnWq1sdRVpSdv2UDuis9i5-9QUMgQxn_I4iNB7ee5so04gzisJGL9a3UhNLHTjwu3yN-AVEWVZ8w-Q
 
### Регистрация 

Регистрация просисходит через сервис [Classroom](#Classroom). 
Помимо учетной записи при регистрации создается родитель и привязвается к группе и к ученику.

Для регистрации необходимы данные ученика или группы. 
Передполагается что родителям были отправлены письма с приглашением 
с необходимой зашифрованной информацией и они регистрируются, перейдя по ссылке в письме.
Рассылка приглашений пока не реализована.  
 
**Регистрация простого родителя** 
http://localhost:8080/api/v1/add/parent

Необходимо знать id ученика.

`{
  "email": "parent@mail.ru",
  "idStudent": 31,
  "password": "12345",
  "passwordConfirm": "12345"
}
`

**Регистрация члена родительского комитета** 
http://localhost:8080/api/v1/add/member

Необходимо знать id группы.  Можно указать id ученика. 

`{
  "email": "member@mail.ru",
  "idGroup": 21,
  "idStudent": 31,
  "password": "12345",
  "passwordConfirm": "12345"
}
`

**Регистрация новой группы и админа** 
http://localhost:8080/api/v1/add/group

Создатель группы является админом.
 
Можно выбрать школу из существующих 

`{
"email": "creator@mail.ru",
"nameGroup": "1 А",
"idSchool": "11",
"password": "12345",
"passwordConfirm": "12345"
}
`

или создать свою

`{
"email": "creator@mail.ru",
"nameGroup": "1 А",
"nameSchool": "Школа № 777",
"password": "12345",
"passwordConfirm": "12345"
}
`

  
После регистрации можно пройти аутентификацию, используя в качестве логина email 


<a name="hw5"></a>
## Домашнее задание №5 (realtime)


Реализовано получение уведомлений в реальном времени через websocket. За отправку уведомлений отвечает сервис 
[Notifier Agent Websocket](#NotifierAgentWebsocket)  

Для развертывания сервисов необходимо выполнить `docker-compose up` из этого репозитория, запущены 
будут контейнеры с сервисами из публичного docker hub.(см. [Get started](#get-started))
 
Для проверки подключения к websocket и подписки на уведомления необходимо взять из текущего репозитория 
клиентское демонстрационное веб приложение. 
Оно находится в папке `websocket_demo` скачайте папку с содержимым и откройте `websocket_demo/index.html` 
в браузере. 

Нажимите кнопку "Сonnect" для подключения к сокету. И отправьте новость через сервис [News](#News). 
Как это сделать детально описано в [домашнем задании #6](#hw6addNews)

Публикация новости, запускает механизм отправки уведомлений всем родителям группы. 
Сервис [Notifier](#Notifier) получает список родителей и кладет сообщение для каждого родителя в
очередь, откуда ее разбирают различные агенты в том числе [Notifier Agent Websocket](#NotifierAgentWebsocket), 
который отправляет сообщения клиентам, подключенным к его сокету.    

В результате в таблице уведомлений на демо-страничке должно появиться уведомление об опубликованной новости   

![alt text](https://github.com/pleshakoff/pc-root/blob/master/screen/wsDemo_hw8.png?raw=true"")

Реализацию подключения можно посмотреть здесь `websocket_demo/js/app.js` 
Ну или здесь https://github.com/pleshakoff/pc-root/blob/master/websocket_demo/js/app.js 

Все настройки для демонстрации захардкодены непосредственно в джава-скрипте.
 
Предполагаеся что клиент залогинен, уже получил авторизационный jwt токен и знает идентификатор текущего пользователя.
На нашей демо страничке мы подписаны на уведомления для пользователя с идентификатором 1, это один из родителей группы.
Хотя пуши и отправляются сразу трем пользователям, онлайн только 1. 

Авторизация организована так. Неавторизованный пользователь может создать websocket соединение. 
После установки соединения он должен подписаться на рассылку. При подписке необходимо в заголовке stomp сообщения,
указать токен. Если это не будет сделано, то сервер разорвет сессию(я пока поставил таймаут 2 секунды). 

На сервере реализовно следующим образом. При хэндшейке создается сессия и помещается в список сессий,
ожидающих подтверждения. Для каждой сессии фиксируется время до которого ее надо подтвердить.
Если подписка состоялась и токен был верный, то сессия убирается из списка и считается подтвержденной. 
Если нет, то она будет прибита фоновым процессом, который мониторит список на предмет "expired" сессий.    

![alt text](https://github.com/pleshakoff/pc-root/blob/master/screen/log1hw8.1.png?raw=true"")          


<a name="hw6"></a>
## Домашнее задание №6 (кэш)

В качестве объекта для кэширования выбраны данные пользователей(родителей). 
Во первых, эти данные стабильны и меняются редко. 
Во вторых, одна из частых операций в системе это рассылка уведомлений, для которых нужны данные пользователя.
Уведомления рассылаются при добавлении новости, комментария, опроса, начала сбора средств и т.д.
Уведомления рассылаются агентами, каждый из которых отвечает за различные методы уведомлений: email, sms, 
сообщение в популярных соцсетях и прочее. 
Каждый агент автономен и каждому из них необходимы разные данные пользователя. 
Каждый агент запрашивает профиль пользователя-получателя у сервиса [Classroom](#Classroom) и использует те данные, 
которые ему нужны для формирования и отправки уведомления(например для отправки по почте email и имя, а для sms телефон). 
Если один агент запросил данные профиля пользователя, логично эти данные где-нибудь сохранить, 
чтобы агент, отправляющий уведомления другим способом мог ими воспользоваться. 
Также при отправке следующего уведомления этому же пользователью можно опять взять их из кэша. 

Кэш находится в сервисе [User cache](#UserCache) 
В качестве хранилища кэша используется Redis.  
Time to live выбрано: 10 минут. 
Также при изменении данных пользователя в сервисе [Classroom](#Classroom), сервису кэша [User cache](#UserCache) отправляется сообщение 
и кэш для измененного пользователя сбрасывается         
 
При росте объема данных кэш можно партиционировать, например по географическому признаку, 
в зависмости от того в каком регионе находится учебное заведение   
 
Для того чтобы проверить работу кэша, надо добавить новость, и уведомления будут отправлены всем родителям группы.
После этого надо посмотреть логи сервиса кэширования. 

Для развертывания сервисов необходимо выполнить `docker-compose up` из этого репозитория, запущены 
будут контейнеры с сервисами из публичного docker hub.(см. [Get started](#get-started))
 
<a name="hw6addNews"></a>
##### Добавить новость:


Сервис [News](#News) Swagger: http://localhost:8082/api/v1/swagger-ui.html

Контроллер `/news` метод `POST` 

Тестовый вечный токен для авторизации. Необходимо добавить в хидер запроса (X-Auth-Token)  
`eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbkBtYWlsLmNvbSIsInVzZXIiOiJhZG1pbkBtYWlsLmNvbSIsImlkVXNlciI6MSwiaWRHcm91cCI6MjEsImlkU3R1ZGVudCI6MzEsImF1dGhvcml0aWVzIjoiUk9MRV9BRE1JTiIsImlhdCI6MTU3NjMyMDc5NywiZXhwIjoxNjA3ODU2Nzk3fQ.qEfk5Jxdc7lNpJq_AF5gjn985FZMHhnHYNroM2Thu7kVz04OucBSEWcT0dKRHytWXmr6IsVX28BuNZEfN0Z8zg`

Тело запроса 

`
{
  "title": "Внимание! Важное сообщение!",
  "message": "Требуются родители для участия в добровольных состязаниях по бегу в мешках. Явка добровольцев обязательна"
}
`

После публикации новости уведомление будет отправлено в сервис [Notifier](#Notifier), 
который перенаправит его трем агентам  

##### Посмотреть логи

`docker-compose logs pc-user-cache`

Будет видно что при обращении к сервису [User cache](#UserCache) первого агента, 
вызов перенаправляется сервису [Classroom](#Classroom). 
При попытке второго агента получить данные того же самого пользователя, даннее берутся уже из кэша.  

Что-то вроде вот этого: 

![alt text](https://github.com/pleshakoff/pc-root/blob/master/screen/log1hw5.png?raw=true"")

Теперь можно обновить данные одного из пользователей 

Сервис [Classroom](#Classroom) Swagger: http://localhost:8080/api/v1/swagger-ui.html

Контроллер `/users/1` метод `PUT` 

Тестовый вечный токен для авторизации. Необходимо добавить в хидер запроса (X-Auth-Token)  
`eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbkBtYWlsLmNvbSIsInVzZXIiOiJhZG1pbkBtYWlsLmNvbSIsImlkVXNlciI6MSwiaWRHcm91cCI6MjEsImlkU3R1ZGVudCI6MzEsImF1dGhvcml0aWVzIjoiUk9MRV9BRE1JTiIsImlhdCI6MTU3NjMyMDc5NywiZXhwIjoxNjA3ODU2Nzk3fQ.qEfk5Jxdc7lNpJq_AF5gjn985FZMHhnHYNroM2Thu7kVz04OucBSEWcT0dKRHytWXmr6IsVX28BuNZEfN0Z8zg`

Тело запроса 

`
{
  "familyName": "Фамилия",
  "firstName": "Имя",
  "middleName": "Отчество",
  "phone": "+7 915 1234567"
}
`

Кэш для пользователя с идентификатором 1 будет сброшен. 

Если запостить еще одну новость и посмотреть лог,видно что данные для первого пользователя были сброшены, а данные остальных берутся из кэша  

![alt text](https://github.com/pleshakoff/pc-root/blob/master/screen/log2hw5.png?raw=true"")

<a name="hw7"></a>
## Домашнее задание №7 (очередь)

Добавлен брокер сообщений - Kafka.  

Чем был обусловлен выбор

Я выбирал rabbitMQ  или Kafka

1) В данной системе не нужны возможности RabbitMQ по затейливому роутингу сообщений. 
По сути нужны факты того что где-то что-то обновилось, 
а консьюмеры уже сами должны решать что с этим делать (dumb broker).

2) В выбранной архитектуре предполагается что есть некие источники знаний, 
например состав группы учеников и есть ряд потребителей факта изменения состава. 
В случае с RabbitMQ сообщение об изменении состава должно роутиться по нескольким очередям. 
Для каждого сервиса-подписчика своя очередь. Если добавится еще один сервис, которому нужен будет состав группы, 
надо будет переконфигурировать брокер
В случае с Kafka все сервисы читают из одного топика, просто для разных групп разное смещение.
3) То же самое с расылкой уведомлений пользователям, несколько агентов могут быть подписаны на один топик, 
при добавлении агента, это просто еще один подписчик, ничего изменять не надо.  
4) Одним из преимуществ Kafka считается то, что она более устойчива к нагрузкам и лучше масштабируется. 
При использования данной системы предполагается наличие сезонных нагрузок (сентябрь - начало учебы). 
В такие моменты можно увеличивать количество партиций в топике и количество инстансов подписчиков.
 

Ниже перечислены операции осуществляемые теперь по message-based протоколу 

1) Отправка уведомления сервисами 
2) Передача уведомления подписанным агентам 
3) Сообщение сервисам-подписчикам об изменении состава группы (удаление, доабавение ученика) НЕ РЕАЛИЗОВАНО 
4) Сообщение об удалении группы. НЕ РЕАЛИЗОВАНО 


Для развертывания сервисов необходимо выполнить `docker-compose up` из этого репозитория, запущены 
будут контейнеры с сервисами из публичного docker hub.(см. [Get started](#get-started))

Для того чтобы проверить работоспособность: необходимо  добавить новость так 
как это описано в [домашнем задании #6](#hw6addNews)

После этого можно посмотреть логи сервиса [Notifier](#Notifier),который берет соообщение из очереди,
определяет перечень получателей и помещает уведомление для каждого получателя в очередь, 
на которую подписаны агенты:  [Notifier Agent Email](#NotifierAgentEmail), [Notifier Agent Push](#NotifierAgentPush) и
[Notifier Agent Websocket](#NotifierAgentWebsocket)


[Notifier](#Notifier)
![alt text](https://github.com/pleshakoff/pc-root/blob/master/screen/log1hw6.png?raw=true"")


[Notifier Agent Email](#NotifierAgentEmail)
![alt text](https://github.com/pleshakoff/pc-root/blob/master/screen/log2hw6.png?raw=true"")
  
<a name="hw8"></a>
## Домашнее задание №8 (мониторнг)

Для развертывания сервисов необходимо выполнить `docker-compose up` из этого репозитория, запущены 
будут контейнеры с сервисами из публичного docker hub.(см. [Get started](#get-started))

Развернута система мониторинга с использование Prometheus и Grafana.
При развертывнии сервисов через docker_compose, поднимается подготовленый контейнер с настроенным 
демонстрационным дашбордом PARCOM

См главу [Мониторинг.](#monitoring) 
  
 

  