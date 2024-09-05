#!/bin/bash

export PGPASSWORD=$DB_PASSWORD

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

readonly SENTRY_LOG_FILE=${SENTRY_LOG_FILE:-}

# Соглашения по вводу-выводу для этого скрипта:
# - Обычные сообщения о состоянии выводятся в STDOUT
# - STDERR используется только в случае фатальной ошибки
# - Подробные журналы записываются в этот FULL_LOG, который сохраняется в случае возникновения ошибки.
# - Самая последняя ошибка хранится в LAST_ERROR, которая никогда не сохраняется.
#  В этом коде происходит создание временных файлов для записи журнала (FULL_LOG) и последней ошибки (LAST_ERROR), а затем объявляются как переменные только для чтения (readonly).
FULL_LOG="$(mktemp -t outline_logXXX)"
LAST_ERROR="$(mktemp -t outline_last_errorXXX)"
readonly FULL_LOG LAST_ERROR

function log_command() {
  # Эта функция используется для выполнения команды и записи ее вывода в журнал (FULL_LOG). Она также сохраняет последнюю ошибку в файле LAST_ERROR
  # Направить STDOUT и STDERR в FULL_LOG и перенаправить STDOUT.
  # Самый последний вывод STDERR также будет сохранен в LAST_ERROR.
  "$@" > >(tee -a "${FULL_LOG}") 2> >(tee -a "${FULL_LOG}" > "${LAST_ERROR}")
}

  # Pretty печатает текст в стандартный вывод, а также записывает в файл журнала часового, если он установлен.
function log_start_step() {
  # Эта функция используется для вывода начала шага выполнения задачи.
  log_for_sentry "$@"  # Вызов другой функции log_for_sentry с переданными аргументами
  local -r str="> $*"  # Формирование строки, начинающейся с "> " и содержащей переданные аргументы
  local -ir lineLength=47  # Определение длины строки вывода
  echo -n "${str}"  # Вывод строки без перевода строки
  local -ir numDots=$(( lineLength - ${#str} - 1 ))  # Вычисление количества точек, которые нужно вывести после строки
  if (( numDots > 0 )); then  # Если количество точек больше нуля
    echo -n " "  # Вывод пробела после строки
    for _ in $(seq 1 "${numDots}"); do echo -n .; done  # Вывод указанного количества точек
  fi
  echo -n " "  # Вывод пробела после точек
}

  # Выводит $1 в качестве имени шага и запускает оставшуюся часть как команду.
  # STDOUT будет переадресован. STDERR будет регистрироваться автоматически, и
  # раскрывается только в случае фатальной ошибки.
function run_step() {
  # Эта функция выполняет шаг выполнения задачи и выводит соответствующее сообщение.
  local -r msg="$1"  # Сохранение первого аргумента в переменной msg
  log_start_step "${msg}"  # Вызов функции log_start_step с аргументом msg
  shift 1  # Сдвиг аргументов на 1 позицию влево, чтобы удалить первый аргумент
  if log_command "$@"; then  # Выполнение команды, передаваемой в качестве аргумента, и проверка ее выполнения
    echo "OK"  # Вывод строки "OK" в случае успешного выполнения команды
  else
    # Распространение кода ошибки
    return  # Возврат из функции с кодом ошибки
  fi
}

function confirm() {
  # Эта функция запрашивает подтверждение пользователя с вопросом, ожидая ответа "Y" или "n".
  echo -n "> $1 [Y/n] "  # Вывод вопроса пользователю с указанием вариантов ответа
  local RESPONSE  # Объявление локальной переменной RESPONSE
  read -r RESPONSE  # Считывание ответа пользователя и сохранение его в RESPONSE
  RESPONSE=$(echo "${RESPONSE}" | tr '[:upper:]' '[:lower:]') || return  # Преобразование ответа в нижний регистр и сохранение в RESPONSE; в случае ошибки возврат из функции
  [[ -z "${RESPONSE}" || "${RESPONSE}" == "y" || "${RESPONSE}" == "yes" ]]  # Проверка ответа: если RESPONSE пустой, или равен "y" или "yes", то вернет true, иначе false
}


function command_exists {
  command -v "$@" &> /dev/null
}

function log_for_sentry() {
  # Эта функция используется для ведения журнала сообщений в файл для системы мониторинга ошибок (например, Sentry) и в полный журнал.
  if [[ -n "${SENTRY_LOG_FILE}" ]]; then
    echo "[$(date "+%Y-%m-%d@%H:%M:%S")] install_server.sh" "$@" >> "${SENTRY_LOG_FILE}"
  fi
  echo "$@" >> "${FULL_LOG}"
}

# Установить ловушку, которая публикует тег ошибки только в случае ошибки.
function finish {
  # Эта функция выполняется в конце скрипта и используется для завершения работы и очистки временных файлов.
  # Наконец, функция удаляет временные файлы ${FULL_LOG} и ${LAST_ERROR}.
  #local -ir EXIT_CODE=$?
  #if (( EXIT_CODE != 0 )); then
    #if [[ -s "${LAST_ERROR}" ]]; then
      #log_error "\nLast error: $(< "${LAST_ERROR}")" >&2
    #fi
    #log_error "\nИзвините! Что-то пошло не так. Если вы не можете это понять, скопируйте и вставьте все эти выходные данные на экран Outline Manager и отправьте их нам, чтобы узнать, сможем ли мы вам помочь." >&2
    #log_error "Full log: ${FULL_LOG}" >&2
  #else
  rm "${FULL_LOG}"
  #fi
  rm "${LAST_ERROR}"
  }

##############################################################
                    #конец function_log_error# 
##############################################################



# Универсальная функция для загрузки файлов
download_file() {
    local url=$1
    local output_file=$2

    wget -q "$url" -O "$output_file"
    if [ $? -eq 0 ]; then
        echo "Файл $output_file успешно загружен."
    else
        echo "Ошибка при загрузке файла $output_file."
    fi
}

# Универсальная функция для сортировки и очистки загруженных файлов
sort_file() {
    local input_file=$1
    local output_file=$2

    # Форматируем полученные домены, удаляем строки, начинающиеся с # и www.
    sed '/^#/d' "$input_file" | sed '/^# /d' | sed '/^www./d' > "$output_file"

    # Удаляем временные файлы
    rm -rf "$input_file"
}

# Функция для загрузки всех списков
list_download_block() {
    log_info "list_download_block"
    
    # Загружаем все файлы
    download_file "https://raw.githubusercontent.com/im-sm/Pi-hole-Torrent-Blocklist/main/all-torrent-websites.txt" "all-torrent-websites.txt"
    download_file "https://raw.githubusercontent.com/SM443/Pi-hole-Torrent-Blocklist/main/all-torrent-trackres.txt" "all-torrent-trackers.txt"
    download_file "https://raw.githubusercontent.com/xdpalad/ip_block_list/main/api_palyer.txt" "api_palyer.txt"
    download_file "https://raw.githubusercontent.com/xdpalad/ip_block_list/main/custom.txt" "custom.txt"
}

# Функция для сортировки всех загруженных файлов
sort_list_block() {
    log_info "sort_list_block"
    
    # Сортировка и очистка загруженных файлов
    sort_file "all-torrent-websites.txt" "torrents_site.txt"
    sort_file "all-torrent-trackers.txt" "torrents_tracker.txt"
    sort_file "api_palyer.txt" "api_palyer_sorted.txt"
    sort_file "custom.txt" "custom_sorted.txt"
}

# Универсальная функция для преобразования доменов в IP-адреса и фильтрации
domains_to_ip() {
    local input_file=$1
    local output_file=$2

    # Используем xargs для асинхронного получения всех IP-адресов и записи только успешных результатов
    cat "$input_file" | xargs -P 10 -I {} bash -c '
        domain="{}"
        # Проверяем, если это уже IP
        if [[ $domain =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "$domain" >> '"$output_file"'
        else
            # Если это домен, пробуем получить IP через dig
            ip=$(dig +short "$domain" | grep -Eo "^[0-9.]+")
            if [ -n "$ip" ]; then
                echo "$ip" >> '"$output_file"'
            fi
        fi
    '

    # Удаляем временные файлы
    rm -rf "$input_file"

    # Удаляем дубликаты и фильтруем IP-адреса (фильтрация как в вашем примере)
    grep -v -E "^0\.0\.0\.0$|^127\.0\.0\.1$|^10\..*|^172\.(1[6-9]|2[0-9]|3[0-1])\..*|^192\.168\..*|^8\.8\.8\.8$|^8\.8\.4\.4$|^1\.1\.1\.1$|^1\.0\.0\.1$|^208\.67\.222\.222$|^208\.67\.220\.220$|^9\.9\.9\.9$|^149\.112\.112\.112$|^84\.200\.69\.80$|^84\.200\.70\.40$|^8\.26\.56\.26$|^8\.20\.247\.20$|^64\.6\.64\.6$|^64\.6\.65\.6$" "$output_file" | sort | uniq > "${output_file}_sorted.txt"

    # Перемещаем отфильтрованный файл обратно
    mv "${output_file}_sorted.txt" "$output_file"
}

# Преобразование доменов в IP для всех файлов
list_block_to_ip() {
    log_info "list_block_to_ip"
    domains_to_ip "torrents_site.txt" "ip_site.txt"
    domains_to_ip "torrents_tracker.txt" "ip_tracker.txt"
    domains_to_ip "api_palyer_sorted.txt" "ip_api_palyer.txt"
    domains_to_ip "custom_sorted.txt" "ip_custom.txt"
}

# Функции проверки IP-адресов
check_ip_file() {
    local input_file=$1

    # Создаем временный файл для хранения корректных IP-адресов
    > valid_"$input_file"
    
    # Проверяем каждый IP-адрес в файле
    while IFS= read -r ip; do
        if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            #```bash
            # Если IP-адрес корректен, добавляем его во временный файл
            echo "$ip" >> valid_"$input_file"
        else
            # Сообщаем о некорректном IP-адресе
            echo "Некорректный IP-адрес: $ip"
        fi
    done < "$input_file"
    
    # Перемещаем корректные IP-адреса обратно
    mv valid_"$input_file" "$input_file"
    
    echo "Проверка файла $input_file завершена. Все некорректные IP-адреса удалены."
}

check_ip_list() {
    log_info "check_ip_list"
    # Проверка файла ip_site.txt
    check_ip_file "ip_site.txt"
    # Проверка файла ip_tracker.txt
    check_ip_file "ip_tracker.txt"
    # Проверка файла ip_api_palyer.txt
    check_ip_file "ip_api_palyer.txt"
    # Проверка файла ip_custom.txt
    check_ip_file "ip_custom.txt"
}

# Универсальная функция для обновления IP-адресов в базе данных на основе файла
update_db_with_file() {
    local input_file=$1
    local ip_type=$2
    
    # Получаем текущие IP-адреса из базы данных для указанного типа
    current_ips=$(psql -U $DB_USER -d $DB_NAME -h $DB_IP -p $DB_PORT -t -c "SELECT ip_block FROM $TABLE_NAME WHERE ip_type = '$ip_type';" | sed '/^\s*$/d')

    # Читаем новые IP-адреса из файла
    new_ips=$(cat "$input_file" | tr ' ' '\n' | sort)
    
    # Сортировка списков IP-адресов
    current_ips=$(echo "$current_ips" | tr ' ' '\n' | sort)

    # Сортировка списков IP-адресов и удаление пустых строк и пробелов
    sorted_new_ips=$(echo "$new_ips" | sort | sed '/^$/d; s/^[ \t]*//;s/[ \t]*$//')
    sorted_current_ips=$(echo "$current_ips" | sort | sed '/^$/d; s/^[ \t]*//;s/[ \t]*$//')

    # Определяем IP-адреса для добавления и удаления
    ips_to_add=$(comm -23 <(echo "$sorted_new_ips") <(echo "$sorted_current_ips"))
    ips_to_del=$(comm -13 <(echo "$sorted_new_ips") <(echo "$sorted_current_ips"))
    
    # Добавляем новые IP-адреса в базу данных
    if [ -n "$ips_to_add" ]; then
        echo "Добавление новых IP-адресов в базу данных для типа $ip_type..."
        while IFS= read -r ip; do
            psql -q -U $DB_USER -d $DB_NAME -h $DB_IP -p $DB_PORT -c "INSERT INTO $TABLE_NAME (ip_block, ip_type) VALUES ('$ip', '$ip_type');"
        done <<< "$ips_to_add"
    else
        echo "Нет новых IP-адресов для добавления для типа $ip_type."
    fi

    # Удаляем старые IP-адреса из базы данных
    if [ -n "$ips_to_del" ]; then
        echo "Удаление старых IP-адресов из базы данных для типа $ip_type..."
        while IFS= read -r ip; do
            psql -q -U $DB_USER -d $DB_NAME -h $DB_IP -p $DB_PORT -c "DELETE FROM $TABLE_NAME WHERE ip_block = '$ip' AND ip_type = '$ip_type';"
        done <<< "$ips_to_del"
    else
        echo "Нет старых IP-адресов для удаления для типа $ip_type."
    fi

    # Удаляем временные файлы
    rm -rf "$input_file"
}

# Функция для вставки IP-адресов в базу данных
in_bd_ip() {  
    log_info "in_bd_ip"
    update_db_with_file "ip_site.txt" "torrent_site"
    update_db_with_file "ip_tracker.txt" "torrent_tracker"
    update_db_with_file "ip_api_palyer.txt" "api_player"
    update_db_with_file "ip_custom.txt" "custom"
}

# Основная функция
function main() {
  trap finish EXIT
  list_download_block    # Загружаем списки
  sort_list_block        # Форматируем загруженные списки
  list_block_to_ip       # Преобразуем домены в IP-адреса
  check_ip_list          # Проверяем корректность IP-адресов
  in_bd_ip               # Обновляем базу данных
}

main "$@"
