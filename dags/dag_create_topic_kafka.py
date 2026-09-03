from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator

with DAG(
    dag_id="simple_three_step_dag",
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
) as dag:
    start_task = EmptyOperator(task_id="start_task")

    # Предполагаем, что рабочая директория Airflow содержит папку src/kafka
    create_topic_task = BashOperator(
        task_id="create_topic",
        bash_command="python /opt/airflow/src/kafka/create_topic.py",
    )

    end_task = EmptyOperator(task_id="end_task")

    start_task >> create_topic_task >> end_task