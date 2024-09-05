<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>README</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            background-color: #f9f9f9;
            color: #333;
        }
        h1, h2, h3 {
            color: #0b3d91;
        }
        code {
            background-color: #f4f4f4;
            padding: 2px 4px;
            border-radius: 4px;
            font-size: 0.9em;
        }
        pre {
            background-color: #f4f4f4;
            padding: 10px;
            border-radius: 4px;
            overflow-x: auto;
        }
        blockquote {
            background-color: #f4f4f4;
            padding: 10px 20px;
            margin: 20px 0;
            border-left: 5px solid #ccc;
        }
        .highlight {
            color: #d9534f;
        }
    </style>
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
</ul>

<h2>Как начать использование</h2>

<h3>Шаг 1: Клонирование репозитория</h3>

<pre><code>git clone https://github.com/xdpalad/docker-ip-block-manager.git
cd docker-ip-block-manager
</code></pre>

<h3>Шаг 2: Запуск скрипта для создания и запуска Docker контейнера</h3>

<pre><code>bash setup_docker_container.sh</code></pre>

<p>Скрипт запросит у вас следующие данные:</p>

<ul>
    <li>Имя базы данных (<code>DB_NAME</code>)</li>
    <li>IP-адрес базы данных (<code>DB_IP</code>)</li>
    <li>Имя пользователя базы данных (<code>DB_USER</code>)</li>
    <li>Порт базы данных (<code>DB_PORT</code>)</li>
    <li>Пароль пользователя базы данных (<code>DB_PASSWORD</code>)</li>
    <li>Имя таблицы в базе данных (<code>TABLE_NAME</code>)</li>
</ul>

<h3>Шаг 3: Проверка логов</h3>

<p>Для просмотра логов выполнения скрипта выполните команду:</p>

<pre><code>tail -f /var/log/in_bd_ip_block.log</code></pre>

<h2>Требования</h2>

<ul>
    <li>Установленные <code>Docker</code> и <code>Docker Compose</code>.</li>
    <li>Доступ к базе данных PostgreSQL с правильными учетными данными.</li>
</ul>

<h2>Безопасность</h2>

<ul>
    <li>Убедитесь, что пароль для базы данных не сохраняется в открытом виде.</li>
    <li>Логи выполнения могут содержать конфиденциальную информацию; убедитесь, что доступ к ним ограничен.</li>
</ul>

<h2>Заключение</h2>

<p>Этот проект предоставляет простой и автоматизированный способ управления списками доменов и IP-адресов с использованием Docker. Он легко разворачивается и масштабируется, что делает его полезным для системных администраторов и специалистов по информационной безопасности.</p>

</body>
</html>
