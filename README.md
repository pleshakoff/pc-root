# Родительский комитет

## Описание системы. 
Система предназначена для автоматизации работы родительского комитета в школе или детском саду.

##### Доступный функционал на текущий момент: 

* Авторизация и аутентификация. 
* Регистрация класса и учебного заведения
* Управление списком учеников
* Регистрация родителей и привязка к ученикам
* Публикация и чтение новостей
* Рассылка уведомлений родителям учеников
* Проведение опросов среди родителй
* Учет сбора денег

Работа в системе для каждого пользователя ведется в рамках рабочего пространства (группы или класса). 
Пользователи могут быть трех видов 
* Администратор 
* Член родительского комитета 
* Родитель

Для организации родительского комитета  в системе необходимо создать свою группу и пригласить туда других пользователей.
Пользователь, создавший группу, получает роль "Администратор" и может приглашать других членов родительского комитета или просто родителей.
Остальные пользователи могут присоединиться только получив приглашение от администратора или от члена родительского комитета.

На текущий момент для того чтобы зарегистрироваться как член родительского комитета, достаточно знать идентификтор класса.
Для того чтобы зарегистрироваться как родитель, надо знать идентификатор ученика.

Один и тот же пользователь может быть членом несеольких групп.(как в slack)  

В рамках группы, членами родительского комитета формируется список ученников. 
К одному ученику может быть привязано бесконечное количество пользователей.
Пользователь может быть родителем нескольких учеников группы . 
Весь список класса видят только члены родительского комитета.
Обычный родитель может видеть только своих детей. 

Члены родительского комитета могут публиковать  новости. 
Обычные пользователи имеют доступ к ленте новостей. 
При публикации новости всем пользователям(родителям) рассылаются уведомления 

Член родительского комитета может создать опрос. Пока запрос открыт родители могут выбрать один из вариантов ответов,
или поменять свой вариант. После закрытия опроса менять, ничего нельзя. Количестово голосующих равно количествоу учеников в группе. 
Каждый родитель может голосовать за ученика,к кторому он привязан. Если к ученику привязано несколько родителей, 
то оба могут менять результат, но только за своего ребенка.
Опросы могут быть публичные и анонимные. При созданнии опроса рассылаются уведомления. 

Для управления финансами родительского комитета в системе вводится понятие "Цель". 
В рамках цели задается необходимая сумма и перечень учеников, которые учавствуют в достиженнии цели. 
Например на цель - "нужды класса" должны сдать все, а на цель "экскурсия" только часть учеников.
В рамках цели учитываются входящие платежи от учеников и исходящие с описанием на что потрачено и аттачем чека.
Член родительского комитета вносят данные о приходах и расходах и видят все движение по всем целям. 
Обычные родители вядит доступные им цели, общую сумму цели и расходы.
Для членов родительского комитета доступны отчеты: списки должников, расходы по периодам и.т.д 
При формировании новой цели родителям детей рассылаются уведомления.  
            

## Логическая структура 

![alt text](https://github.com/pleshakoff/pc-root/blob/hw3/pics/parcom_hw3.png?raw=true"")



### Сервисы

#### Security 

https://github.com/pleshakoff/pc-security/tree/hw2

http://localhost:8081/swagger-ui.html

Сервис управления учетными записями 

* Регистрация и хранение учетных записей 
* Аутентификация 
* Формирование "self contained" токена со сроком действия.
* Смена пароля 
* Подтверждение регистрации 
    
Валидация токена осуществляется на стороне сервисов(sidecar).  
Авторизация тоже на стороне сервисов, путем определения доступа к методам для роли из токена.
У пользователя может быть всего одна роль и ее можно передать в токене.

#### Classroom 

https://github.com/pleshakoff/pc-classroom/tree/hw2

http://localhost:8080/swagger-ui.html


Сервис отвечает за управление рабочим пространством родительского комитета.

* Регистрация группы/класса
* Управление списком учащихся
* Регистрация родителей 
* Привязка родителей к ученикам
* Публикация новостей (переедет в отдельный сервис)  

#### Notifier  

https://github.com/pleshakoff/pc-notifier/tree/hw2

http://localhost:8083/swagger-ui.html

Сервис отвечает за отправку уведомлений. Содержит список агентов.
Рассылает уведомления в едином формате различным агентам

Поддерживает три вида уведомлений 

* Для всей группы. 
* Для отдельного пользователя 
* Для списка пользователей     

В зависимост от типа уведомления формирует список пользователей получателй  и передает идентификатор
каждого зарегистрированым агентам.   

#### Notifier Agent Email    

https://github.com/pleshakoff/pc-notifier-agent-email/tree/hw2

http://localhost:8084/swagger-ui.html

Отправка письма пользователю. 
Получает  идентификатор пользователя и текст сообщения от сервиса Notifier, запрашивает email 
у сервиса Classroom и отправляет письмо (в текущей версии просто пишет в лог) 

#### Notifier Agent Push    

https://github.com/pleshakoff/pc-notifier-agent-push/tree/hw2

http://localhost:8085/swagger-ui.html

Отправка пуш-уведомления пользователю. 
Получает  идентификатор пользователя и текст сообщения от сервиса Notifier, запрашивает номер телефона(допустим он нужен)  
у сервиса Classroom и отправляет push или sms (в текущей версии просто пишет в лог) 

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


