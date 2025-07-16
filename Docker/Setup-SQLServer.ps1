<#
.SYNOPSIS
    Configuración completa de SQL Server en Docker con datos de prueba
.DESCRIPTION
    Este script:
    1. Crea un contenedor Docker con SQL Server
    2. Configura la base de datos
    3. Crea tablas e inserta datos de prueba
    4. Verifica la instalación
.NOTES
    Requiere Docker y PowerShell 5.1+
#>

# Configuración inicial
$password = "TuClave*Segura123"
$containerName = "sql_server_demo"
$databaseName = "Ventas"
$tableName = "Ordenes"

Write-Host "=== INICIANDO CONFIGURACIÓN SQL SERVER ===" -ForegroundColor Cyan

# 1. Crear contenedor Docker
Write-Host "`n[1/4] Creando contenedor SQL Server..." -ForegroundColor Yellow
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=$password" `
    -e "MSSQL_OPTS=-DoNotEncrypt" `
    -p 1433:1433 --name $containerName `
    -d mcr.microsoft.com/mssql/server:2019-latest

# Esperar inicialización (30 segundos)
Write-Host "Esperando inicialización de SQL Server (30 segundos)..."
Start-Sleep -Seconds 30

# 2. Crear base de datos
Write-Host "`n[2/4] Creando base de datos y tablas..." -ForegroundColor Yellow
$createDBScript = @"
CREATE DATABASE $databaseName;
GO
USE $databaseName;
GO
CREATE TABLE $tableName (
    id INT IDENTITY PRIMARY KEY,
    producto VARCHAR(50),
    cantidad INT,
    fecha_registro DATETIME DEFAULT GETDATE()
);
GO
"@

docker exec $containerName /opt/mssql-tools/bin/sqlcmd `
    -S localhost -U SA -P $password `
    -Q "$createDBScript"

# 3. Insertar datos de prueba
Write-Host "`n[3/4] Insertando datos de prueba..." -ForegroundColor Yellow
$insertDataScript = @"
USE $databaseName;
INSERT INTO $tableName (producto, cantidad) VALUES 
    ('Laptop', 5),
    ('Mouse', 20),
    ('Teclado', 15),
    ('Monitor', 8),
    ('Impresora', 3);
GO
"@

docker exec $containerName /opt/mssql-tools/bin/sqlcmd `
    -S localhost -U SA -P $password `
    -Q "$insertDataScript"

# 4. Verificación
Write-Host "`n[4/4] Verificando instalación..." -ForegroundColor Yellow
$testQuery = @"
USE $databaseName;
SELECT 
    'Tabla creada correctamente' AS Resultado,
    COUNT(*) AS Filas
FROM $tableName;
GO
"@

docker exec $containerName /opt/mssql-tools/bin/sqlcmd `
    -S localhost -U SA -P $password `
    -Q "$testQuery"

# Mensaje final
Write-Host "`n=== CONFIGURACIÓN COMPLETADA ===" -ForegroundColor Green
Write-Host "Contenedor: $containerName"
Write-Host "Base de datos: $databaseName"
Write-Host "Tabla: $tableName (con 5 registros de prueba)"
Write-Host "`nPara conectarte usa:"
Write-Host "  sqlcmd -S localhost,1433 -d $databaseName -U SA -P $password" -ForegroundColor Cyan