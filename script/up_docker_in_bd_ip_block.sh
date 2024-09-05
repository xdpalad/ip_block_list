#!/bin/bash

xdpalad_art="
\033[0;34m 
            ██╗  ██╗██████╗ ██████╗  █████╗ ██╗      █████╗ ██████╗ 
            ╚██╗██╔╝██╔══██╗██╔══██╗██╔══██╗██║     ██╔══██╗██╔══██╗
             ╚███╔╝ ██║  ██║██████╔╝███████║██║     ███████║██║  ██║
             ██╔██╗ ██║  ██║██╔═══╝ ██╔══██║██║     ██╔══██║██║  ██║
            ██╔╝ ██╗██████╔╝██║     ██║  ██║███████╗██║  ██║██████╔╝
            ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ 
\033[0m"
# Вывести ASCII-арт
# https://www.asciiart.eu/text-to-ascii-art
echo -e "$xdpalad_art"


function log_info() {
  # Эта функция используется для вывода сообщения об ошибке в зеленом цвете и записи его в файл FULL_LOG.
  local -r INFO_TEXT="\033[0;32m"  # green
  local -r NO_COLOR="\033[0m"
  echo -e "${INFO_TEXT}$1${NO_COLOR}"
}

function log_error() {
  # Эта функция используется для вывода сообщения об ошибке в красном цвете и записи его в файл FULL_LOG.
  local -r ERROR_TEXT="\033[0;31m"  # red
  local -r NO_COLOR="\033[0m"
  echo -e "${ERROR_TEXT}$1${NO_COLOR}"
}

#!/bin/bash

# Функция для проверки ввода имени базы данных, имени пользователя и таблицы (только буквы и цифры)
validate_string() {
  if [[ "$1" =~ ^[a-zA-Z0-9_]+$ ]]; then
    return 0  # Валидный ввод
  else
    return 1  # Невалидный ввод
  fi
}

# Функция для проверки IP-адреса
validate_ip() {
  if [[ "$1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    # Дополнительная проверка, что каждое октет в диапазоне 0-255
    IFS='.' read -r -a octets <<< "$1"
    for octet in "${octets[@]}"; do
      if ((octet < 0 || octet > 255)); then
        return 1  # Невалидный IP-адрес
      fi
    done
    return 0  # Валидный IP-адрес
  else
    return 1  # Невалидный IP-адрес
  fi
}

# Функция для проверки порта (число от 1 до 65535)
validate_port() {
  if [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ] && [ "$1" -le 65535 ]; then
    return 0  # Валидный порт
  else
    return 1  # Невалидный порт
  fi
}

# Функция для запроса ввода и проверки валидности
get_input() {
  local prompt="$1"
  local var_name="$2"
  local validation_function="$3"

  while true; do
    read -p "$prompt" input
    if $validation_function "$input"; then
      eval "$var_name='$input'"
      break
    else
      log_error "Неверный ввод. Попробуйте еще раз."
    fi
  done
}

# Запрос данных с проверкой
log_info "Вас приветсвует мастер установки, заполните данные для подключения:"
get_input "Введите название базы данных (DB_NAME): " DB_NAME validate_string
get_input "Введите IP адрес базы данных (DB_IP): " DB_IP validate_ip
get_input "Введите имя пользователя базы данных (DB_USER): " DB_USER validate_string
get_input "Введите порт базы данных (DB_PORT): " DB_PORT validate_port

# Ввод пароля (не проверяется на валидность, но скрыт)
read -sp "Введите пароль пользователя базы данных (DB_PASSWORD): " DB_PASSWORD
echo  # Пустая строка для форматирования

# Запрос имени таблицы с проверкой
get_input "Введите имя таблицы базы данных (TABLE_NAME): " TABLE_NAME validate_string

sudo touch /var/log/in_bd_ip_block.log
sudo chmod 666 /var/log/in_bd_ip_block.log  # Даем разрешение на запись в этот файл

# Создание файла docker-compose.yml
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  update-bd:
    image: xdpalad/in_bd_ip_block:latest  # Укажите ваш образ, опубликованный на Docker Hub
    container_name: in_bd_ip_block
    environment:
      - DB_NAME=$DB_NAME
      - DB_IP=$DB_IP
      - DB_USER=$DB_USER
      - DB_PORT=$DB_PORT
      - DB_PASSWORD=$DB_PASSWORD
      - TABLE_NAME=$TABLE_NAME
    network_mode: "host"  # Используем сеть хоста для доступа к локальной базе данных
    volumes:
      - /var/log/in_bd_ip_block.log:/var/log/in_bd_ip_block.log  # Пример монтирования тома для логов

EOF

echo "Файл docker-compose.yml успешно создан."

# Запуск Docker Compose
docker-compose up -d

echo "Контейнер запущен с использованием Docker Compose."
