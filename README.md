# EffectiveMobile

## Описание

```test_monitoring.sh```
- Отслеживает запущен ли процесс test
- Если процесс запущен, то стучится(по https) на
```https://test.com/monitoring/test/api```
- Если процесс был перезапущен, пишет в лог ```/var/log/monitoring.log```
- Если процесс не запущен ничего не делает
- Если сервер мониторинга не доступен, пишет в лог ```/var/log/monitoring.log```

## Установка и удаление

```sudo ./install.sh```
- Копирует ```test_monitoring.sh``` в ```/usr/local/bin/```
- Копирует юниты ```test_monitoring.service``` и ```test_monitoring.timer``` в ```/etc/systemd/system/```
- Перезагружает демона systemd (```daemon-reload```)
- Включает и запускает таймер (```systemctl enable --now test_monitoring.timer```)

После установки таймер будет запускать сервис каждую минуту

```sudo ./unistall.sh```
- Останавливает таймер и сервис (```systemctl stop test_monitoring.timer test_monitoring.service```)
- Отключает таймер (```systemctl disable test_monitoring.timer```)
- Удаляет файлы юнитов (```/etc/systemd/system/test_monitoring.*```)
- Удаляет скрипт ```/usr/local/bin/test_monitoring.sh```
- Удаляет каталог состояния ```/var/lib/test_monitoring``` и лог ```/var/log/monitoring.log```

## Тестирование

Для тестирование предлагается перед установкой ```install.sh``` заменить в ```test_monitoring.sh``` ```PROC_NAME``` на ```sleep``` и запустить в фоне процесс ```sleep 300 &```
Также можно убить этот процесс и запустить новый, чтобы проверить лог о перезапуске
  