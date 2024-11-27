# Primera etapa: Build
FROM python:3.11-alpine AS builder

# Establecer variables de entorno para evitar archivos .pyc y forzar salida sin búfer en Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apk update && \

    apk add --no-cache build-base gcc musl-dev mariadb-dev libffi-dev openssl-dev \

    cmake hdf5 hdf5-dev g++ && \
    apk add --no-cache lapack-dev && \

    ln -s /usr/include/locale.h /usr/include/xlocale.h

WORKDIR /app

# Instalar dependencias necesarias para compilar Python y las librerías
#RUN apk add --no-cache gcc musl-dev libffi-dev python3-dev

# Copiar archivo de requerimientos e instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el código fuente
COPY . .

# Segunda etapa: Runtime
FROM python:3.11-alpine

# Establecer variables de entorno
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Instalar las dependencias del sistema necesarias en la etapa final
RUN apk update && \

    apk add --no-cache mariadb-connector-c-dev libffi-dev openssl-dev


# Instalar dependencias en tiempo de ejecución
#RUN apk add --no-cache libffi

# Copiar las librerías instaladas y el código desde la etapa de build
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY . .

# Configurar variables de entorno
ENV PORT=8000

# Ejecutar la aplicación
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

