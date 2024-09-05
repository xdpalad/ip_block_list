# Используем базовый образ Ubuntu
FROM ubuntu:latest

# Устанавливаем зависимости
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    cron \
    postgresql-client \
    dnsutils \
    bash

# Копируем ваш скрипт в контейнер
COPY in_bd_ip_block.sh /root/in_bd_ip_block.sh

# Делаем скрипт исполняемым
RUN chmod +x /root/in_bd_ip_block.sh

# Настройка cron для запуска скрипта раз в сутки
RUN echo "0 0 * * * root /bin/bash /root/in_bd_ip_block.sh >> /var/log/in_bd_ip_block.log 2>&1" > /etc/cron.d/in_bd_ip_block

# Настройка cron для очистки файла лога раз в неделю (каждое воскресенье в полночь)
RUN echo "0 0 * * 0 root > /var/log/in_bd_ip_block.log" >> /etc/cron.d/in_bd_ip_block

# Даем права на выполнение cron файла
RUN chmod 0644 /etc/cron.d/in_bd_ip_block

# Убедитесь, что файл лога существует и имеет нужные права доступа
RUN touch /var/log/in_bd_ip_block.log && chmod 666 /var/log/in_bd_ip_block.log

# Убедитесь, что cron может писать PID-файлы и выполнять задания
RUN mkdir -p /var/run/cron && chmod 755 /var/run/cron

# Запуск скрипта при запуске контейнера, затем запуск cron и просмотр логов
CMD ["sh", "-c", "/root/in_bd_ip_block.sh && cron && tail -f /var/log/in_bd_ip_block.log"]