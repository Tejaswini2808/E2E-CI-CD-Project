FROM python:3.12-slim
COPY . /application
WORKDIR /application
COPY requirements.txt .
RUN apt-get update && apt-get install -y gcc && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get purge -y gcc && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*
EXPOSE 5000
CMD ["python", "app.py"]
