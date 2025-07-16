from pyspark.sql import SparkSession
from pyspark.sql.functions import col,lit,current_timestamp
def main():
    #Configuracion inicial
    config = {
        "jdbc_url": "jdbc:postgresql://localhost:1433/databaseName=Ventas",
        "user": "SA",
        "password": "TuClave*Segura123",
        "driver_path": "mssql-jdbc-12.4.2.jre11.jar",
    }
    # Crear una sesión de Spark
    spark = SparkSession.builder \
        .appName("Procesamiento Ventas") \
        .config("spark.jars", config["driver_path"]) \
        .getOrCreate()
    try:
        #Extraer datos de la tabla Ordenes
        df_ordenes = spark.read \
            .format("jdbc") \
            .option("url", config["jdbc_url"]) \
            .option("dbtable", "Ordenes") \
            .option("user", config["user"]) \
            .option("password", config["password"]) \
            .load()
        print("Datos de Ordenes cargados correctamente.")
        df_ordenes.show()
        #Transformar los datos
        df_ordenes_transformed = df_ordenes.withColumn("precio_total",col("cantidad")) \
            .withColumn("procesado_en", current_timestamp()) \
            
        #4. Cargar los datos transformados a la tabla OrdenesProcesadas
        df_ordenes_transformed.write \
            .format("jdbc") \
            .option("url", config["jdbc_url"]) \
            .option("dbtable", "OrdenesProcesadas") \
            .option("user", config["user"]) \
            .option("password", config["password"]) \
            .mode("overwrite") \
            .save()
        print("ETL Completado! Verifica la tabla Ordenes_Procesadas.")
    except Exception as e:
        print(f"Error durante el proceso ETL: {e}")
    finally:
        # Detener la sesión de Spark
        spark.stop()
if __name__ == "__main__":
    main()