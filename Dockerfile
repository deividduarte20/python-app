FROM python:3.10-alpine

COPY requirements.txt .

RUN pip install -r ./requirements.txt

COPY ./src /src

CMD python /src/app.py