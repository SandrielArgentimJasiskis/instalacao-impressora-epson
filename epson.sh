#!/bin/bash

set -Eeuo pipefail

trap 'echo "Erro na linha $LINENO"' ERR

# Caminhos
SCRIPT_PATH="$(realpath "$0")"

APP_DIR="$HOME/epson"

INSTALL_SCRIPT="$APP_DIR/epson.sh"

APP_LAUNCHER_DIR="$HOME/.local/share/applications"
APPLICATION_FILE="$APP_LAUNCHER_DIR/epson.desktop"

# Detecta Desktop corretamente
DESKTOP_DIR="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"
DESKTOP_FILE="$DESKTOP_DIR/epson.desktop"
DESKTOP_COPY="$DESKTOP_DIR/epson.desktop"

echo "🧩 Verificando launcher (.desktop)..."

# 1. Criar pasta ~/epson se não existir
if [[ ! -d "$APP_DIR" ]]; then
    echo "📁 Criando pasta ~/epson..."
    mkdir -p "$APP_DIR"
fi

#2. Copia para a o script path para a pasta ~/epson
if [[ ! -f "$INSTALL_SCRIPT" ]] || ! cmp -s "$SCRIPT_PATH" "$INSTALL_SCRIPT"; then
    cp "$SCRIPT_PATH" "$INSTALL_SCRIPT"
    chmod +x "$INSTALL_SCRIPT"
fi

# 2. Criar o .desktop se não existir
if [[ ! -f "$DESKTOP_FILE" ]]; then
    echo "📦 Criando launcher  na Área de trabalho..."

    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Instalar/Configurar Impressora Epson
Comment=Configuração automática da impressora Epson
Exec=bash "$INSTALL_SCRIPT"
Icon=printer
Terminal=true
Categories=Utility;
EOF

    chmod +x "$DESKTOP_FILE"
    echo "✔ Launcher criado na Área de trabalho"
else
    echo "✔ Launcher já existe na Área de trabalho"
fi

# 3. Copiar para  APPLICATIONS E Desktop
mkdir -p "$APP_LAUNCHER_DIR"

if [[ ! -f "$APPLICATION_FILE" ]]; then
    echo "🖥️ Instalando no menu de aplicativos..."
    cp "$DESKTOP_FILE" "$APPLICATION_FILE"
    chmod +x "$APPLICATION_FILE"
else
    echo "✔ Já instalado no menu"
fi

if [[ -d "$DESKTOP_DIR" ]]; then
    if [[ ! -f "$DESKTOP_COPY" ]]; then
        echo "🖥️ Copiando para Área de Trabalho..."
        cp "$DESKTOP_FILE" "$DESKTOP_COPY"
        chmod +x "$DESKTOP_COPY"
    else
        echo "✔ Já existe na Área de Trabalho"
    fi
fi


echo ""

echo "🔐 Será solicitada sua senha para instalar as dependências..."

erro() {
    echo "❌ $1"
    echo ""
    read -p "Pressione ENTER para sair..."
    exit 1
}

echo "🔧 Atualizando pacotes..."
sudo apt update -y

echo "📦 Instalando dependências necessárias..."

DEPS=(
    cups
    cups-client
    cups-browsed
    avahi-daemon
    avahi-utils
)

sudo systemctl stop cups 2>/dev/null || true
sudo killall cupsd 2>/dev/null || true
sudo systemctl daemon-reexec

for pkg in "${DEPS[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
        echo "➡ Instalando: $pkg"
        sudo apt install -y "$pkg"
    else
        echo "✔ Já instalado: $pkg"
    fi
done

# Detecta se está rodando fora da pasta padrão
if [[ "$SCRIPT_PATH" != "$INSTALL_SCRIPT" ]]; then
    echo "📦 Executando fora do diretório padrão..."

    # Detecta se está em pendrive (/media ou /mnt)
    if [[ "$SCRIPT_PATH" == /media/* || "$SCRIPT_PATH" == /mnt/* ]]; then
        echo "💾 Detectado execução via pendrive"
        read -p "Pressione ENTER para sair..."
        exit
    fi
fi

echo "⚙️ Ativando serviços..."

echo "⚙️ Iniciando serviços..."

sudo systemctl enable --now cups 2>/dev/null || sudo service cups start
sudo systemctl enable --now avahi-daemon 2>/dev/null || sudo service avahi-daemon start
sudo systemctl enable --now cups-browsed 2>/dev/null || true

echo "🌐 Verificando conexão de rede..."

if ! ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
    erro "Sem conexão com a rede!"
fi

echo "🔎 Verificando CUPS..."

if ! systemctl is-active --quiet cups; then
    echo "⚠️ CUPS não está ativo, tentando iniciar..."
    sudo systemctl start cups || sudo service cups start
    sleep 2
fi

if ! lpstat -r &>/dev/null; then
    erro "CUPS não conseguiu iniciar. Ambiente pode não suportar systemctl (ex: live USB)."
fi

echo "⏳ Aguardando serviços estabilizarem..."
sleep 2

echo "🔍 Procurando impressora via CUPS (driverless)..."

# Tenta Epson primeiro
URI=$(lpinfo -v 2>/dev/null | grep -i ipps | grep -i epson | head -n1 | awk '{print $2}')

# Fallback: qualquer impressora
if [[ -z "$URI" ]]; then
    echo "⚠️ Epson não encontrada, tentando qualquer impressora..."
    URI=$(lpinfo -v | grep -i ipps | head -n1 | awk '{print $2}')
fi

[[ -z "$URI" ]] && erro "Nenhuma impressora encontrada via CUPS."

echo "✔ URI encontrada:"
echo "$URI"

# Nome automático da impressora
RAW_NAME=$(echo "$URI" | sed 's/.*\/\/\(.*\)\._.*/\1/' | sed 's/%20/ /g')

# Limpa o nome (remove caracteres inválidos)
PRINTER_NAME=$(echo "$RAW_NAME" | tr ' ' '_' | tr -cd '[:alnum:]_')

# fallback caso fique vazio
[[ -z "$PRINTER_NAME" ]] && PRINTER_NAME="Impressora_Epson"

echo "🖨️ Nome detectado: $PRINTER_NAME"

echo "🔄 Reiniciando CUPS..."
sudo systemctl restart cups 2>/dev/null || sudo service cups restart

echo "🧹 Removendo configuração antiga (se existir)..."
sudo lpadmin -x "$PRINTER_NAME" 2>/dev/null || true

echo "🖨️ Configurando impressora automaticamente..."

sudo lpadmin \
    -p "$PRINTER_NAME" \
    -E \
    -v "$URI" \
    -m everywhere

sudo cupsenable "$PRINTER_NAME"
sudo cupsaccept "$PRINTER_NAME"

lpoptions -d "$PRINTER_NAME"

echo "📄 Definindo padrão A4..."
sudo lpadmin -p "$PRINTER_NAME" -o media=A4

echo "🧪 Testando impressão..."
echo "Teste automático OK" | lp -d "$PRINTER_NAME"

echo ""
echo "🎉 TUDO PRONTO! Impressora configurada com sucesso."
echo ""
read -p "Pressione ENTER para sair..."
