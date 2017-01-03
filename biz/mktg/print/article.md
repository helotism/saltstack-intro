# Gut gewürzt: Automatisierung mit Saltstack

Neben den Platzhirschen des Config Managements gibt es mit Saltstack eine beachtenswerte Variante, um Befehle auf entfernten Systemen auszuführen (Remote Execution), Abweichungen von definierten Zielzuständen zu beheben, Instanzen bei Cloud-Anbietern zu verwalten (......) oder diese Infrastruktur-Informationen in Quellcodeverwaltung zu hinterlegen. Dieser Artikel soll die Arbeit mit Saltstack vorstellen.

...

...

## Entwicklung

Saltstack wird sehr aktiv auf GitHub entwickelt, und ist ein Produkt der ...., das Geschäftsmodell beruht auf Supportverträgen. Mehrfach pro Jahr werden Releases als Snapshot veröffentlicht, das jetzige Namensschema ist yyyy.m und die aktive Entwicklung findet in Zweigen mit Namen wie Thorium, .... statt. Als Python-Software wird die Dokumentation im Code als ... gepflegt, parallel dazu ist die über .... erreichbare Handbuch-Webseite ebenfalls im Repo enthalten. Die Mailingliste in Form der Google-Group salt-users sowie der IRC-Channel #salt auf freenode sind neben den GitHub-Issues weitere Informationsquellen.

## Installation

Saltstack ist als Paket in allen Distributionen enthalten, kann aber auch mit einem Shell-Script boitstrap..... installiert werden. Dieses ist sehr mächtig und nimmt eine Vielzahl Optionen an, dadurch ist das Script bequem in post-install-hooks einzusetzen. Die Verwendung dieses Scripts kann der Autor ausdrücklich empfehlen.

Die zentrale(n) Instanz(en) sind nur für GNU/Linux-Betriebssysteme implementiert, aber es können auch Windows-Systeme unter Verwaltung gebracht werden.

Saltstack hat derzeit kein nennenswertes grafisches Frontend, sondern wird wird typischerweise über Kommandozeilenaufrufe verwendet, oder arbeitet im Hintergrund. Die Integration in bestehende Oberflächen (und existierende Berechtigungskonzepte) kann mittels REST-API .... erfolgen oder die Python-Aufrufe anderweitig getätigt werden.


## Einige Definitionen

An zentraler Stelle arbeitet der Salt-Master, er kontrolliert Minions (...) mit entweder einer Python-Agentensoftware, über eine SSH-Verbindung oder auch einen (individuell zu schreibenden) Proxy-Minion als Interface zu einem Webservice oder sonst betriebssystemlosen Gerät.

Die Minions melden sich über .... ZeroMQ beim Master mit einem individuellen Schlüssel, welcher bei Bedarf im Vorfeld generiert werden kann, oder bei erster Abmeldung (wahlweise automatisch) bestätigt werden muss.

Der Master kann als .... dupliziert werden, in Verbindung mit einer entsprechenden Topologie auch Subnetze übergreifend. Auf dem Master kann auch ein Minion zur Selbstverwaltung laufen.

Die Konfiguration von Master und Minion erfolgt in Dateien in /etc/salt ....Windows...  Die Dateien /etc/salt/master und /etc/salt/Minion enthalten alle default-Konfigurationsparameter als auskommentierte Zeilen. Eine dieser Einstellungen ist, in /etc/salt/master.d/ oder minion.d/ alle Dateien mit der (konfigurierbaren) Endung .conf einzulesen. ...merge... ...sortorder...


Eine wichtige, nicht ganz intuitiv zu verstehende Unterscheidung, sind Module und States. .....
Die in der Dokumentation verwendete Form der State-Files ist YAML, daneben sind aber auch ....-templates implementiert und selbst auch reines Python ist möglich: Saltstack erzeugt unter der Haube daraus Python-Dictionaries,  die ......
In wenn-dann-Bedingungen können die feinen Unterschiede zwischen Distributionen abstrahiert werden, in Schleifen eine Reihe von Benutzern bearbeitet oder ...

Die in state-files hinterlegten Informationen werden in einer Art Broadcast an alle (per key akzeptierten) Minions geschickt. Vertrauliche Informationen sind daher ein Fall für die Pillar genannte Verteilung.

Die Minions werden mit Jobs angesprochen, die Returnwerte werden typischerweise auf der Kommandozeile angezeigt, können aber mit Returners.... weiterverarbeitet werden.

Von den Minions wird ein Soft-und Hardware-Inventory in Form von grains abgerufen, die typischen Standardwerte wie Distribution, Arbeitsspeicher und v.a.m. können um eigene .... erweitert werden. Das grains-System ist für eher statische Daten gedacht.

Ein flexiblerer Reaktionsweg auf Minion-Zustandsänderungen sind die beacons: Hier beginnt die MesssageQueue... ihre Stärke an den Tag zu legen. Läuft etwa die Festplatte eines Minions voll, ist ein Schwellwert als Auslöser eines beacon-events konfigurierbar, der auf dem Master von einem .... verarbeitet wird. Diese Events kommen in Form eines Pfades an, so dass auch mit Wildcards ein .... getriggert werden kann.

Neben der Messagequeue beruht die Funktionsweise stark auf Dateisynchronisation...: Damit ein Minion eine Module-Funktion ausführen kann, muss die entsprechende Datei auf dem Minion vorhanden sein. Saltstack synchronisiert daher die mitgelieferten oder vom Benutzer erstellten Python-Dateien im Hintergrund.

Zwischen den Minions...



salt-run winrepo.update_git_repos
winrepo_provider: gitpython
salt -G 'os:windows' pkg.refresh_db

salt-run winrepo.genrepo
salt winminion pkg.refresh_db

https://github.com/saltstack/salt-winrepo.git

salt '*' status.uptime

salt -G 'os:windows' pkg.list_pkgs
salt '*' status.uptime

salt -G 'os:windows' pkg.install gedit
W7-minion:
    ----------
    gedit:
        ----------
        install status:
            success
    gedit 2.30.1:
        ----------
        new:
            2.30.1
        old:


dd bs=4M if=2016-11-25-raspbian-jessie.img of=/dev/sdd

#https://docs.saltstack.com/en/latest/topics/installation/debian.html#installation-from-the-debian-raspbian-official-repository

echo 'deb http://archive.raspbian.org/raspbian/ stretch main' >> /etc/apt/sources.list
echo 'APT::Default-Release "jessie";' > /etc/apt/apt.conf.d/10apt

apt-get update
apt-get install python-zmq python-tornado/stretch salt-common/stretch

apt-get update
apt-get install python-zmq python-tornado/stretch

pi@raspberrypi:~ $ cat /etc/os-release 
PRETTY_NAME="Raspbian GNU/Linux 8 (jessie)"
NAME="Raspbian GNU/Linux"
VERSION_ID="8"
VERSION="8 (jessie)"
ID=raspbian
ID_LIKE=debian
HOME_URL="http://www.raspbian.org/"
SUPPORT_URL="http://www.raspbian.org/RaspbianForums"
BUG_REPORT_URL="http://www.raspbian.org/RaspbianBugs"
pi@raspberrypi:~ $ if grep "ID=raspbian" /etc/os-release ; then echo "r"; else echo "nr"; fi
ID=raspbian

pi@raspberrypi:~ $ if grep -q "ID=raspbian" /etc/os-release ; then echo "r"; else echo "nr"; fi

## Eine praktische Einführung

Wer die folgenden Kommandos selbst nachvollziehen moechte, sollte eine frische Installation in einer Testumgebung wählen, weil mit root-Rechten theoretisch unbegrenzt in das System eingegriffen wird.
Selbst der relativ leistungsschwache Raspberry Pi Modell B mit 512 MB reicht als Salt Master Server fuer erste Tests aus, mit einer Handvoll Minions kommt die verfügbare Hardware zurecht.

Ziel dieses ersten Kennenlernens ist, die vorstehende theoretischen Erklärungen zu festigen.
Dazu wird
- Saltstack als Master und Minion instaliert
- die public/private key Authentifizierung nachvollzogen
- ein Benutzer angelegt
- ein systemweiter Editor festgelegt

### Die Installation

Neben der Installation
- aus den Paketquellen der Distribution existiert auch
- der Weg über ein "Bootstrap-Script"
welches ein Wrapper um Paketmanager und pip ist und einige 

Die Dokumentation unter https://docs.saltstack.com/en/latest/topics/installation/ ist für jede Distribution sehr übersichtlich. Das Bootstrap-Script hat eine gute eingebaute Liste der Parameter beim Aufruf mit `-h` -- oder nachlesar auf GitHub unter https://github.com/saltstack/salt-bootstrap/blob/develop/bootstrap-salt.sh.

Das aktuelle Raspbian 2016-11-25-raspbian-jessie hat Stand Anfang Januar 2017 einige veraltete Schlüssel, die zuerst nachinstalliert werden. Ein mehrfacher Aufruf schadet übrigens nicht.

```
if grep -q 'PRETTY_NAME="Raspbian GNU/Linux 8 (jessie)"' /etc/os-release ; then
  gpg --keyserver pgpkeys.mit.edu --recv-key 8B48AD6246925553
  gpg -a --export 8B48AD6246925553 | sudo apt-key add -
  gpg --keyserver pgpkeys.mit.edu --recv-key 7638D0442B90D010
  gpg -a --export 7638D0442B90D010 | sudo apt-key add -
fi; \
myIP=$(/sbin/ip -4 -o addr show dev eth0| awk '{split($4,a,"/");print a[1]}'); \
curl -L https://bootstrap.saltstack.com | sudo sh -s -- -U -P -M -L -A ${myIP} -i minion-on-saltmaster git v2016.11.1
```
Installiert wird die momentan aktuelle Version v2016.11.1 und es wird mit `-M` auch ein Master installiert und dessen Adresse als IP eingetragen (der Default-Wert ist der hostname `salt`, der in diesem Artikel aber aus pädagogischen Gründen vermieden werden soll) . Wollte man keinen Minion installieren, müsste das mit `-N` explizit angegeben werden. Hier aber ist das nicht der Fall, sondern darüber hinaus wird der Identifier des Minions mit `-i` angegeben. Vorbereitend für weitergehende Beispiele wird mittels `-L` auch die Komponente für cloudbasierte Zielsysteme installiert. Ganz zu Beginn aber mit `-U` ein komplettes Systemupdate gemacht, auf Raspbian also ein `apt-get upgrade`. Bei der Installation von Salt selbst wird auf pip Pakete zurückgegriffen. Unter dem aktuellen Rapsbian ist dies ein Muss, weil das Paket für python-tornado mittels Distribution veraltet ist (und das Bootstrap-Script nicht zwischen Debian und Raspbian unterscheidet -- unter Debian hingegen funktioniert es.)

Das Resultat sollte zum Ende hin so aussehen:
```
 *  INFO: Running install_debian_git_post()
Created symlink from /etc/systemd/system/multi-user.target.wants/salt-master.service to /lib/systemd/system/salt-master.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/salt-minion.service to /lib/systemd/system/salt-minion.service.
 *  INFO: Running install_debian_check_services()
 *  INFO: Running install_debian_restart_daemons()
 *  INFO: Running daemons_running()
 *  INFO: Salt installed!
pi@raspberrypi:~ $ 
```

Ob beide Prozesse im Hintergrund laufen, zeigt `sudo systemctl status salt-minion.service` und `sudo systemctl status salt-master.service`, auf schwacher Hardware kann der komplette Start aber durchaus zwei bis drei Minuten dauern.

Im Logfile des Minion wird sichtbar, wenn der Minion sich beim Master gemeldet hat:
```
sudo tail -f /var/log/salt/minion 
<snip />
2017-01-03 06:10:35,700 [salt.minion      ][ERROR   ][10897] Error while bringing up minion for multi-master. Is master at 10.76.33.112 responding?
2017-01-03 06:10:45,814 [salt.crypt       ][ERROR   ][10897] The Salt Master has cached the public key for this node, this salt minion will wait for 10 seconds before attempting to re-authenticate
```
Die letzte Zeile wiederholt sich, bis der Master den Minion akzeptiert.

Weil auf diesem System Master und Minion installiert sind, kann im selben Terminal `salt-key -L` für `--list-all` aufgerufen werden, zur Auflistung der momentan bekannten Minion-Schlüssel:
```
sudo salt-key -L
Accepted Keys:
Denied Keys:
Unaccepted Keys:
minion-on-saltmaster
Rejected Keys:
```
Der Schlüssel des Minion liegt in `/etc/salt/pki/minion/minion.pem` und `/etc/salt/pki/minion/minion.pub` und der Master verwaltet seinen Schlüssel und die der Minions in der Ordnerstruktur unterhalb von `/etc/salt/pki/master`:
```
sudo ls /etc/salt/pki/master
master.pem  minions           minions_denied  minions_rejected
master.pub  minions_autosign  minions_pre
```

Wie am Ordernamen zu erahnen, kann vor der Installation eines Minions bereits ein Schlüssel generiert werden und automatisch akzeptiert. Dies ist hier nicht geschehen, weshalb der auf dem gleichen System laufende Minion akzeptiert werden muss mit:

```
sudo salt-key -a minion-on-saltmaster
```
Der Vorgang sieht so aus:
```
pi@raspberrypi:~ $ sudo salt-key -a minion-on-saltmaster
The following keys are going to be accepted:
Unaccepted Keys:
minion-on-saltmaster
Proceed? [n/Y] y
Key for minion minion-on-saltmaster accepted.
pi@raspberrypi:~ $
```

Das Hallo-Welt-Beispiel einer frischen Saltstask-Installation ist dann:
```
sudo salt 'minion-on-saltmaster' test.ping
```
Das Resultat:
```
pi@raspberrypi:~ $ sudo salt 'minion-on-saltmaster' test.ping
minion-on-saltmaster:
    True
pi@raspberrypi:~ $ 
```