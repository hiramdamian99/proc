# Establecer la imagen base
FROM maven:3.8.5-openjdk-17 AS build

RUN groupadd --gid 1001 app
RUN useradd --uid 1001 --gid app --home /app app
RUN sed -i -e 's/1001/0/g' /etc/passwd

WORKDIR /app
COPY . /app

# See everything (in a linux container)...
RUN dir -s   
RUN ls

# Descargar las dependencias del proyecto
RUN mvn -B dependency:resolve --fail-never

# Copiar el resto de los archivos del proyecto
COPY . .

# Compilar el proyecto
RUN mvn -B clean install -P dev

# Configurar la imagen base para la ejecuci�n
FROM openjdk:17-jdk-slim

# Establecer el directorio de trabajo
WORKDIR /app

# See everything (in a linux container)...
RUN dir -s   

# Copiar el archivo JAR construido en el paso anterior
COPY --from=build /app/target/*.jar app.jar

# Exponer el puerto en el contenedor
EXPOSE 5000

CMD ["echo", "'cache'"]

# Ejecutar la aplicaci�n
CMD ["java", "-jar", "app.jar"]
