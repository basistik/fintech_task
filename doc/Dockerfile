
FROM alpine
RUN apk --update add --no-cache python3 py-pip
WORKDIR /usr/src/app
EXPOSE 8000
COPY requirements.txt .
RUN pip install -qr requirements.txt
COPY app.py .
CMD ["python3", "./app.py"]
