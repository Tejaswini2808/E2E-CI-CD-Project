FROM python:3.12-slim
COPY . /application
WORKDIR /application
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --upgrade pip setuptools wheel
EXPOSE 5000
CMD ["python", "app.py"]
