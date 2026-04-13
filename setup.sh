#!/bin/bash
# Запускать в WSL2 на Windows
set -e

echo "=== Hermes Agent Setup ==="
echo ""

# Проверяем наличие Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не найден. Установи Docker Desktop для Windows."
    exit 1
fi

# Проверяем LM Studio
if ! curl -s http://host.docker.internal:1234/v1/models > /dev/null 2>&1; then
    echo "⚠️  LM Studio недоступен на host.docker.internal:1234"
    echo "   Убедись что LM Studio запущен и сервер включён."
fi

cd hermes

# Создаём .env если нет
if [ ! -f .env ]; then
    cp .env.example .env
    echo "📝 Создан hermes/.env — заполни TELEGRAM_BOT_TOKEN и OPENAI_API_KEY"
    echo "   Потом запусти: docker compose up -d"
    exit 0
fi

echo "🐳 Собираем и запускаем Hermes..."
echo "   (первый раз займёт 5-10 минут — скачивается и собирается образ)"
echo ""
docker compose up -d --build

echo ""
echo "✅ Hermes запущен!"
echo "   Логи: docker compose logs -f"
echo "   Остановить: docker compose down"
