# ─── Estágio 1: build do Flutter Web ─────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# As chaves do Supabase (públicas) já estão em lib/supabase_config.dart
RUN flutter build web --release

# ─── Estágio 2: servidor estático (nginx) ────────────────────────────
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

# O Railway define a porta via variável PORT em tempo de execução
CMD ["/bin/sh", "-c", "sed -i \"s/listen       80;/listen ${PORT:-80};/\" /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
