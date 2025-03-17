FROM python:3.9-slim

WORKDIR /app

RUN pip3 install flask

COPY ./src/app.py .

RUN python -m compileall app.py

RUN mv __pycache__/app.cpython-39.pyc app.pyc

EXPOSE 80

CMD ["python3", "app.pyc"]