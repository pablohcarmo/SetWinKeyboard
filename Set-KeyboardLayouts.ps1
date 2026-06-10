#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Configura os layouts de teclado permitidos no sistema.

.DESCRIPTION
    Este script redefine completamente a lista de idiomas e layouts de teclado,
    mantendo apenas o idioma pt-BR e aplicando os layouts especificados.
    
    Ele remove qualquer layout existente e adiciona somente:
    - Português (Brasil) — ABNT2
    - Português (Brasil) — Estados Unidos (Internacional)

    O objetivo é garantir que o Windows não recrie layouts indesejados e que
    apenas os layouts definidos sejam mantidos.
#>

$desiredLayouts = @{
    "0416" = @(
        "00010416",  # ABNT2
        "00020409"   # US-International
    )
}

Write-Host "Starting keyboard layout configuration..." -ForegroundColor Cyan

# Criar lista nova contendo apenas pt-BR
$newLanguageList = New-WinUserLanguageList -Language "pt-BR"

# Obter referência ao idioma pt-BR
$ptBR = $newLanguageList | Where-Object { $_.LanguageTag -eq "pt-BR" }

# Limpar layouts existentes
$ptBR.InputMethodTips.Clear()

# Adicionar todos os layouts desejados
foreach ($layout in $desiredLayouts["0416"]) {
    $tip = "0416:$layout"
    Write-Host "Adding layout: $tip" -ForegroundColor Green
    $ptBR.InputMethodTips.Add($tip)
}

# Aplicar
try{
    Write-Host "`nApplying new keyboard configuration..." -ForegroundColor Cyan
    Set-WinUserLanguageList -LanguageList $newLanguageList -Force

    Write-Host "✅ Keyboard layouts configured successfully!" -ForegroundColor Green
    Write-Host "`nFinal configuration:" -ForegroundColor Yellow
    Get-WinUserLanguageList | Select-Object LanguageTag, InputMethodTips
} catch {
    Write-Host "❌ Error applying keyboard configuration: $_" -ForegroundColor Red
    exit 1
}