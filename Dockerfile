# Primera etapa: Build
FROM python:3.11-alpine AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Segunda etapa: Runtime
FROM python:3.11-alpine

WORKDIR /app
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY . .

ENV PORT=8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "$PORT"]