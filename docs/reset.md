# Reset Controlado

O reset existe para permitir retestes do bootstrap na mesma máquina sem tratar a workstation inteira como descartável.

Reset não é "desinstalar tudo". O projeto deve remover ou restaurar apenas o que for explicitamente pedido e comprovadamente gerenciado pelo `workstation-bootstrap`.

## Princípios

- `DryRun` deve estar disponível em todo reset.
- O escopo deve ser explícito.
- Ações destrutivas exigem confirmação explícita.
- Restaurar backup é preferível a apagar arquivo.
- Aplicativos, pacotes e distros existentes antes do bootstrap não devem ser removidos sem evidência de gerenciamento pelo projeto.
- O resumo final deve listar ações executadas, ignoradas e pendentes.

## Parâmetros Windows

```powershell
.\bootstrap.ps1 -Reset -ResetScope Config -DryRun
.\bootstrap.ps1 -Reset -ResetScope WSLDistro -ConfirmDestructive
.\bootstrap.ps1 -Reset -ResetScope All -ConfirmDestructive
```

## Escopos Windows

| Escopo | Descrição | Observações |
| --- | --- | --- |
| `Config` | Restaura ou remove configurações gerenciadas. | Deve usar backups quando existirem. |
| `UbuntuTools` | Reseta ferramentas dentro do Ubuntu gerenciado. | Deve ser conservador. |
| `WSLDistro` | Remove distro WSL gerenciada pelo projeto. | Sempre destrutivo. |
| `WindowsApps` | Remove apps Windows gerenciados pelo projeto. | Sempre destrutivo. |
| `All` | Executa reset amplo dos escopos suportados. | Sempre destrutivo. |

## Estratégia recomendada para retestes

Para retestar o bootstrap completo, preferir uma distro WSL dedicada, por exemplo `Ubuntu-WorkstationTest`, em vez de remover o Ubuntu principal do usuário.

O projeto deve permitir que a distro alvo seja configurável. Assim, testes destrutivos podem usar uma distro descartável enquanto o ambiente principal permanece preservado.

## Estado gerenciado

O bootstrap Windows mantém um manifesto de estado local em:

```text
%LOCALAPPDATA%\workstation-bootstrap\state.json
```

Esse arquivo registra execuções e será usado para saber o que foi instalado, configurado ou alterado pelo projeto.

Responsabilidades do manifesto:

- distro WSL criada pelo projeto;
- apps instalados pelo projeto;
- arquivos de configuração aplicados;
- backups criados;
- versões e timestamps de execução;
- perfil usado.

## Implementação Windows atual

O reset Windows usa o manifesto local e só considera itens registrados como gerenciados pelo projeto.

Escopos implementados:

- `Config`: restaura arquivos gerenciados a partir do backup mais recente disponível.
- `WindowsApps`: desinstala apenas apps Windows registrados como instalados pelo projeto.
- `WSLDistro`: remove apenas distros WSL registradas como criadas pelo projeto.
- `All`: combina os escopos acima.

`UbuntuTools` é conservador: pacotes `apt` não são removidos porque ainda não há rastreio confiável de ownership por pacote.

Operações destrutivas exigem `-ConfirmDestructive`. Sem essa confirmação, o reset apenas informa o que seria necessário.

## Ubuntu host futuro

TODO: criar escopos equivalentes para Ubuntu host, evitando remoção indiscriminada de pacotes do sistema.
