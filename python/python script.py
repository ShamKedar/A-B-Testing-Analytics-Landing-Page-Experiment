# This code is for importing data into MySQL
import pandas as pd
import mysql.connector  # pip install pandas mysql-connector-python
import numpy as np

# --- CONFIGURATION ---
DB_CONFIG = {
    "host": "localhost",
    "user": "username",       # Change to your MySQL username
    "password": "password",   # Change to your MySQL password
    "database": "database"    # Change to your database name
}
TABLE_NAME = "ab_data"    # Your target MySQL table name
CSV_FILE_PATH = "CSV_FILE_PATH"  # Use forward slashes (/) for the path
CHUNK_SIZE = 10000                 # Number of rows to process at a time
# ---------------------

def run_import():
    try:
        # 1. Connect to MySQL Database
        print("Connecting to local MySQL database...")
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        # 2. Create Table if it does not exist
        print(f"Checking if table '{TABLE_NAME}' exists...")
        create_table_query = f"""
        CREATE TABLE IF NOT EXISTS {TABLE_NAME} (
            user_id VARCHAR(50),
            timestamp DATETIME,
            group_name VARCHAR(50),
            landing_page VARCHAR(50),
            converted INT,
            age INT,
            gender VARCHAR(20),
            location VARCHAR(100),
            session_duration DECIMAL(10,2),
            pages_visited INT,
            device_type VARCHAR(50),
            purchase_amount DECIMAL(10,2)
        );
        """
        cursor.execute(create_table_query)
        conn.commit()
        
        # 3. Prepare the dynamic SQL Insert Query
        columns = "user_id, timestamp, group_name, landing_page, converted, age, gender, location, session_duration, pages_visited, device_type, purchase_amount"
        placeholders = ", ".join(["%s"] * 12)
        insert_query = f"INSERT INTO {TABLE_NAME} ({columns}) VALUES ({placeholders})"
        
        # 4. Read and process the CSV file in chunks
        print(f"Starting bulk import from: {CSV_FILE_PATH}")
        total_rows = 0
        
        # sep=None lets pandas automatically detect if your file is comma or tab separated
        for chunk in pd.read_csv(CSV_FILE_PATH, chunksize=CHUNK_SIZE, sep=None, engine='python'):
            
            # Replace missing values (NaN) with None so MySQL treats them as NULL
            chunk = chunk.replace({np.nan: None})
            
            # Convert dataframe rows into a list of tuples
            data_tuples = [tuple(row) for row in chunk.values]
            
            # Execute batch insert
            cursor.executemany(insert_query, data_tuples)
            conn.commit()
            
            total_rows += len(chunk)
            print(f"Uploaded {total_rows} rows...")

        print(f"\nSuccess! Successfully imported {total_rows} rows into '{TABLE_NAME}'.")

    except mysql.connector.Error as err:
        print(f"Database Error: {err}")
    except FileNotFoundError:
        print(f"Error: The file at '{CSV_FILE_PATH}' was not found. Check the path.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
    finally:
        if 'cursor' in locals() and cursor:
            cursor.close()
        if 'conn' in locals() and conn:
            conn.close()

if __name__ == "__main__":
    run_import()
