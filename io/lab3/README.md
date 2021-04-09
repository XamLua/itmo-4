# Лабораторная работа 3

**Название:** "Разработка драйверов сетевых устройств"

**Цель работы:** Получить знания и навыки разработки драйверов сетевых интерфейсов для операционной системы Linux.

## Описание функциональности драйвера
Драйвер создает виртуальный сетевой интерфейс, который перехватывает UDP пакеты родительского интерфейса, адресуемые на конкретный порт. Информация о полученных пакетах выводится в кольцевой буффер, а общая статистика в файл /proc/lab3.


## Инструкция по сборке
$ cd lab3
$ make

## Инструкция пользователя

1. Собрать проект
2. Загрузить модуль: $ sudo insmod lab3.ko link=link_name port=port
3. Проверить системные логи: $ dmesg
4. Проверить, создан ли proc файл: $ ls -l /proc/lab3
5. Отправить пакет на интерфейс: $ traceroute ip_addr -U -p port
6. Проверить, что в файл в /proc записана информация о пакете: \# cat /proc/lab3
7. Проверить, что в кольцевой буфер записана информация о пакете: $ dmesg
8. Выгрузить модуль ядра: $ sudo rmmod lab3

## Примеры использования
Проверим адрес:
```bash
lab3$ ifconfig
enp0s3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.43.134  netmask 255.255.255.0  broadcast 192.168.43.255
        inet6 fe80::b059:c45a:fba0:d019  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:06:51:cf  txqueuelen 1000  (Ethernet)
        RX packets 22411  bytes 30346558 (30.3 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 9917  bytes 675964 (675.9 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
Вывод в кольцевом буфере:
```bash
[347.225455] UDP datagram #41
[347.225456] Src port: 51942 
             Dst port: 313
[347.225457] Src addr: 192.168.43.236
[347.225458] Dst addr: 192.168.43.134
[347.225458] Data length: 32 
             Data: 
[347.225458] @ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_

```
Вывод в /proc файле:
```bash
$ cat /proc/lab3
Recieved packets: 43 (2602 bytes)
Filtered packets: 32
```