#!/bin/bash

while [[ $# -gt 0 ]]; do
    case "$1" in
        --zephyrBaseUrl)
            zephyrBaseUrl="$2"
            shift 2
            ;;
        --accessKey)
            accessKey="$2"
            shift 2
            ;;
        --secretKey)
            secretKey="$2"
            shift 2
            ;;
        --accountId)
            accountId="$2"
            shift 2
            ;;
        --taskName)
            taskName="$2"
            shift 2
            ;;
        --taskDescription)
            taskDescription="$2"
            shift 2
            ;;
        --automationFramework)
            automationFramework="$2"
            shift 2
            ;;
        --projectKey)
            projectKey="$2"
            shift 2
            ;;
        --versionName)
            versionName="$2"
            shift 2
            ;;
        --cycleName)
            cycleName="$2"
            shift 2
            ;;
        --folderName)
            folderName="$2"
            shift 2
            ;;
        --resultPath)
            resultPath="$2"
            shift 2
            ;;
        *)
            echo "Неизвестный аргумент: $1"
            exit 1
            ;;
    esac
done

# Логирование
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Проверка обязательных переменных
check_variables() {
    local required_vars=("zephyrBaseUrl" "accessKey" "secretKey" "accountId" "taskName" "projectKey" "versionName" "cycleName" "folderName" "resultPath")
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            log "Ошибка: Переменная $var не установлена."
            exit 1
        fi
    done
}

generate_jwt() {
    log "Генерация JWT токена..."
    local jwt_url="$zephyrBaseUrl/public/rest/api/1.0/jwt/generate"
    local jwt_response=$(curl -s -X POST -H "Content-Type: application/json" \
        --data "{
            \"accessKey\": \"$accessKey\",
            \"secretKey\": \"$secretKey\",
            \"accountId\": \"$accountId\",
            \"zephyrBaseUrl\": \"$zephyrBaseUrl\",
            \"expirationTime\": 360000
        }" \
        "$jwt_url")

    jwt=$(echo "$jwt_response" | jq -r '.token')
    if [ -z "$jwt" ]; then
        log "Ошибка: Не удалось сгенерировать JWT токен. Ответ: $jwt_response"
        exit 1
    fi

    log "JWT токен успешно создан."
}

create_and_execute_task() {
    log "Создание и выполнение задачи в Zephyr..."
    local task_url="$zephyrBaseUrl/public/rest/api/1.0/automation/job"
    local response=$(curl -s -X POST \
        -H "Content-Type: multipart/form-data" \
        -H "accessKey: $accessKey" \
        -H "jwt: $jwt" \
        -F "jobName=$taskName" \
        -F "jobDescription=$taskDescription" \
        -F "automationFramework=$automationFramework" \
        -F "projectKey=$projectKey" \
        -F "versionName=$versionName" \
        -F "cycleName=$cycleName" \
        -F "createNewCycle=true" \
        -F "appendDateTimeInCycleName=false" \
        -F "folderName=$folderName" \
        -F "createNewFolder=true" \
        -F "appendDateTimeInFolderName=true" \
        -F "file=@$resultPath" \
        "$task_url")

    if echo "$response" | jq -e '.error' > /dev/null; then
        log "Ошибка при выполнении задачи: $response"
        exit 1
    fi

    log "Задача успешно создана и выполнена. Ответ: $response"
}

main() {
    log "Начало выполнения интеграции с Zephyr..."
    check_variables
    generate_jwt
    create_and_execute_task
    log "Интеграция завершена."
}

main