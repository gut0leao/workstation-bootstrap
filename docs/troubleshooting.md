# Troubleshooting

## WSL não instala

Aplica-se apenas ao host Windows.

Verificar:

```powershell
wsl --status
wsl -l -v
```

Verificar recursos Windows:

- Windows Subsystem for Linux;
- Virtual Machine Platform;
- virtualização habilitada no firmware/BIOS.

Se o bootstrap informar que a distro já existe, ela não será marcada como gerenciada pelo projeto. Isso evita que um reset futuro remova uma distro criada manualmente.

## Alterações no `.wslconfig` não surtiram efeito

Aplica-se apenas ao host Windows.

Executar:

```powershell
wsl --shutdown
```

Depois abrir novamente o Ubuntu.

## WezTerm não abre direto no Ubuntu/WSL

Aplica-se ao fluxo Windows atual.

Verificar o nome da distribuição:

```powershell
wsl -l -v
```

Ajustar `config.default_prog` no `wezterm.lua`.

## Fonte Nerd Font não aparece

No Windows, verificar se a fonte foi instalada e reiniciar o WezTerm.

TODO: documentar validação de fontes no Ubuntu host quando esse fluxo existir.

## `bat` não encontrado

No Ubuntu, o pacote pode instalar o comando como `batcat`.

## `fd` não encontrado

No Ubuntu, o pacote pode instalar o comando como `fdfind`.

## Starship não aparece

Verificar se o `.zshrc` contém:

```zsh
eval "$(starship init zsh)"
```

Verificar:

```bash
starship --version
```

## Bootstrap Ubuntu não instala pacotes apt

O bootstrap Ubuntu não aguarda senha de `sudo` para evitar travamentos em execução automatizada.

Se o resumo indicar que `sudo` não está disponível de forma não interativa, execute manualmente dentro do Ubuntu:

```bash
sudo apt-get update
sudo apt-get install -y eza zoxide fzf bat ripgrep fd-find btop direnv
```

## Quero retestar o bootstrap do zero

Não desinstale tudo manualmente como primeira opção.

Fluxo recomendado:

```powershell
.\bootstrap.ps1 -Reset -ResetScope Config -DryRun
```

Para testes destrutivos, usar uma distro WSL dedicada ao projeto e exigir confirmação explícita:

```powershell
.\bootstrap.ps1 -Reset -ResetScope WSLDistro -ConfirmDestructive
```

TODO: implementar o fluxo acima.

## Ubuntu host nativo

TODO: adicionar problemas comuns quando o fluxo Ubuntu host for implementado.
