import sqlite3
import re

def convert_to_mysql(db_path, output_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("SET FOREIGN_KEY_CHECKS=0;\n")
        
        # Get all tables
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';")
        tables = [row[0] for row in cursor.fetchall()]
        
        for table in tables:
            # We skip creating tables because it's better to let Laravel migrate it
            # But just in case, we will dump the inserts
            
            cursor.execute(f"SELECT * FROM {table}")
            rows = cursor.fetchall()
            
            if not rows:
                continue
                
            # Get column names
            col_names = [description[0] for description in cursor.description]
            cols = ', '.join([f"{c}" for c in col_names])
            
            f.write(f"\n-- Data for {table}\n")
            
            for row in rows:
                values = []
                for val in row:
                    if val is None:
                        values.append('NULL')
                    elif isinstance(val, (int, float)):
                        values.append(str(val))
                    else:
                        # Escape quotes
                        val_str = str(val).replace("'", "''")
                        values.append(f"'{val_str}'")
                
                vals = ', '.join(values)
                f.write(f"INSERT INTO {table} ({cols}) VALUES ({vals});\n")
                
        f.write("\nSET FOREIGN_KEY_CHECKS=1;\n")
    print(f"Exported to {output_path}")

convert_to_mysql('backend/database/database.sqlite', 'database_mysql_export.sql')
