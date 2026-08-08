# --- Estágio 1: Instalação do Flutter e Build Web ---
FROM debian:stable-slim AS build-env

# Instala apenas as dependências necessárias (sem pacotes obsoletos)
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libstdc++6 \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Baixa o repositório oficial do Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:${PATH}"

# Configura o ambiente do Flutter
RUN flutter doctor -v
RUN flutter config --enable-web

WORKDIR /app

# Copia o código do projeto
COPY . .

# Instala pacotes do pubspec e gera os arquivos da Web
RUN flutter pub get
RUN flutter build web --release

# --- Estágio 2: Nginx para servir a aplicação ---
FROM nginx:alpine

# Copia a pasta /web compilada para o diretório estático do Nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]