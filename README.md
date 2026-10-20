<<<<<<< HEAD
# 🖨️ Configurador Automático de Impressoras Epson para Linux

Script Bash para automatizar a instalação de dependências, a detecção e a configuração de impressoras Epson em distribuições Linux baseadas em Debian/Ubuntu, utilizando o CUPS e o protocolo IPP.

O projeto simplifica a configuração de impressoras de rede, reduzindo a necessidade de executar manualmente diversos comandos no terminal.

## ✨ Funcionalidades

- **Instalação automática de dependências:** verifica e instala os pacotes necessários para o funcionamento do sistema de impressão.
- **Detecção automática de impressoras:** procura impressoras Epson disponíveis na rede por meio do CUPS.
- **Configuração sem driver específico:** utiliza o modelo `everywhere` do CUPS para configurar impressoras compatíveis com impressão sem driver tradicional.
- **Configuração do CUPS:** inicia e habilita os serviços necessários para o gerenciamento de impressoras.
- **Definição da impressora padrão:** configura automaticamente a impressora detectada como padrão do sistema.
- **Formato de papel A4:** define o tamanho de papel padrão para as impressões.
- **Impressão de teste:** envia automaticamente uma página de teste para verificar a configuração.
- **Atalho na área de trabalho:** cria um lançador para executar o script diretamente pela interface gráfica.
- **Integração com o menu de aplicativos:** disponibiliza o atalho no menu de aplicações do ambiente gráfico.
- **Verificação de dependências:** evita reinstalar pacotes que já estão presentes no sistema.
- **Tratamento de erros:** interrompe a execução em caso de falhas críticas e apresenta mensagens para facilitar o diagnóstico.

## 🛠️ Tecnologias utilizadas

- Bash
- CUPS (Common UNIX Printing System)
- IPP/IPPS (Internet Printing Protocol)
- APT / DPKG
- systemd
- Avahi
- Utilitários Linux: `lpadmin`, `lpinfo`, `lpstat`, `lpoptions` e `ping`

## 📋 Requisitos

- Linux baseado em Debian/Ubuntu, como Ubuntu ou Linux Mint.
- Acesso a uma conta com privilégios `sudo`.
- Conexão de rede ativa.
- Impressora compatível com o CUPS e acessível pela rede.
- Suporte ao protocolo IPP e à configuração automática utilizada pelo CUPS.
- Ambiente com os serviços de impressão disponíveis.

**Observação:** apesar de priorizar impressoras Epson, o script possui uma alternativa que procura outra impressora IPPS caso não encontre uma Epson. Portanto, o funcionamento não é restrito exclusivamente à marca Epson.

## 🚀 Instalação e utilização

### 1. Baixe o script

Clone o repositório:

```bash
git clone https://github.com/sandrielargentim/instalacao-impressora-epson.git
```

Entre na pasta do projeto:

```bash
cd epson-printer-configurator
```

### 2. Dê permissão de execução

```bash
chmod +x epson.sh
```

### 3. Execute o configurador

```bash
./epson.sh
```

O script poderá solicitar a senha do usuário para instalar pacotes e configurar os serviços de impressão.

### 4. Aguarde a configuração

Durante a execução, o script realiza as seguintes etapas:

1. Prepara o diretório de instalação em `~/epson`.
2. Cria um atalho na área de trabalho e uma entrada no menu de aplicativos.
3. Atualiza a lista de pacotes e instala as dependências ausentes.
4. Ativa os serviços relacionados à impressão e à descoberta de dispositivos.
5. Verifica a conectividade de rede e o funcionamento do CUPS.
6. Procura uma impressora compatível disponível na rede.
7. Configura a impressora encontrada.
8. Define o papel A4 e envia uma impressão de teste.

Ao final, uma mensagem informa se a configuração foi concluída.

## 📦 Dependências instaladas

O script verifica e instala automaticamente os seguintes pacotes, caso ainda não estejam instalados:

| Pacote | Finalidade |
|---|---|
| `cups` | Sistema de gerenciamento de impressão. |
| `cups-client` | Ferramentas de linha de comando para impressão. |
| `cups-browsed` | Descoberta e gerenciamento de impressoras de rede. |
| `avahi-daemon` | Descoberta de dispositivos e serviços na rede local. |
| `avahi-utils` | Utilitários para descoberta de serviços de rede. |

## ⚙️ Como funciona a configuração

A configuração é realizada por meio de comandos do CUPS.

O script procura primeiro um dispositivo Epson anunciado por IPPS. Caso não encontre, tenta localizar outro dispositivo IPPS disponível.

Após identificar o endereço da impressora, executa o equivalente a:

```bash
sudo lpadmin -p NOME_DA_IMPRESSORA \
    -E \
    -v "URI_DA_IMPRESSORA" \
    -m everywhere
```

Em seguida, habilita a impressora, aceita trabalhos de impressão, define-a como padrão e configura o papel A4.

Por fim, envia um trabalho de teste:

```bash
echo "Teste automático OK" | lp -d NOME_DA_IMPRESSORA
```

## 📁 Estrutura do projeto

```text
epson-printer-configurator/
├── epson.sh
└── README.md
```

Após a execução, o script também utiliza diretórios do usuário para armazenar sua cópia de instalação e os atalhos de inicialização.

## ⚠️ Limitações e observações

- O script foi desenvolvido para sistemas que utilizam APT e DPKG.
- A detecção depende da disponibilidade da impressora na rede e do suporte aos protocolos utilizados.
- A compatibilidade com `-m everywhere` depende dos recursos anunciados pela impressora e reconhecidos pelo CUPS.
- O teste de conectividade utiliza o endereço `8.8.8.8`; redes que bloqueiam esse tráfego podem ser identificadas incorretamente como indisponíveis.
- O script modifica serviços do sistema e configurações de impressão, portanto requer privilégios administrativos em determinadas etapas.
- O script não instala automaticamente um driver proprietário específico da Epson.

## 🔒 Segurança

Execute o script somente após revisar seu conteúdo e compreender as alterações realizadas no sistema.

O projeto utiliza `sudo` para instalar dependências, administrar serviços e configurar a impressora. Os comandos administrativos são executados durante a própria instalação e configuração.

## 🎯 Objetivo do projeto

Automatizar tarefas comuns de configuração de impressoras no Linux, tornando o processo mais simples para usuários que preferem uma instalação guiada por mensagens no terminal e atalhos acessíveis pela interface gráfica.

## 📄 Licença

Este projeto ainda não especifica uma licença. Caso deseje permitir que outras pessoas utilizem, modifiquem e redistribuam o código, adicione um arquivo `LICENSE` com a licença escolhida.

---

Desenvolvido para simplificar a configuração de impressoras de rede em ambientes Linux.
=======
# instalacao-impressora-epson
Automatizar tarefas comuns de configuração de impressoras no Linux, tornando o processo mais simples para usuários que preferem uma instalação guiada por mensagens no terminal e atalhos acessíveis pela interface gráfica.
>>>>>>> instalacao-impressora-epson/main
