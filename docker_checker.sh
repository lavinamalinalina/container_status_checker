#!/bin/bash

LOG_FILE="/home/arsadaul/container.log"

# Создаем лог-файл, если его нет
touch "$LOG_FILE"

# динамический KV массив, отслеживающий текущее состояние контейнера
declare -A prev_status

# функция для записи сообщения в лог
log_message() {
  echo "$(date +%Y-%m-%d\ %H:%M:%S.%N): $1" >> "$LOG_FILE"
}

while true; do
  # Получаем статус всех контейнеров
  container_status=$(docker ps -a --format '{{.Names}}:{{.State}}:{{.ID}}')

  # читаем каждую строку и разбираем её на атрибуты контейнера
  while IFS=':' read -r name status ID; do
    prev_status_cont="${prev_status[$ID]}"

    # если статус контейнера НЕ running и НЕ совпадает с предыдущим, пишем лог
    if [ "$status" != "running" ] && [ "$status" != "$prev_status_cont" ]; then
      log_message "Container '$name' with ID: '$ID' changed status to '$status'"
    fi

    # обновляем текущий статус
    prev_status["$ID"]=$status
  done <<< "$container_status"

  # задержка перед следующей проверкой
  sleep 1
done
