# ─── Estágio 1: build do Flutter Web ─────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# O Railway injeta variáveis do serviço como build args quando declaradas.
# Se não existirem, o app roda em modo local (sem login/nuvem).
ARG SUPABASE_URL=""
ARG SUPABASE_ANON_KEY=""

RUN flutter build web --release \
    --dart-define=SUPABASE_URL=$SUPABASE_URL \
    --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# ─── Estágio 2: servidor estático (nginx) ────────────────────────────
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

# O Railway define a porta via variável PORT em tempo de execução
CMD ["/bin/sh", "-c", "sed -i \"s/listen       80;/listen ${PORT:-80};/\" /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
