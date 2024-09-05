<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>

<h1>Проект Docker для автоматического управления списками блокировки IP</h1>

<p>Этот проект предоставляет возможность автоматического управления списками доменов и IP-адресов с использованием Docker-контейнера. Контейнер содержит скрипт на Bash, который загружает списки доменов, преобразует их в IP-адреса, фильтрует и обновляет базу данных PostgreSQL. Этот процесс автоматизирует управление нежелательными доменами и IP-адресами, что особенно полезно для системных администраторов и специалистов по информационной безопасности.</p>

<h2>Основные возможности</h2>

<ul>
    <li><strong>Интерактивный ввод параметров подключения к базе данных</strong>: Скрипт запрашивает параметры подключения к базе данных PostgreSQL и проверяет их на корректность.</li>
    <li><strong>Автоматическое создание Docker Compose файла</strong>: На основе введенных данных создается файл <code>docker-compose.yml</code> для запуска контейнера.</li>
    <li><strong>Запуск Docker контейнера с помощью Docker Compose</strong>: Контейнер запускается с помощью Docker Compose и включает все необходимые зависимости.</li>
    <li><strong>Логирование выполнения скрипта</strong>: Логи сохраняются в локальный файл <code>/var/log/in_bd_ip_block.log</code>.</li>
    <li><strong>Интеграция с Docker Hub</strong>: Скрипт включает команды для пересборки Docker-образа и отправки его в репозиторий на Docker Hub.</li>
</ul>

<h2>Как начать использование</h2>

<h3>Шаг 1: Клонирование репозитория и запуск скрипта для создания и запуска Docker контейнера</h3>

<pre><code>wget -q https://raw.githubusercontent.com/xdpalad/ip_block_list/main/script/up_docker_in_bd_ip_block.sh -O up_docker_in_bd_ip_block.sh && bash up_docker_in_bd_ip_block.sh && rm -f up_docker_in_bd_ip_block.sh
</code></pre>

<p>Скрипт запросит у вас следующие данные:</p>

<ul>
    <li>Имя базы данных (<code>DB_NAME</code>)</li>
    <li>IP-адрес базы данных (<code>DB_IP</code>)</li>
    <li>Имя пользователя базы данных (<code>DB_USER</code>)</li>
    <li>Порт базы данных (<code>DB_PORT</code>)</li>
    <li>Пароль пользователя базы данных (<code>DB_PASSWORD</code>)</li>
    <li>Имя таблицы в базе данных (<code>TABLE_NAME</code>)</li>
</ul>

<h3>Шаг 2: Проверка логов</h3>

<p>Для просмотра логов выполнения скрипта выполните команду:</p>

<pre><code>sudo docker logs in_bd_ip_block</code></pre>

<h3>Шаг 3: Интеграция с Docker Hub (необязательно)</h3>

<p>Вы можете использовать команды, предоставленные в скрипте, для пересборки Docker-образа и его отправки в репозиторий:</p>

<pre><code>wget https://raw.githubusercontent.com/xdpalad/ip_block_list/main/script/in_bd_ip_block.sh
wget https://raw.githubusercontent.com/xdpalad/ip_block_list/main/Dockerfile
</code></pre>

<pre><code>docker login
docker build -t in_bd_ip_block .
docker tag in_bd_ip_block xdpalad/in_bd_ip_block:latest
docker push xdpalad/in_bd_ip_block:latest
</code></pre>

<h2>Требования</h2>

<ul>
    <li>Установленные <code>Docker</code> и <code>Docker Compose</code>.</li>
    <li>Доступ к базе данных PostgreSQL с правильными учетными данными.</li>
</ul>

<h2>Заключение</h2>

<p>Этот проект предоставляет простой и автоматизированный способ управления списками доменов и IP-адресов с использованием Docker. Он легко разворачивается и масштабируется, что делает его полезным для системных администраторов и специалистов по информационной безопасности.</p>

</body>
</html>
