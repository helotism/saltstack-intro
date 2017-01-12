# Gut gewürzt: Automatisierung mit Saltstack

Neben den Platzhirschen des Config Managements gibt es mit Saltstack eine beachtenswerte Variante, um Befehle auf entfernten Systemen auszuführen (Remote Execution), Abweichungen von definierten Zielzuständen zu beheben, Instanzen bei rund zwei Dutzend Cloud-Anbietern oder auf einem Hypervisor zu verwalten beispielsweise bei Azure, Amazon EC2, Proxmox oder VMWare) oder diese Infrastruktur-Informationen in Quellcodeverwaltung zu hinterlegen. Dieser Artikel soll die Arbeit mit Saltstack vorstellen.

Der Autor dieses Artikels verwaltet mit Saltstack ein Raspberry-Pi-Cluster und auch den privaten Laptop. Im Unternehmenseinsatz ist Saltstack unter anderem Basis des Suse Manager. Ab einer installierten Basis von mehreren tausend verwalteten Systemen stehen in der Haupt-Konfigurationsdatei Parameter zur Anpassung bereit. Die Größe einer Installation bemisst sich aber nicht nur nach der Anzahl, sondern auch der Häufigkeit der Kommunikation zwischen den Systemen und der Komplexität der verwalteten Zusammenhänge.


## Entwicklung

Saltstack wird sehr aktiv auf GitHub entwickelt, und ist ein Produkt des gleichnamigen Unernehmens aus Utah, das Geschäftsmodell beruht auf Supportverträgen und der Enterprise-Version mit Frontend. Mitarbeiter sind in den GitHub-Issues aktiv und nehmen dort Produktmanagement-Aufgaben wahr. Mehrfach pro Jahr werden Releases als Snapshot veröffentlicht, das jetzige ist v2016.11.1, nach den vorigen v2016.3 und v2015.8. Als Python-Software wird die Dokumentation im Code als Docstrings gepflegt und auf der Kommandozeile zugänglich, parallel dazu ist die über http://docs.saltstack.com/ erreichbare Handbuch-Webseite ebenfalls im Repo enthalten. Die Mailingliste in Form der Google-Group salt-users sowie der IRC-Channel #salt auf freenode sind weitere Informationsquellen.

## Installation

Saltstack ist als Paket in allen Distributionen enthalten, kann aber auch mit dem "Salt Bootstrap"-Script installiert werden. Dieses ist sehr mächtig und nimmt eine Vielzahl Optionen entgegen, wodurch es bequem in post-install-hooks eingesetzt werden kann. Die Verwendung dieses Scripts kann der Autor ausdrücklich empfehlen.

Die zentrale(n) Instanz(en) sind nur für GNU/Linux-Betriebssysteme implementiert, aber es können als abhängige Systeme ("Minions") aber auch  Windows-Systeme unter Verwaltung gebracht werden.

Saltstack hat in der Community-Edition "Salt Open" derzeit kein nennenswertes grafisches Frontend, sondern wird wird typischerweise über Kommandozeilenaufrufe verwendet, oder arbeitet im Hintergrund. Die Integration in bestehende Oberflächen (und existierende Berechtigungskonzepte) kann mittels "netapi" Webaufrufen erfolgen oder auf anderem Wege eine native Python-API verwendet werden.

Sowohl Master als auch Minion werden standardmäßig als Benutzer `root` ausgeführt, der Konfigurationsparameter `user` kann aber auch auf einen anderen Benutzer zeigen. Egal unter welchem Benutzer der Master läuft: Der Minion nimmt von ihm alle Kommandos entgegen.

Den Nutzern auf dem Salt Master können einzelne Module für wiederum einzelne Minions mittels `publisher_acl` freigegeben werden, etwa dem Datenbankadministrator die mysql.* Aufufe auf Minions mit dem Hostnamen db.*.

Auf allen Distributionen installieren sich die Salstack-Komponenten als Dienst, können aber auch im Vordergrund und mit hohem Loglevel mittels `/usr/bin/salt-master -l debug` bzw. `/usr/bin/salt-minion -l debug` gestartet werden.

## Einige Definitionen

An zentraler Stelle arbeitet der Salt-"Master", er versorgt Minions mit entweder einer Python-Agentensoftware, über eine SSH-Verbindung oder auch einen (individuell zu schreibenden) Proxy-Minion als Interface zu einem Webservice oder sonst betriebssystemlosen Gerät.

Die Minions melden sich über (die Python-Bindings von) ZeroMQ beim Master mit einem individuellen Schlüssel, welcher bei Bedarf im Vorfeld generiert werden kann. Der Master muss den Schlüssel des Minions nach dessen erster Kontaktaufnahme bestätigen, dem Master wird der Schlüssel zur automatischen Bestätigung vorher übertragen. Bei Bedarf kann eine TLS-Verschlüsselung zwischen Master und Minion in der Konfiguration aktiviert werden, standardmäßig ist sie nicht aktiviert.



Der Master kann als "Syndic" dupliziert werden, in Verbindung mit einer entsprechenden Netzwerk-Topologie auch Subnetze übergreifend. Auf dem Master kann auch ein Minion zur Selbstverwaltung laufen. Minions können auf mehrere Master ("multi-master") horchen.

Die Konfiguration von Master und Minion erfolgt in Dateien in /etc/salt/, unter Windows in C:\salt\config\minion. Die Dateien /etc/salt/master und /etc/salt/Minion enthalten alle default-Konfigurationsparameter als auskommentierte Zeilen. Eine dieser Einstellungen `default_include` ist, in /etc/salt/master.d/ oder minion.d/ alle Dateien mit der Endung .conf einzulesen, die Inhalte der Datei mit dem letzten alphanumerischen Dateinamen gewinnen.

Was der Saltstack Master mit seinen Minions tun soll, wird üblicherweise in Textdateien unte `/srv/salt` festgelegt. Es ist aber nahezu trivial, andere Quellen von entfernten Systemen einzubinden: Mit weniger als zehn Zeilen Konfiguration mittels `fileserver_backend` und `gitfs_remotes` lässt sich ein GitHub-Repository einbinden, bei voller Flexibilität in der Verzeichnisstruktur und Branches. Ebenso sind Mercurial, SVN, S3fs und Azurefs möglich. Die eigene .vimrc in einem privaten Bitbucket-Repo kommt mit Saltstack an verblüffend viele Ablageorte, und lässt sich unterwegs dorthin sogar Host-individuell umschreiben.

Eine wichtige (nicht ganz intuitiv zu verstehende) Unterscheidung sind "Execution Modules" und "States": Zwar spielt Saltstack seine Stärke vor allem dann aus, wenn die Ziel-Status eines Minions als Textdatei definiert wird ("infrastructure as code"), aber auf der Kommandozeile lassen sich ebenfalls Saltstack Module aufrufen, und zwar nicht nur von Master, sondern auch von einem "standalone minion". Ein Beispiel soll es verdeutlichen:

```
root@saltmaster:~# salt -C 'G@os_family:Arch and G@init:systemd' pkg.install libmicrohttpd
logsrv-arch-01:
    ----------
    libmicrohttpd:
        ----------
        new:
            0.9.52-1
        old:
root@saltmaster:~# 
```
Hier wird vom Master aus auf allen Minions mit der zusammengesetzten/"compound" ID aus ArchLinux und Systemd als Initprozess die rein optionale Abhängigkeit `libmicrohttpd` installiert. Denn um mit Zertifikaten abgesichert remote Logdateien zu übertragen, ist diese Abhängigkeit nicht mehr optional.

Die Dokumentation findet sich also von https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.pkg.html verlinkt.


Die Definition in einem State ergibt letztlich das gleiche Resultat:

```
root@saltmaster:~# cat /srv/salt/top.sls
base:
  'G@os_family:Arch and G@init:systemd':
    - match: compound
    - tutorial/remoteloggingdeps
root@saltmaster:~# cat /srv/salt/tutorial/remoteloggingdeps.sls
ensure needed dependency:
  pkg.installed:
    - name: libmicrohttpd

root@saltmaster:~# salt 'logsrv-arch-01' state.highstate
logsrv-arch-01:
----------
          ID: ensure needed dependency
    Function: pkg.installed
        Name: libmicrohttpd
      Result: True
     Comment: Package libmicrohttpd is already installed
     Started: 20:54:40.407961
    Duration: 139.701 ms
     Changes:   

Summary for logsrv-arch-01
------------
Succeeded: 1
Failed:    0
------------
Total states run:     1
Total run time: 139.701 ms
root@saltmaster:~#
```

Die Namensgebung von Saltstack folgt hier in der Verwendung von Verben und Adjektiven den Üblichkeiten bei Endlichen Automaten, Zustände mit Eigenschaften und Übergänge mit Tätigkeiten zu benennen.

Diese Unterscheidung ist deshalb wichtig, um die richtige Dokumentation zu finden:
https://docs.saltstack.com/en/latest/ref/modules/all/index.html
https://docs.saltstack.com/en/latest/ref/states/all/index.html


Die in der Dokumentation verwendete Form der State-Files ist YAML, daneben sind aber auch eine Vielzahl weiterer "Renderer-Module" https://docs.saltstack.com/en/latest/ref/renderers/all/index.html implementiert und selbst auch reines Python ist möglich: Saltstack erzeugt unter der Haube daraus Python-Dictionaries.
Auch eine Verkettung von Renderern ist möglich.

.....

In wenn-dann-Bedingungen können die feinen Unterschiede zwischen Distributionen abstrahiert werden, in Schleifen eine Reihe von Benutzern bearbeitet oder ...

Die in state-files hinterlegten Informationen werden in einer Art Broadcast an alle (per key akzeptierten) Minions geschickt. Vertrauliche Informationen sind daher ein Fall für die Pillar genannte Verteilung, welche diese Daten nur zwischen dem Master und dem Minion austauscht, für den die Information bestimmt ist.

Die Minions werden mit Jobs angesprochen, die Returnwerte werden typischerweise auf der Kommandozeile angezeigt, können aber mit Returners.... weiterverarbeitet werden.

Von den Minions wird ein Soft-und Hardware-Inventory in Form von grains abgerufen, die typischen Standardwerte wie Distribution, Arbeitsspeicher und v.a.m. können um eigene .... erweitert werden. Das grains-System ist für eher statische Daten gedacht.

Ein flexiblerer Reaktionsweg auf Minion-Zustandsänderungen sind die beacons: Hier beginnt die MesssageQueue... ihre Stärke an den Tag zu legen. Läuft etwa die Festplatte eines Minions voll, ist ein Schwellwert als Auslöser eines beacon-events konfigurierbar, der auf dem Master von einem .... verarbeitet wird. Diese Events kommen in Form eines Pfades an, so dass auch mit Wildcards ein .... getriggert werden kann.

Neben der Messagequeue beruht die Funktionsweise stark auf Dateisynchronisation...: Damit ein Minion eine Module-Funktion ausführen kann, muss die entsprechende Datei auf dem Minion vorhanden sein. Saltstack synchronisiert daher die mitgelieferten oder vom Benutzer erstellten Python-Dateien im Hintergrund. Auch dieser Austausch ist in ZeroMq implementiert.

Zwischen den Minions...


state_top_saltenv
top_file_merging_strategy
env_order
default_top
master_tops




## Eine praktische Einführung

Wer die folgenden Kommandos selbst nachvollziehen moechte, sollte eine frische Installation in einer Testumgebung wählen, weil mit root-Rechten theoretisch unbegrenzt in das System eingegriffen wird.
Selbst der relativ leistungsschwache Raspberry Pi Modell B mit 512 MB reicht als Salt Master Server fuer erste Tests aus, mit einer Handvoll Minions kommt die verfügbare Hardware zurecht.

Ziel dieses ersten Kennenlernens ist, die vorstehende theoretischen Erklärungen zu festigen.
Dazu wird
- Saltstack als Master und Minion instaliert
- die public/private key Authentifizierung nachvollzogen
- ein systemweiter Editor festgelegt
- ein Benutzer angelegt

### Die Installation

Neben der Installation
- aus den Paketquellen der Distribution existiert auch
- der Weg über ein "Bootstrap-Script"
welches ein Wrapper um Paketmanager und pip ist und einige 

Die Dokumentation unter https://docs.saltstack.com/en/latest/topics/installation/ ist für jede Distribution sehr übersichtlich. Das Bootstrap-Script hat eine gute eingebaute Liste der Parameter beim Aufruf mit `-h` -- oder nachlesar auf GitHub unter https://github.com/saltstack/salt-bootstrap/blob/develop/bootstrap-salt.sh.

Das aktuelle Raspbian 2016-11-25-raspbian-jessie https://downloads.raspberrypi.org/raspbian_latest hat Stand Anfang Januar 2017 einige veraltete Schlüssel, die zuerst nachinstalliert werden. Ein mehrfacher Aufruf schadet übrigens nicht.

```
dd bs=4M if=2016-11-25-raspbian-jessie.img of=/dev/mmblkreplacethis
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

Das Hallo-Welt-Beispiel einer frischen Saltstack-Installation ist dann:
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


### Zustand des Systems, Vertrauliche Stoffe und Ausführungsmodule

Zum jetzigen Zeitpunkt ist Saltack installiert, aber kennt noch keine Zielzustände. Es stehen auf Master und Minion diverse Kommandozeilenprogramme zur Verfügung (`salt-key` wurde schon verwendet). Auf dem zuvor installierten System sind Master und Minion installiert.

Der Minion kann mit seinen eigenen Rechten (in der Regel ebenfalls `root`) auf sich selbst auch Aktionen ausführen. Folgende Aufrufe sind, abgesehen von leichten Unterschieden in der Verwendung der Messagequeue, für den Anwender identisch; zuerst setzt der Minion auf sich selbst einen `test.ping` ab, danach setzt der Master:

```
root@saltmaster:~# salt-call test.ping
local:
    True
root@saltmaster:~# salt 'minion-on-saltmaster' test.ping
minion-on-saltmaster:
    True
```


Die Liste der enthaltenen Ausführungsmodule findet sich unter https://docs.saltstack.com/en/2015.8/ref/modules/all/index.html und der Minion kann mit `salt-call --local test.ping` dieses und andere Module sogar unter Umgehung der Messagequeue ausführen.


Eine Vielfalt an vorangig statischen Informationen gibt der folgende Aufruf an das `grains` Teilsystem zurück, es ist eine Art Software- und Hardwareinventar. Wie alle dieser Aufrufe ist das Ausgabeformat wählbar, bsw als JSON. Eine Liste der Ausgabeformate findet sich unter https://docs.saltstack.com/en/latest/ref/output/all/index.html .

```
sudo salt 'minion-on-saltmaster' grains.items --out=json
```

Eine reduzierte Liste erhält man mit dem Ausführungsmodul im Singular und Nennung der Bezeichner:

```
sudo salt 'minion-on-saltmaster' grains.item id zmqversion kernel os_family --out=pprint
{'minion-on-saltmaster': {'id': 'minion-on-saltmaster',
                          'kernel': 'Linux',
                          'os_family': 'Debian',
                          'zmqversion': '4.1.4'}}
```

Nur die Liste aller vorgehaltenen Datenschnippsel ohne deren Werte liefert `salt 'minion-on-saltmaster' grains.ls`.

In YAML-Notation kann in `/etc/salt/minion`, `/etc/salt/minion.d/*conf`, `/etc/salt/grains` oder auch in eigenen Python-Modulen in `/srv/salt/_grains/` der Inhalt der `grains` beeinflusst werden.

Sollte es notwendig sein, die `grains`-Daten neu einzulesen, so macht das `salt 'minion-on-saltmaster' saltutil.sync_grains`.

Mit `grains` kann selektiert werden, welche Zielsysteme angesprochen werden sollen. Zum Beispiel kann der Minion nicht mittels seiner ID angesprochen werden, sondern anhand von `grains`:

```
pi@raspberrypi:~ $ sudo salt -G 'os:Raspbian' test.ping
minion-on-saltmaster:
    True
```

Ein Minimalbeispiel eigener `grains` ist, in `/etc/salt/grains` ein `key: value`-Paar zu setzen:

```
sed 's/^[ ]*//' <<EOF | sudo tee -a /etc/salt/grains
informatik: aktuell
EOF
sudo salt '*' saltutil.sync_grains
```

Und im Anschluss damit zu selektieren:

```
sudo salt -G 'informatik:aktuell' test.ping --out=pprint
{'minion-on-saltmaster': True}
```

Nicht alle Konfigurationsparameter eignen sich für den `grains` Mechanismus, denn `grains` sind allen Minions zugänglich. Benutzerpasswörter, Lizenzschlüssel oder andere vertrauliche Daten werden unter Saltstack in einem "pillar" genannten Modul verwaltet.




Üblicherweise zeigt die Master Konfiguration mittels `pillar_roots` auf /srv/pillar mit einer Dateistruktur analog zu den state files unter `/srv/salt`.



### Wiederaufgewärmte Formeln


Hiermit endet der Mitmachteil.

## Fortgeschrittene Anwendung

### GitHub remote

### Proxy-Minion

### salt-cloud mit DigitalOcean

### Das andere Betriebssystem

```
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
```

# Wege zur Saltstack-Kennerschaft

event bus beobachten
- Returners
Jobs


Saltstack arbeitet als Python-Software letztlich mit dem Datentyp dictionary. Dass in Saltstack normalerweise YAML-Dateien geschrieben werden, ist nur die Oberfläche des Salzbergs. Saltstack kann letztlich alles entgegennehmen, was ein Python dictionary ausgibt, auch die YAML-Dateien laufen nur durch PyYAML. Im Verbund mit einer netzwerkfähigen Messagequeue und Dateisynchronisation erscheint der aktuelle Saltstack Slogan "Automatisierung des Rechenzentrums" sehr eng gegriffen. Vielmehr ist in allen Umgebungen, wo ein Python-Interpreter vorstellbar ist und noch kein Scheduler notwendig, Saltstack als Messagebus-Statemachine eine umfassende und verlässliche Variante, hochkomplexe Umgebungen zu verwalten.


