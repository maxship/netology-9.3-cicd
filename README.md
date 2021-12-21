# Домашнее задание к занятию "09.03 CI\CD"

## Подготовка к выполнению

1. Создаём 2 VM в yandex cloud со следующими параметрами: 2CPU 4RAM Centos7(остальное по минимальным требованиям)
2. Прописываем в [inventory](./infrastructure/inventory/cicd/hosts.yml) [playbook'a](./infrastructure/site.yml) созданные хосты
3. Добавляем в [files](./infrastructure/files/) файл со своим публичным ключом (id_rsa.pub). Если ключ называется иначе - найдите таску в плейбуке, которая использует id_rsa.pub имя и исправьте на своё
4. Запускаем playbook, ожидаем успешного завершения
5. Проверяем готовность Sonarqube через [браузер](http://localhost:9000)
6. Заходим под admin\admin, меняем пароль на свой
7.  Проверяем готовность Nexus через [бразуер](http://localhost:8081)
8. Подключаемся под admin\admin123, меняем пароль, сохраняем анонимный доступ

---

1. Создал директорию `infrastructure/terraform`, прописал настройки провайдера YC, виртуальных машин в `main.tf`, а так же вывод внешних IP адресов в и `output.tf`. Для доступа к ВМ по ssh создал пользователя и указал публичный ключ в `meta.txt` в виде:

```yml
#cloud-config
users:
  - name: maxship
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - "ssh-ed25519 <содержимое ключа> m.o.shipitsyn@mail.ru"
```

Применил конфигурацию:

```bash
$ terraform apply
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

external_ip_nexus01 = "62.84.127.16"
external_ip_sonar01 = "62.84.124.162"
```
2. Полученные IP адреса прописал в `infrastructure/inventory/cicd/hosts.yml`.
3. Добавил `id_ed25519.pub` в `infrastructure/files`.
4. Запустил плейбук:

```sh
$ ansible-playbook -i inventory/cicd/ site.yml -vv
PLAY RECAP ************************************************************************************************************************************
nexus-01                   : ok=17   changed=15   unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
sonar-01                   : ok=35   changed=27   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

5. Проверил доступность сервисов, поменял пароли.

## Знакомоство с SonarQube

### Основная часть

1. Создаём новый проект, название произвольное
2. Скачиваем пакет sonar-scanner, который нам предлагает скачать сам sonarqube
3. Делаем так, чтобы binary был доступен через вызов в shell (или меняем переменную PATH или любой другой удобный вам способ)

Разархивировал sonarqube, запустил в директории bin команду

```sh
$ export PATH=$PATH:$(pwd)
```

4. Проверяем `sonar-scanner --version`

```sh
$ sonar-scanner --version
INFO: Scanner configuration file: /home/maxship/Downloads/sonar-scanner-4.6.2.2472-linux/conf/sonar-scanner.properties
INFO: Project root configuration file: NONE
INFO: SonarScanner 4.6.2.2472
INFO: Java 11.0.11 AdoptOpenJDK (64-bit)
INFO: Linux 5.11.0-43-generic amd64
```

5. Запускаем анализатор против кода из директории [example](./example) с дополнительным ключом `-Dsonar.coverage.exclusions=fail.py`

```sh
sonar-scanner \
  -Dsonar.projectKey=my_project_01 \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://62.84.124.162:9000 \
  -Dsonar.login=2e2516b60a03b77e516a30c2614e52ae49149dd1 \
  -Dsonar.coverage.exclusions=fail.py
```

6. Смотрим результат в интерфейсе

![sonar01](https://user-images.githubusercontent.com/72273610/146891856-d3da0ffc-0544-4531-bce8-6e024bd36af7.png)

7. Исправляем ошибки, которые он выявил(включая warnings)

8. Запускаем анализатор повторно - проверяем, что QG пройдены успешно

9. Делаем скриншот успешного прохождения анализа, прикладываем к решению ДЗ

![sonar02](https://user-images.githubusercontent.com/72273610/146903149-44f03815-a9ab-4d23-b39d-8b7c040d33b7.png)


## Знакомство с Nexus

### Основная часть

1. В репозиторий `maven-public` загружаем артефакт с GAV параметрами:
   1. groupId: netology
   2. artifactId: java
   3. version: 8_282
   4. classifier: distrib
   5. type: tar.gz
2. В него же загружаем такой же артефакт, но с version: 8_102
3. Проверяем, что все файлы загрузились успешно
4. В ответе присылаем файл `maven-metadata.xml` для этого артефекта

---

После загрузки в репозитроий двух артефактов`maven-metadata.xml` выглядит так:

```xml
<metadata modelVersion="1.1.0">
  <groupId>netology</groupId>
  <artifactId>java</artifactId>
  <versioning>
    <latest>8_282</latest>
    <release>8_282</release>
    <versions>
      <version>8_102</version>
      <version>8_282</version>
    </versions>
    <lastUpdated>20211221094918</lastUpdated>
  </versioning>
</metadata>
```
![nexus01](https://user-images.githubusercontent.com/72273610/146909686-ea92c5e9-7944-4b94-9bb3-49ccd4fecc02.png)


### Знакомство с Maven

### Подготовка к выполнению

1. Скачиваем дистрибутив с [maven](https://maven.apache.org/download.cgi)
2. Разархивируем, делаем так, чтобы binary был доступен через вызов в shell (или меняем переменную PATH или любой другой удобный вам способ)
3. Удаляем из `apache-maven-<version>/conf/settings.xml` упоминание о правиле, отвергающем http соединение( раздел mirrors->id: my-repository-http-unblocker)
4. Проверяем `mvn --version`
5. Забираем директорию [mvn](./mvn) с pom

### Основная часть

1. Меняем в `pom.xml` блок с зависимостями под наш артефакт из первого пункта задания для Nexus (java с версией 8_282)
2. Запускаем команду `mvn package` в директории с `pom.xml`, ожидаем успешного окончания
3. Проверяем директорию `~/.m2/repository/`, находим наш артефакт
4. В ответе присылаем исправленный файл `pom.xml`

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
