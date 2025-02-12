#!/usr/bin/env groovy

def call(Map params = [:]) {
    String scriptName = 'zefir-upload.sh'

    // загрука скрипта
    String scriptBody = libraryResource("resources/${scriptName}")

    // сохрания скрипта в директорию
    writeFile(file: scriptName, text: scriptBody)

    sh "chmod +x ${scriptName}"

    // Запуск скрипта передача параметров
    sh """
        ./${scriptName} \
        --zephyrBaseUrl "${params.zephyrBaseUrl}" \
        --accessKey "${params.accessKey}" \
        --secretKey "${params.secretKey}" \
        --accountId "${params.accountId}" \
        --taskName "${params.taskName}" \
        --taskDescription "${params.taskDescription}" \
        --automationFramework "${params.automationFramework}" \
        --projectKey "${params.projectKey}" \
        --versionName "${params.versionName}" \
        --cycleName "${params.cycleName}" \
        --folderName "${params.folderName}" \
        --resultPath "${params.resultPath}"
    """
}