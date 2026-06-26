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

## Ubuntu host nativo

TODO: adicionar problemas comuns quando o fluxo Ubuntu host for implementado.
