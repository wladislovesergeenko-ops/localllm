# localllm — контекст проекта

## Что это
Локальный LLM-стек на базе LM Studio + Telegram-бот на базе Hermes Agent.

## LM Studio
- **Base URL:** `http://10.8.0.15:1234/v1` (машина локальная, не VPN)
- **API:** OpenAI-compatible
- **Ключ:** в `hermes/.env` (не коммитить)

### Доступные модели
| ID | Назначение |
|----|-----------|
| `google/gemma-3-4b` | Быстрый бот, операционные задачи |
| `google/gemma-4-e4b` | Сложный reasoning (`max_tokens ≥ 1000`!) |
| `qwen/qwen3-vl-8b` | Качественный текст, код, vision |
| `text-embedding-nomic-embed-text-v1.5` | Эмбеддинги |

Подробный бенчмарк: [`benchmark_results.md`](./benchmark_results.md)

---

## Hermes Agent (Telegram-бот)

### Статус
Развёрнут и работает в Docker. Telegram-бот активен.

### Структура
```
hermes/
├── docker-compose.yml   # Docker-конфиг
├── config.yaml          # Конфиг Hermes (модель, TTS, gateway)
├── .env                 # Ключи (не коммитить)
└── hermes-agent/        # Клон NousResearch/hermes-agent (локально)
```

### Управление
```bash
cd hermes
docker compose up -d          # запустить
docker compose restart        # перезапустить (после изменений config.yaml)
docker compose down           # остановить
docker compose logs -f        # логи
```

### Текущая конфигурация (`config.yaml`)
- **Основная модель:** `minimax/minimax-m2.7` через OpenRouter
- **Вспомогательная модель:** Gemini Flash Preview (авто, через OpenRouter — для сжатия контекста)
- **TTS:** Microsoft Edge TTS, голос `ru-RU-SvetlanaNeural` (бесплатно)
- **STT:** faster-whisper (локально, модель кешируется в Docker volume)
- **Terminal backend:** local, cwd `/opt/data/workspace`

### Ключи в `hermes/.env`
| Переменная | Назначение |
|-----------|-----------|
| `OPENAI_API_KEY` | OpenAI Whisper (STT для голосовых) |
| `OPENROUTER_API_KEY` | OpenRouter (основная модель) |
| `TELEGRAM_BOT_TOKEN` | Telegram bot |
| `TELEGRAM_ALLOWED_USERS` | Whitelist user ID: 5120385261 |

### Известные фиксы (не трогать)
- В `hermes-agent/Dockerfile` добавлен `git` в apt-зависимости (npm требует)
- `hermes-agent/docker/entrypoint.sh` конвертирован из CRLF → LF (Windows)
- `docker-compose.yml` билдит из `./hermes-agent` (не с GitHub — Windows не поддерживает)
- Команда запуска: `gateway run` (не `gateway start` — нет systemd в Docker)
- `config.yaml` смонтирован без `:ro` — Hermes пишет в него при `/sethome`

### Голосовой режим
Бот поддерживает полный voice-to-voice пайплайн:
- Пользователь → войс → Whisper → модель → Edge TTS → войс обратно
- `/voice off` — отключить голосовые ответы
- `/voice tts` — голос на все сообщения, не только войс
- Голос меняется в `config.yaml`: `tts.edge.voice`
- Другие бесплатные голоса: `ru-RU-DmitryNeural` (муж.), `ru-RU-SvetlanaNeural` (жен.)
