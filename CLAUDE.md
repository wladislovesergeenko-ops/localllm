# localllm — контекст проекта

## Что это
Локальный LLM-стек на базе LM Studio. Тестирование моделей, разработка Telegram-бота и OpenWebUI.

## Подключение к LM Studio
- **Base URL:** `http://10.8.0.15:1234/v1`
- **API:** OpenAI-compatible
- **Ключ:** в `.env` (не коммитить)

## Результаты тестирования моделей
См. [`benchmark_results.md`](./benchmark_results.md) — полный бенчмарк от 2026-04-13:
скорость, качество, оптимальные параметры для каждой модели.

## Доступные модели
| ID | Назначение |
|----|-----------|
| `google/gemma-3-4b` | Быстрый бот, операционные задачи |
| `google/gemma-4-e4b` | Сложный reasoning (max_tokens ≥ 1000!) |
| `qwen/qwen3-vl-8b` | Качественный текст, код, vision |
| `text-embedding-nomic-embed-text-v1.5` | Эмбеддинги |
