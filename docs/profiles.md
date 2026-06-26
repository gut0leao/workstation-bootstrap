# Perfis

O projeto deve suportar perfis para diferentes contextos de uso.

## personal

Perfil padrão para máquina pessoal.

Características:

- pode assumir privilégios administrativos;
- pode usar winget;
- pode instalar fontes;
- pode instalar ferramentas Windows;
- pode configurar WSL e Ubuntu.

## corporate

Perfil conservador para máquinas corporativas.

Características:

- pode não ter privilégios administrativos;
- winget pode estar bloqueado;
- proxy pode ser obrigatório;
- instalação de fontes pode ser bloqueada;
- Hyper-V pode estar indisponível;
- scripts devem falhar de forma amigável.

## minimal

Perfil mínimo para instalar apenas o essencial.

Características:

- menor número de programas;
- foco em WSL, Ubuntu, zsh e Starship;
- menos alterações no host Windows.
