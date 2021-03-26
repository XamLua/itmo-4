# Лабораторная работа 2

**Название:** "Разработка драйверов блочных устройств"

**Цель работы:** Получить знание и навыки разработки драйверов блочных устровйств для операционной системы Linux

## Описание функциональности драйвера

Драйвер блочного устройства создает виртуальный жесткий диск размером в 50 Мбайт. Созданный диск содержит один первичный раздел размером 30 Мбайт и один расширенный, содержащий два логических раздела размером 10Мбайт каждый.

## Инструкция по сборке

Собирается с помощью команды ```make```.

## Инструкция пользователя

Для включения драйвера необходимо выполнить команду ```insmod lab2.ko``` ,которая загрузит модуль в систему. Для выгрузки модуля нужно выполнить команду ```rmmod lab2.ko```

## Примеры использования

### Просмотр разделов виртуального диска

```bash
divand@divand-VirtualBox:~/labs/itmo-4/io/lab2$ sudo parted /dev/mydisk
GNU Parted 3.2
Using /dev/mydisk
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) unit mib print                                                   
Model: Unknown (unknown)
Disk /dev/mydisk: 50,0MiB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags: 

Number  Start    End      Size     Type      File system  Flags
 1      0,00MiB  30,0MiB  30,0MiB  primary
 2      30,0MiB  50,0MiB  20,0MiB  extended
 5      30,0MiB  40,0MiB  10,0MiB  logical
 6      40,0MiB  50,0MiB  10,0MiB  logical

```

### Форматирование разделов диска с помощью mkfs.vfat

```bash
divand@divand-VirtualBox:~/labs/itmo-4/io/lab2$ sudo mkfs.vfat /dev/mydisk1
mkfs.fat 4.1 (2017-01-24)
divand@divand-VirtualBox:~/labs/itmo-4/io/lab2$ sudo mkfs.vfat /dev/mydisk5
mkfs.fat 4.1 (2017-01-24)
divand@divand-VirtualBox:~/labs/itmo-4/io/lab2$ sudo mkfs.vfat /dev/mydisk6
mkfs.fat 4.1 (2017-01-24)
```

### Измерение скорости передачи данных при копировании файлов между разделами 

```bash
divand@divand-VirtualBox:~/labs/itmo-4/io/lab2$ sudo dd if=/dev/mydisk1 of=/dev/mydisk5 bs=512 count=10000 oflag=direct
10000+0 records in
10000+0 records out
5120000 bytes (5,1 MB, 4,9 MiB) copied, 0,109654 s, 46,7 MB/s
divand@divand-VirtualBox:~/labs/itmo-4/io/lab2$ sudo dd if=/dev/mydisk1 of=/dev/mydisk6 bs=512 count=10000 oflag=direct
10000+0 records in
10000+0 records out
5120000 bytes (5,1 MB, 4,9 MiB) copied, 0,118656 s, 43,2 MB/s
divand@divand-VirtualBox:~/labs/itmo-4/io/lab2$ sudo dd if=/dev/mydisk5 of=/dev/mydisk6 bs=512 count=10000 oflag=direct
10000+0 records in
10000+0 records out
5120000 bytes (5,1 MB, 4,9 MiB) copied, 0,0987802 s, 51,8 MB/s

```

### Измерение скорости передачи данных при копировании файлов между разделами виртуального и реального жестких дисков

```bash
divand@divand-VirtualBox:~/labs/itmo-4/io/lab2$ sudo dd if=/dev/mydisk1 of=/dev/mydisk5 bs=512 count=10000 oflag=direct
10000+0 records in
10000+0 records out
5120000 bytes (5,1 MB, 4,9 MiB) copied, 0,109654 s, 46,7 MB/s
divand@divand-VirtualBox:~/labs/itmo-4/io/lab2$ sudo dd if=/dev/mydisk1 of=/dev/mydisk6 bs=512 count=10000 oflag=direct
10000+0 records in
10000+0 records out
5120000 bytes (5,1 MB, 4,9 MiB) copied, 0,118656 s, 43,2 MB/s
divand@divand-VirtualBox:~/labs/itmo-4/io/lab2$ sudo dd if=/dev/mydisk5 of=/dev/mydisk6 bs=512 count=10000 oflag=direct
10000+0 records in
10000+0 records out
5120000 bytes (5,1 MB, 4,9 MiB) copied, 0,0987802 s, 51,8 MB/s

```