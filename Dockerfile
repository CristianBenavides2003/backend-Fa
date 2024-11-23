#Etapa de construcción
FROM python:3.13.0-alpine as builder

#Instalar dependencias necesarias
RUN apk add --no-cache \
    curl \
    bash \
    ca-certificates \
    gcc \
    musl-dev \
    python3-dev \
    libffi-dev \
    && apk add --no-cache nodejs npm \
    && rm -rf /var/cache/apk/*

WORKDIR /app

#Copiar el código de la aplicación al contenedor
COPY . .

#Instalar dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir prisma uvicorn

#Eliminar el archivo conflictivo de prisma y luego instalar la CLI globalmente
RUN rm -f /usr/local/bin/prisma && npm install -g prisma@5.11.0

#Generar el cliente de Prisma
RUN prisma generate

#Etapa final
FROM python:3.13.0-alpine

#Instalar dependencias necesarias para la imagen final
RUN apk add --no-cache \
    libpq \
    nodejs \
    npm \
    gcc \
    musl-dev \
    python3-dev \
    libffi-dev

WORKDIR /app

#Copiar todo el contenido de la etapa builder
COPY --from=builder /app /app

#Instalar dependencias de Python en la imagen final
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir prisma uvicorn

#Configurar la variable de entorno
ENV DATABASE_URL=${DATABASE_URL}

#Comando final que garantiza la generación del cliente y el despliegue de migraciones
CMD ["sh", "-c", "prisma generate && prisma migrate deploy && uvicorn app.main:app --host 0.0.0.0 --port 8000"]
