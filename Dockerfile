FROM python:3.13.0-alpine3.20
COPY sum.py /app/sum.py
WORKDIR /app
CMD ["tail", "-f", "/dev/null"]