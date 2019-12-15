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

Член родительского комитета может создать опрос. Пока запрос активен родители могут выбрать один из вариантов ответов,
или поменять свой вариант. После закрытия опроса менять, ничего нельзя. 
Количестово голосующих равно количеству учеников в группе. 
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


![alt text](https://github.com/pleshakoff/pc-root/blob/hw3/pics/parcom_hw3.png?raw=true"")


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
Swagger: http://localhost:8081/swagger-ui.html

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

Swagger: http://localhost:8080/swagger-ui.html

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

Swagger: http://localhost:8082/swagger-ui.html

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
 

<a name="Polls"></a>
### Polls  

**НЕ РЕАЛИЗОВАН** 

Сервис предназначен для проведения отпросов среди родителей группы. 

* создание опроса 
* голосование 

#### Взаимодействие с другими сервисами     
 
 1. Через брокер сообщение синхронизируется со списком учеников 
 группы, поставляемым сервисом [Classroom](#Classroom)
 
 2. При публикации опроса вызывает метод сервиса [Notifier](#Notifier), 
 рассылающий групповое (POST ​/send​/group) сообщение или сообщение списку пользователей, 
 участников опроса (POST ​/send​/custom). 
 Новость публикуется незвисимо от того, удачно ли прошла рассылка уведомления. 
 В текущей реализации взаимодействие синхронное, 
  в дальйшем планируется использовать брокер сообщений.
 

<a name="Money"></a>
### Money  

**НЕ РЕАЛИЗОВАН** 

Сервис учета денежных средств группы 

* управления целями сбора средств 
* учет входящих транзакций  
* учет исходящих транзакций
* выборки для отчетов (остатки, должники) 
 
#### Взаимодействие с другими сервисами     
 
 1. Через брокер сообщение синхронизируется со списком учеников 
 группы, поставляемым сервисом [Classroom](#Classroom)
 
 2. При публикации цели сбора средств вызывает метод сервиса [Notifier](#Notifier) ,
 рассылающий групповое (POST ​/send​/group) сообщение или сообщение списку пользователей, 
 участников сбора (POST ​/send​/custom). 
 Новость публикуется незвисимо от того, удачно ли прошла рассылка уведомления. 
 В текущей реализации взаимодействие синхронное, 
  в дальйшем планируется использовать брокер сообщений.


<a name="Notifier"></a>
### Notifier  

Репозиторий: https://github.com/pleshakoff/pc-notifier

Swagger: http://localhost:8083/swagger-ui.html

Сервис отвечает за отправку уведомлений. Содержит список агентов.
Рассылает уведомления в едином формате различным агентам

Поддерживает три вида уведомлений 

* Для всей группы. 
* Для отдельного пользователя 
* Для списка пользователей     

В зависимост от типа уведомления формирует список пользователей получателй и передает идентификатор
каждого зарегистрированым агентам.   

1. Если сообщение общегрупповое (POST ​/send​/group), то запрашивает идентификаторы пользователей(родителей)
группы у сервиса [Classroom](#Classroom) (GET ​/users​/all)
 
2. Переправляет сообщение и идентифиаторы пользователей получателей зарегистрирвоанным агентам 
(POST ​/send​/) В текущей реализации взаимодействие синхронное, в дальйшем планируется использовать брокер сообщений.


<a name="NotifierAgentEmail"></a>
### Notifier Agent Email    

Репозиторий: https://github.com/pleshakoff/pc-notifier-agent-email

Swagger: http://localhost:8084/swagger-ui.html

Отправка письма пользователю. 

#### Взаимодействие с другими сервисами     
  
1. Получает  идентификатор пользователя и текст сообщения от сервиса [Notifier](#Notifier), запрашивает email пользователя 
у сервиса [Classroom](#Classroom) (GET ​/users​/{id}) и отправляет письмо (в текущей версии просто пишет в лог) 

<a name="NotifierAgentPush"></a>
### Notifier Agent Push    

Репозиторий: https://github.com/pleshakoff/pc-notifier-agent-push

Swagger: http://localhost:8085/swagger-ui.html

#### Взаимодействие с другими сервисами     
  
1. Получает  идентификатор пользователя и текст сообщения от сервиса [Notifier](#Notifier), запрашивает телефон пользователя 
у сервиса [Classroom](#Classroom) (GET ​/users​/{id}) и отправляет смс (в текущей версии просто пишет в лог) 



<a name="get-started"></a>
## Get started 

Для развертывания сервисов необходимо выполнить `docker-compose up` из этого репозитория, запущены 
будут контейнеры с сервисами из публичного docker hub.

Для того чтобы проверить отправку сообщений необходимо сделать следующее: 

##### Запостить какую либо новость: 

Сервис classroom. Swagger: http://localhost:8080/swagger-ui.html

Контроллер `/news` метод `POST` 

Тестовый вечный токен для авторизации. Необходимо добавить в хидер запроса (X-Auth-Token)  
`eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbkBtYWlsLmNvbSIsInVzZXIiOiJhZG1pbkBtYWlsLmNvbSIsImlkVXNlciI6MSwiaWRHcm91cCI6MjEsImF1dGhvcml0aWVzIjoiUk9MRV9BRE1JTiIsImlhdCI6MTU3NTgxNTA5OCwiZXhwIjoxNjA3MzUxMDk4fQ.q5Dv3rnzrfc7IXE2HoTK7wTCsgamAMcROBUYOtSOOocgpxFN5dRzpJadbSr4Zh9xZRihFTUQOaInPGqhasoGLA`

Тело запроса 

`{
  "title": "Внимание! Важное сообщение! ",
  "message": "Требуются добровольцы для украшения елки в классе"
}
`
##### Посмотреть логи

После отправки надо посмотреть логи сервиса notifier

`docker-compose logs pc-notifier`

Будет видно что для каждого родителя отправлено уведомление через двух агентов 

Что-то вроде вот этого: 

![alt text](https://github.com/pleshakoff/pc-root/blob/hw2/screen/log1hw2.png?raw=true"")



Потом можно посмотреть логи агентов: 

 `docker-compose logs pc-notifier-agent-email`
 
 `docker-compose logs pc-notifier-agent-push`
  
![alt text](https://github.com/pleshakoff/pc-root/blob/hw2/screen/log2hw2.png?raw=true"")


