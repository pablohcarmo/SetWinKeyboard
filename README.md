# Windows Keyboard Layout Configuration Scripts

## O Problema

O Windows tem o hábito frustrante de adicionar ou alterar layouts de teclado automaticamente, sem qualquer ação do usuário. Isso costuma acontecer quando:

- Instala atualizações do Windows
- Conecta-se a sessões de Área de Trabalho Remota (RDP)
- Instala pacotes de idiomas
- Alterna entre diferentes fontes de entrada
- Reinicia após updates cumulativos

Essas mudanças indesejadas atrapalham o fluxo de trabalho, especialmente para usuários que utilizam apenas **pt-BR**, mas o Windows insiste em adicionar:

- en-US  
- US-QWERTY  
- ABNT “padrão”  
- layouts duplicados  

O resultado é a necessidade constante de reconfigurar manualmente o teclado — algo que deveria ser simples, mas o Windows insiste em desfazer.

---

## A Solução

Este repositório contém scripts PowerShell que impedem o Windows de recriar layouts indesejados e garantem que somente os layouts definidos pelo usuário sejam mantidos.

Os scripts:

- Removem qualquer layout de teclado não autorizado
- Configuram apenas os layouts especificados
- Reaplicam automaticamente a configuração
- Executam no logon e periodicamente para evitar que o Windows reverta as mudanças

---

## Visão Geral dos Scripts

### `Set-KeyboardLayouts.ps1`

O script principal que aplica a configuração de layouts. Ele:

- Remove todos os idiomas e layouts existentes
- Mantém somente o idioma **pt-BR (0416)**
- Adiciona apenas os seguintes layouts:
  - **ABNT2** (`00010416`)
  - **US-International** (`00020409`)
- Aplica a nova configuração ao sistema
- Exibe o resultado final
- Inclui tratamento de erro (`try/catch`)
- Requer privilégios de Administrador

Este script é responsável por corrigir imediatamente qualquer alteração indesejada feita pelo Windows.

---

### `Register-KeyboardTask.ps1`

Cria uma tarefa agendada no Windows para executar automaticamente o script acima. A tarefa:

- Executa no logon do usuário atual
- Executa novamente a cada **3 horas**
- Roda com privilégios elevados
- Mantém o script invisível (janela minimizada)
- Remove tarefas antigas antes de recriar
- Verifica se o script principal existe
- Exibe detalhes da tarefa criada

Essa tarefa garante que, mesmo após atualizações do Windows ou eventos do sistema, os layouts corretos sejam restaurados automaticamente.

---

## Como Usar

### Configuração Inicial

1. **Clone ou baixe este repositório** para sua máquina.

2. **Verifique os layouts desejados** (opcional):

   O script já está configurado para usar:

   - **ABNT2**
   - **US-International**

   Caso queira alterar, edite a tabela:

   ```
   $desiredLayouts = @{
       "0416" = @(
           "00010416",  # ABNT2
           "00020409"   # US-International
       )
   }

### Guia de Execução e Gerenciamento

#### Execute o script de configuração (como Administrador):

```
.\Set-KeyboardLayouts.ps1
````

#### Crie a tarefa automática (como Administrador):

```
.\Register-KeyboardTask.ps1
```

---

## Gerenciando a Tarefa Agendada

### Ver a tarefa:

```
Get-ScheduledTask -TaskName 'ConfigureKeyboardLayouts'
```

### Executar imediatamente:

```
Start-ScheduledTask -TaskName 'ConfigureKeyboardLayouts'
```

### Remover a tarefa:

```
Unregister-ScheduledTask -TaskName 'ConfigureKeyboardLayouts' -Confirm:$false
```

## Execução Manual

Se preferir não usar a tarefa agendada, você pode executar:

```
.\Set-KeyboardLayouts.ps1
```
sempre que o Windows alterar seus layouts de teclado.

---

## Requisitos
- Windows 10 ou superior
- PowerShell 7+ (pwsh) — recomendado
- Privilégios de Administrador
- Execução de scripts habilitada (`ExecutionPolicy Bypass` já é aplicado automaticamente)

---

## Observações
- Após aplicar a configuração, pode ser necessário sair e entrar novamente na conta para que o Windows atualize todos os componentes.
- A tarefa agendada roda com privilégios elevados para garantir que possa modificar configurações de idioma.
- A tarefa é configurada para rodar mesmo em laptops usando bateria.
- Se você modificar o script `Set-KeyboardLayouts.ps1`, a tarefa agendada aplicará automaticamente as mudanças na próxima execução.

---

## Personalização
Para adicionar ou alterar layouts, edite a tabela:

```
$desiredLayouts = @{
    "0416" = @("KeyboardCode1", "KeyboardCode2")
}
```

Códigos comuns:
- `00010416` — ABNT2
- `00020409` — US-International

Lista completa de códigos:
https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-language-pack-default-values

---

## Licença
Sinta-se à vontade para usar, modificar e distribuir estes scripts conforme necessário.