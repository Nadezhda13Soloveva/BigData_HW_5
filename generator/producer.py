import os
import csv
import json
import time
import glob
from kafka import KafkaProducer
from kafka.errors import NoBrokersAvailable

BOOTSTRAP_SERVERS = os.getenv('KAFKA_BOOTSTRAP_SERVERS', 'kafka:9092')
DATA_DIR = os.getenv('DATA_DIR', '/app/data')
TOPIC_NAME = os.getenv('TOPIC_NAME', 'sales_stream')

def create_producer():
    while True:
        try:
            producer = KafkaProducer(
                bootstrap_servers=BOOTSTRAP_SERVERS,
                value_serializer=lambda v: json.dumps(v).encode('utf-8'),
                key_serializer=lambda k: k.encode('utf-8') if k else None
            )
            print("Connected to Kafka")
            return producer
        except NoBrokersAvailable:
            print("Kafka broker not available. Retrying in 5 seconds...")
            time.sleep(5)

def process_files():
    producer = create_producer()
    
    csv_files = sorted(glob.glob(os.path.join(DATA_DIR, 'MOCK_DATA*.csv')))
    if not csv_files:
        print(f"No CSV files found in {DATA_DIR}")
        print("Available files:", os.listdir(DATA_DIR))
        exit(1)

    print(f"Found {len(csv_files)} CSV files: {[os.path.basename(f) for f in csv_files]}")
    print(f"Starting to send to topic '{TOPIC_NAME}'...")
    
    total_messages = 0
    
    for file_path in csv_files:
        print(f"Processing {os.path.basename(file_path)}")
        with open(file_path, 'r', encoding='utf-8') as f:
            first_line = f.readline()
            f.seek(0)
            delimiter = ';' if ';' in first_line else ','
            
            reader = csv.DictReader(f, delimiter=delimiter)
            row_count = 0
            
            for row in reader:
                cleaned_row = {key.strip(): value for key, value in row.items()}
                
                # используем первую колонку как ключ, если есть
                key = cleaned_row.get(list(cleaned_row.keys())[0], str(time.time()))
                producer.send(TOPIC_NAME, key=str(key), value=cleaned_row)
                row_count += 1
                total_messages += 1
                
                time.sleep(0.01)
                
            print(f"Sent {row_count} messages from {os.path.basename(file_path)}")
    
    producer.flush()
    print(f"All files processed. Total messages sent: {total_messages}")

if __name__ == "__main__":
    process_files()