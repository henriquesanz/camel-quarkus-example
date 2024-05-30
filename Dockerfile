# Etapa 1: Construção
FROM maven:3.8.6-eclipse-temurin-17 AS builder

# Define o diretório de trabalho dentro do contêiner
WORKDIR /build

# Copia os arquivos do projeto para o contêiner
COPY pom.xml .
COPY src ./src

# Executa o build do Maven para compilar o projeto e gerar o JAR
RUN mvn clean package -DskipTests

# Etapa 2: Imagem Final
FROM eclipse-temurin:17-jdk-alpine

# Define o diretório de trabalho dentro do contêiner
WORKDIR /app

# Copia o JAR gerado na etapa de construção para o contêiner
COPY --from=builder /build/target/quarkus-app/lib/ /deployments/lib/
COPY --from=builder /build/target/quarkus-app/*.jar /deployments/
COPY --from=builder /build/target/quarkus-app/app/ /deployments/app/
COPY --from=builder /build/target/quarkus-app/quarkus/ /deployments/quarkus/

EXPOSE 8081
EXPOSE 8080

RUN chown -R 1001:1001 /deployments
USER 1001

ENV JAVA_OPTS_APPEND="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"
ENV JAVA_APP_JAR="/deployments/quarkus-run.jar"

# Define o comando padrão para executar a aplicação
ENTRYPOINT ["java", "-jar", "/deployments/quarkus-run.jar"]