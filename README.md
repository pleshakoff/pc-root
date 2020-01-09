# Родительский комитет

1. [Описание системы](#desc)
2. [Логическая структура](#struct)
3. [Сервисы](#service)
4. [Get started.](#get-started)


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


![alt text](https://github.com/pleshakoff/pc-root/blob/hw3/pics/parcom_hw3.1.png?raw=true"")


Во всех сервисах работа ведется в контексте текущего ученика. Данные о текущем ученике пользователя 
зашифрованы в "self contained" токене, 
который формируется сервисом авторизации [Security](#Security) и должен передваться во все запросы к сервисам.

Валидация токена осуществляется на стороне сервисов(sidecar).  

Авторизация тоже на стороне сервисов, путем определения доступа к методам для роли из токена
(у пользователя может быть всего одна роль и ее можно передать в токене)

Сервисы [Polls](#Polls) и [Money](#Money) есть на схеме, но они ее не реализованы. 
Также все взаимодействие осуществляется в синхронном режиме, брокеров сообщений и очередей нет. 

<a name="service"></a>
## Сервисы

* [ Security](#Security)
* [Classroom](#Classroom)
* [News](#News)
* [Polls](#Polls)
* [Money](#Money)
* [Notifier](#Notifier)
* [Notifier Agent Email](#NotifierAgentEmail)
* [Notifier Agent Push](#NotifierAgentPush)

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
 [Security](#Security). Если вызов неудачен, то создание нового родителя или группы откатывается.   
 
 2. При удалении пользователя(родителя) (DELETE ​/users/{id}) вызывает метод удаления (DELETE ​/users​/{id}) 
 учетной записи сервиса  [Security](#Security). Если вызов неудачен, то удаление откатывается.  
 
 3. Является поставщиком информаци о списке учеников. 
 При удалении или добавалениее ученика отправляет сообщение в брокер сообщений для синхронизации 
 со списками учеников сервисах-потребителях. (Не реализовано) 
 

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
 
 1. При публикации новости (POST​/news) вызывает метод сервиса [Notifier](#Notifier), 
 рассылающий групповое сообщение (POST ​/send​/group). Новость публикуется незвисимо от 
 того, удачно ли прошла рассылка уведомления. В текущей реализации взаимодействие синхронное, 
 в дальйшем планируется использовать брокер сообщений.  
 2. Получение через брокер сообщений сигнала об удалении группы от сервиса [Classroom](#Classroom). 


<a name="Polls"></a>
### Polls  

**НЕ РЕАЛИЗОВАН** 

Сервис предназначен для проведения отпросов среди родителей группы.

* создание опроса 
* выбор учеников для опроса 
* голосование 

#### Взаимодействие с другими сервисами     

 1. При создании опроса, если он общегрупповой, у сервиса запрашивается текущий состав группы,
 прямым обращением к сервису [Classroom](#Classroom) и список учеников, привязывается к опросу. 
 
 2. Через брокер сообщений список учеников в активных опросах синхронизируется со списком учеников 
 группы, поставляемым сервисом [Classroom](#Classroom). Если в группе появился новый ученик, 
 то он добавляется в активные общегрупповые опросы. Если удаляется ученик, то он удаляется из любых активных 
 опросов.
 
 3. Получение через брокер сообщений сигнала об удалении группы от сервиса [Classroom](#Classroom). 
    
 4. При публикации опроса вызывается метод сервиса [Notifier](#Notifier), 
 рассылающий групповое сообщение (POST ​/send​/group) или сообщение списку пользователей, 
 участников опроса (POST ​/send​/custom). 
 Опрос публикуется незвисимо от того, удачно ли прошла рассылка уведомления. 
 В текущей реализации взаимодействие синхронное, в дальйшем планируется использовать брокер сообщений.
 

<a name="Money"></a>
### Money  

**НЕ РЕАЛИЗОВАН** 

Сервис учета денежных средств группы 

* управления целями сбора средств 
* учет входящих транзакций  
* учет исходящих транзакций
* выборки для отчетов (остатки, должники) 
 
#### Взаимодействие с другими сервисами    

 1. При создании цели сбора средств, если она общегрупповая, у сервиса запрашивается текущий состав группы,
 прямым обращением к сервису [Classroom](#Classroom) и список учеников, привязывается к цели. 
 
 2. Через брокер сообщений список учеников в активных сборах средств синхронизируется со списком учеников 
 группы, поставляемым сервисом [Classroom](#Classroom). Если в группе появился новый ученик, 
 то он добавляется в активные общегрупповые сборы. Если удаляется ученик, то он удаляется из любых активных 
 сборов.
 
 3. Получение через брокер сообщений сигнала об удалении группы от сервиса [Classroom](#Classroom). 

 4. При публикации цели сбора средств вызывает метод сервиса [Notifier](#Notifier),
 рассылающий групповое (POST ​/send​/group) сообщение или сообщение списку пользователей, 
 участников сбора (POST ​/send​/custom). 
 Новость публикуется незвисимо от того, удачно ли прошла рассылка уведомления. 
 В текущей реализации взаимодействие синхронное, 
  в дальйшем планируется использовать брокер сообщений.


<a name="Notifier"></a>
### Notifier  

Репозиторий: https://github.com/pleshakoff/pc-notifier

Swagger: http://localhost:8083/api/v1/swagger-ui.html

Сервис отвечает за отправку уведомлений. Содержит список агентов.
Рассылает уведомления в едином формате различным агентам

Поддерживает три вида уведомлений 

* Для всей группы. 
* Для отдельного пользователя 
* Для списка пользователей     

В зависимости от типа уведомления формирует список пользователей получателй и передает идентификатор
каждого зарегистрированым агентам.   

1. Если сообщение общегрупповое (POST ​/send​/group), то запрашивает идентификаторы пользователей(родителей)
группы у сервиса [Classroom](#Classroom) (GET ​/users​/all)
 
2. Переправляет сообщение и идентифиаторы пользователей получателей зарегистрирвоанным агентам, вызывая их метод
(POST ​/send​/) В текущей реализации взаимодействие синхронное, в дальйшем планируется использовать брокер сообщений.


<a name="NotifierAgentEmail"></a>
### Notifier Agent Email    

Репозиторий: https://github.com/pleshakoff/pc-notifier-agent-email

Swagger: http://localhost:8084/api/v1/swagger-ui.html

Отправка письма пользователю. 

#### Взаимодействие с другими сервисами     
  
1. Получает  идентификатор пользователя и текст сообщения от сервиса [Notifier](#Notifier), запрашивает email пользователя 
у сервиса [Classroom](#Classroom) (GET ​/users​/{id}) и отправляет письмо (в текущей версии просто пишет в лог) 

<a name="NotifierAgentPush"></a>
### Notifier Agent Push    

Репозиторий: https://github.com/pleshakoff/pc-notifier-agent-push

Swagger: http://localhost:8085/api/v1/swagger-ui.html

#### Взаимодействие с другими сервисами     
  
1. Получает  идентификатор пользователя и текст сообщения от сервиса [Notifier](#Notifier), запрашивает телефон пользователя 
у сервиса [Classroom](#Classroom) (GET ​/users​/{id}) и отправляет смс (в текущей версии просто пишет в лог) 



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
с необходимой зашифрованной информацией и они регистриуются перейдя по ссылке в письме.
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
  