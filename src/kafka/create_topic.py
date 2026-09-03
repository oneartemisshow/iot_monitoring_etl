from json import load
from dotenv import load_dotenv
import hydra
from omegaconf import DictConfig, OmegaConf
from confluent_kafka.admin import AdminClient, NewTopic
from confluent_kafka import KafkaException


def create_topic(bootstrap_server: str, topic_name: str):
    # Initialize the admin client with your cluster endpoint
    admin_client = AdminClient({
        "bootstrap.servers": bootstrap_server
    })

    # Define the topic configurations
    new_topic = NewTopic(
        topic=topic_name, 
        num_partitions=3, 
        replication_factor=3
    )

    # Trigger creation
    fs = admin_client.create_topics([new_topic])

    # Wait for the operation to finish
    for topic, future in fs.items():
        try:
            future.result()  # The result itself is None
            print(f"Topic '{topic}' created successfully.")
        except KafkaException as e:
            print(f"Failed to create topic '{topic}': {e}")

load_dotenv()
@hydra.main(version_base="1.3", config_path="/opt/airflow/config", config_name="config")
def main(cfg: DictConfig):
    create_topic(cfg.kafka.bootstrap_server, cfg.kafka.topic)

if __name__ == "__main__":
    main()