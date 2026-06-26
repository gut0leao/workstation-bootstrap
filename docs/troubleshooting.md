# Troubleshooting

## WSL não instala

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

Executar:

```powershell
wsl --shutdown
```

Depois abrir novamente o Ubuntu.

## WezTerm não abre direto no Ubuntu

Verificar o nome da distribuição:

```powershell
wsl -l -v
```

Ajustar `config.default_domain` no `wezterm.lua`.

## Fonte Nerd Font não aparece

Verificar se a fonte foi instalada no Windows e reiniciar o WezTerm.

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
