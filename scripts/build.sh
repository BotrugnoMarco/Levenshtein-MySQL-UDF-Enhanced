#!/bin/bash
set -e

# === Colors ===
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# === Configurations (related to scripts/) ===
SRC_FILE="../src/levenshtein.c"
SO_FILE="../levenshtein.so"
INIT_SQL="../init.sql"
ENV_FILE="../.env"
DOCKER_DIR="../../../../docker"
DOCKERFILE="./docker/mysql/Dockerfile"

# === Load variables from .env ===
if [ -f "$ENV_FILE" ]; then
  echo -e "${BLUE}📦 Loading variables from $ENV_FILE...${NC}"
  set -o allexport
  source "$ENV_FILE"
  set +o allexport
else
  echo -e "${RED}❌ Error: .env file not found in $ENV_FILE${NC}"
  exit 1
fi

# === Check variable availability ===
if [ -z "$MYSQL_HOST" ]; then echo -e "${RED}❌ MYSQL_HOST is missing${NC}"; exit 1; fi
if [ -z "$MYSQL_PORT" ]; then echo -e "${RED}❌ MYSQL_PORT is missing${NC}"; exit 1; fi
if [ -z "$MYSQL_USER" ]; then echo -e "${RED}❌ MYSQL_USER is missing${NC}"; exit 1; fi
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then echo -e "${RED}❌ MYSQL_ROOT_PASSWORD is missing${NC}"; exit 1; fi
if [ -z "$MYSQL_DB" ]; then echo -e "${RED}❌ MYSQL_DB is missing${NC}"; exit 1; fi
if [ -z "$IMAGE_NAME" ]; then echo -e "${RED}❌ IMAGE_NAME is missing${NC}"; exit 1; fi
if [ -z "$TAG" ]; then echo -e "${RED}❌ TAG is missing${NC}"; exit 1; fi
if [ -z "$CONTAINER_NAME" ]; then echo -e "${RED}❌ CONTAINER_NAME is missing${NC}"; exit 1; fi

# === Compilation ===
echo -e "${BLUE}🛠️  Building $SRC_FILE in $SO_FILE...${NC}"
gcc -Wall -fPIC -I/usr/include/mysql -shared -o "$SO_FILE" "$SRC_FILE" -lm
echo -e "${GREEN}✅ Compilation completed.${NC}"

# === Docker build ===
echo -e "${BLUE}🐳 Docker image construction $IMAGE_NAME:$TAG...${NC}"
cd "$DOCKER_DIR"
docker stop "$CONTAINER_NAME" || true
cd - > /dev/null
cd ../../../../
docker build --no-cache -t "$IMAGE_NAME:$TAG" -f "$DOCKERFILE" .
cd "docker"
docker start "$CONTAINER_NAME"
cd - > /dev/null
echo -e "${GREEN}✅ Docker avviato.${NC}"

# === Wait for MySQL service to start ===
echo -e "${YELLOW}⏳ I'm waiting for MySQL to be ready on $MYSQL_HOST:$MYSQL_PORT...${NC}"
TIMEOUT=10
COUNT=0
while ! mysqladmin ping -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_ROOT_PASSWORD" --silent; do
  sleep 1
  COUNT=$((COUNT+1))
  if [ "$COUNT" -ge "$TIMEOUT" ]; then
    echo -e "${RED}❌ MySQL not responding after $TIMEOUT seconds.${NC}"
    exit 1
  fi
done
echo -e "${GREEN}✅ MySQL is active!${NC}"

# === Function Initialization in MySQL ===
echo -e "${BLUE}🧩 Recording 'levenshtein' function...${NC}"
mysql -u "$MYSQL_USER" -p"$MYSQL_ROOT_PASSWORD" -h "$MYSQL_HOST" -P "$MYSQL_PORT" <<EOF
USE $MYSQL_DB;
DROP FUNCTION IF EXISTS levenshtein;
CREATE FUNCTION levenshtein RETURNS INTEGER SONAME 'levenshtein.so';
EOF
echo -e "${GREEN}✅ Function 'levenshtein' registered successfully.${NC}"

# === End ===
echo -e "${GREEN}🎉 Build completed successfully!${NC}"