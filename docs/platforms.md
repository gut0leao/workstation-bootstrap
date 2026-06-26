# Plataformas

Este documento define o contrato de plataformas do `workstation-bootstrap`.

O projeto deve ser desenhado para múltiplos hosts, mas a implementação inicial deve ser limitada e testável.

## Estados

| Estado | Significado |
| --- | --- |
| Implementado | Deve funcionar e pode ser testado agora. |
| Planejado | Deve orientar decisões, nomes e separação de responsabilidades. |
| Fora do escopo | Não deve bloquear a implementação atual. |

## Matriz

| Plataforma host | Estado | Orquestrador | Observações |
| --- | --- | --- | --- |
| Windows 11 | Implementado | PowerShell | Instala WSL2, Ubuntu, apps Windows e configurações do host. |
| Ubuntu nativo | Planejado | Bash | Deve reutilizar configs Linux sem depender de WSL. |
| macOS | Fora do escopo | A definir | Pode ser considerado após Windows e Ubuntu host. |

## Windows 11 host

Responsabilidades atuais:

- executar instalação remota via `install.ps1` sem clone prévio;
- verificar Windows 11, PowerShell, privilégios e winget;
- instalar/configurar WSL2;
- instalar/configurar Ubuntu no WSL;
- gerar `.wslconfig`;
- instalar apps via winget;
- instalar fontes;
- configurar WezTerm e VS Code;
- chamar o bootstrap Ubuntu dentro do WSL.

Limitações atuais:

- perfis são aceitos e registrados, mas ainda não alteram comportamento;
- reset de `UbuntuTools` não remove pacotes `apt`;
- Ubuntu nativo como host permanece planejado.

## Ubuntu host

TODO:

- criar `install.sh`;
- criar `bootstrap.sh` para host Linux;
- detectar Ubuntu e versão suportada;
- definir versões Ubuntu suportadas, começando por Ubuntu LTS;
- instalar pacotes via `apt`;
- separar pacotes comuns de pacotes específicos de WSL;
- aplicar `config/zsh/.zshrc` localmente;
- aplicar `config/starship/starship.toml` localmente;
- definir como instalar VS Code;
- definir terminal padrão ou suportado;
- definir instalação de fontes;
- criar export de configurações Linux;
- criar reset Linux seguro por escopo;
- criar testes manuais de validação.

## Regras de desenho

- Código Windows fica em PowerShell.
- Código Linux fica em Bash.
- Configuração compartilhada deve ficar em `config/`.
- Pacotes por plataforma ficam em `packages/`.
- Scripts não devem inferir que todo Ubuntu é WSL.
- Scripts não devem inferir que todo host tem `winget`.
- Toda etapa deve poder ser habilitada, ignorada ou marcada como não aplicável.
- Reset deve ser implementado por host e nunca deve remover itens sem escopo explícito.
