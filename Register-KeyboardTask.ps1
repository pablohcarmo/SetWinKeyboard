#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Cria uma tarefa agendada para executar o script de configuração de layouts de teclado.

.DESCRIPTION
    Este script cria uma tarefa agendada que:
    - Executa no logon do usuário
    - Executa novamente a cada hora
    - Executa o script Set-KeyboardLayouts.ps1
#>

$taskName = "ConfigureKeyboardLayouts"
$scriptPath = Join-Path $PSScriptRoot "Set-KeyboardLayouts.ps1"
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

Write-Host "Criando tarefa agendada: $taskName" -ForegroundColor Cyan
Write-Host "Script a ser executado: $scriptPath" -ForegroundColor Yellow
Write-Host "Usuário: $currentUser" -ForegroundColor Yellow

# Verifica se o script existe
if (-not (Test-Path $scriptPath)) {
    Write-Host "❌ Erro: Set-KeyboardLayouts.ps1 não encontrado em $scriptPath" -ForegroundColor Red
    exit 1
}

# Remove a tarefa existente, se houver
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "`nRemovendo tarefa existente..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# Define a ação — executar PowerShell com o script
$action = New-ScheduledTaskAction `
    -Execute "pwsh.exe" `
    -Argument "-NoProfile -WindowStyle Minimized -ExecutionPolicy Bypass -File `"$scriptPath`""

# Define os gatilhos
# Gatilho 1: No logon do usuário
$triggerLogon = New-ScheduledTaskTrigger -AtLogOn -User $currentUser

# Gatilho 2: A cada hora (recorrente)
$triggerHourly = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval ` (New-TimeSpan -Hours 3)

# Combina os gatilhos
$triggers = @($triggerLogon, $triggerHourly)

# Define o principal (executar com privilégios elevados)
$principal = New-ScheduledTaskPrincipal -UserId $currentUser -LogonType Interactive -RunLevel Highest

# Define configurações adicionais
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 5)

# Registra a tarefa agendada
try {
    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $action `
        -Trigger $triggers `
        -Principal $principal `
        -Settings $settings `
        -Description "Configura layouts de teclado para en-US e pt-BR no logon e a cada hora" `
        -Force | Out-Null
    
    Write-Host "`n✅ Tarefa agendada criada com sucesso!" -ForegroundColor Green
    Write-Host "`nDetalhes da tarefa:" -ForegroundColor Yellow
    Write-Host "  Nome: $taskName"
    Write-Host "  Gatilhos:"
    Write-Host "    - No logon do usuário"
    Write-Host "    - A cada hora (recorrente)"
    Write-Host "  Ação: Executar Set-KeyboardLayouts.ps1"
    Write-Host "  Usuário: $currentUser"
    Write-Host "  Nível de execução: Máximos privilégios"
    
    # Exibe a tarefa criada
    Write-Host "`nVerificando tarefa..." -ForegroundColor Cyan
    Get-ScheduledTask -TaskName $taskName | Format-Table -Property TaskName, State, TaskPath -AutoSize
    
    Write-Host "`nPara gerenciar esta tarefa:" -ForegroundColor Magenta
    Write-Host "  Ver:    Get-ScheduledTask -TaskName '$taskName'"
    Write-Host "  Rodar:  Start-ScheduledTask -TaskName '$taskName'"
    Write-Host "  Remover: Unregister-ScheduledTask -TaskName '$taskName' -Confirm:`$false"
}
catch {
    Write-Host "❌ Erro ao criar a tarefa agendada: $_" -ForegroundColor Red
    exit 1
}
