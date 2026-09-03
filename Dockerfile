FROM apache/airflow:2.11.0

USER airflow

RUN pip install --no-cache-dir \
    # Провайдеры Airflow
    apache-airflow-providers-postgres==7.0.2 \
    apache-airflow-providers-amazon==9.35.0 \
    apache-airflow-providers-apache-kafka==1.16.0 \
    apache-airflow-providers-clickhousedb==1.0.0 \
    # Библиотеки для работы с Python скриптами
    confluent-kafka==2.15.0 \
    faker==40.37.0 \
    hydra-core==1.3.0 \
    omegaconf==2.3.1 \
    python-dotenv==1.2.3

