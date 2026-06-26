# Perfis

O projeto deve suportar perfis para diferentes contextos de uso.

Perfis não devem assumir que o host é sempre Windows. Cada perfil deve declarar intenções e capacidades; o orquestrador de cada host decide quais ações são aplicáveis.

## Estado atual

O fluxo Windows aceita `-Profile personal|corporate|minimal`, valida se o perfil existe em `config/workstation.json` e registra o perfil usado no manifesto local.

No estado atual, os perfis ainda não alteram listas de pacotes, aplicativos, fontes, extensões ou etapas executadas. A diferenciação por perfil permanece pendente.

## personal

Perfil padrão para máquina pessoal.

Características no Windows 11:

- pode assumir privilégios administrativos;
- pode usar winget;
- pode instalar fontes;
- pode instalar ferramentas Windows;
- pode configurar WSL e Ubuntu.

Características futuras no Ubuntu host:

- pode usar `sudo`;
- pode usar `apt`;
- pode instalar fontes do usuário ou do sistema;
- pode configurar shell, prompt, editor e terminal localmente.

## corporate

Perfil conservador para máquinas corporativas.

Características:

- pode não ter privilégios administrativos;
- gerenciadores de pacotes podem estar bloqueados;
- proxy pode ser obrigatório;
- instalação de fontes pode ser bloqueada;
- virtualização ou WSL podem estar indisponíveis no Windows;
- scripts devem falhar de forma amigável.

## minimal

Perfil mínimo para instalar apenas o essencial.

Características:

- menor número de programas;
- foco em shell, prompt e ferramentas básicas;
- no Windows, foco em WSL, Ubuntu, zsh e Starship;
- no Ubuntu host futuro, foco no ambiente local sem aplicativos gráficos opcionais.
