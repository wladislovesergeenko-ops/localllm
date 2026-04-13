# localllm — контекст проекта

## Что это
LLM-стек: Telegram-бот на базе Hermes Agent, работает на VPS через OpenRouter.

## Инфраструктура

### VPS (продакшн)
- **Сервер:** `31.130.129.3` (Linux, root)
- **Путь:** `/opt/localllm/hermes/`
- **Docker:** контейнер `hermes`, изолирован от остальных проектов на сервере

### LM Studio (локально, не используется ботом)
- **Base URL:** `http://10.8.0.15:1234/v1`
- **Модели:** gemma-3-4b, gemma-4-e4b, qwen3-vl-8b, nomic-embed
- **Бенчмарк:** [`benchmark_results.md`](./benchmark_results.md)

---

## Hermes Agent (Telegram-бот)

### Статус
Задеплоен на VPS, работает в Docker. Локальный контейнер остановлен.

### Структура
```
hermes/
├── docker-compose.yml   # Docker-конфиг
├── config.yaml          # Конфиг Hermes (модель, TTS, gateway)
├── deploy.sh            # Скрипт деплоя (клон + патчи + запуск)
├── .env.example         # Шаблон ключей
├── .env                 # Ключи (не коммитить)
└── hermes-agent/        # Клон NousResearch/hermes-agent (в .gitignore)
```

### Управление (на сервере)
```bash
ssh root@31.130.129.3
cd /opt/localllm/hermes
docker compose restart        # перезапустить (после изменений config.yaml)
docker compose logs -f        # логи
docker compose down           # остановить
docker compose up -d --build  # пересобрать (после патчей)
```

### Текущая конфигурация (`config.yaml`)
- **Основная модель:** `google/gemini-2.0-flash-001` через OpenRouter ($0.10/$0.40 за млн токенов)
- **Вспомогательная модель:** Gemini Flash Preview (авто, OpenRouter — сжатие контекста)
- **TTS:** Microsoft Edge TTS, голос `ru-RU-SvetlanaNeural`, скорость 1.5x (бесплатно)
- **STT:** faster-whisper (локально в контейнере, кешируется в Docker volume)
- **Display:** tool_progress отключен (не показывает `🔊 text_to_speech:...`)
- **Патч:** голосовой ответ без дубля текстом

### Ключи в `hermes/.env`
| Переменная | Назначение |
|-----------|-----------|
| `OPENAI_API_KEY` | OpenAI Whisper (STT для голосовых) |
| `OPENROUTER_API_KEY` | OpenRouter (основная + вспомогательная модель) |
| `TELEGRAM_BOT_TOKEN` | Telegram bot |
| `TELEGRAM_ALLOWED_USERS` | Whitelist user ID |

### Деплой (`deploy.sh`)
Скрипт автоматически:
1. Клонирует `NousResearch/hermes-agent`
2. Патчит Dockerfile (добавляет `git` + `gosu` в apt)
3. Патчит `base.py` (убирает текст при голосовом ответе)
4. Собирает и запускает контейнер

### Голосовой режим
Voice-to-voice пайплайн: войс → Whisper → модель → Edge TTS → войс обратно
- `/voice off` — отключить голосовые ответы
- `/voice tts` — голос на все сообщения
- Голос: `tts.edge.voice` в config.yaml
- Варианты: `ru-RU-SvetlanaNeural` (жен.), `ru-RU-DmitryNeural` (муж.)

### Известные особенности
- Первый запрос после старта — cold start OpenRouter (~30-60 сек), потом быстро
- Команда запуска: `gateway run` (не `gateway start` — нет systemd в Docker)
- `config.yaml` без `:ro` — Hermes пишет в него при `/sethome`
