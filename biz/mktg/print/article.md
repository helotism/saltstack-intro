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

In wenn-dann-Bedingungen können die feinen Unterschiede zwischen Distributionen abstrahiert werden, in Schleifen eine Reihe von Benutzern bearbeitet oder subtile Konfigurationsunterschiede abgefangen werden.

Die in state-files hinterlegten Informationen werden in einer Art Broadcast an alle (per key akzeptierten) Minions geschickt. Vertrauliche Informationen sind daher ein Fall für die Pillar genannte Verteilung, welche diese Daten nur zwischen dem Master und dem Minion austauscht, für den die Information bestimmt ist.

Die Minions werden mit Jobs angesprochen, die Returnwerte werden typischerweise auf der Kommandozeile angezeigt, können aber mit `returner` weiterverarbeitet werden.

Von den Minions wird ein Soft-und Hardware-Inventory in Form von grains abgerufen, die typischen Standardwerte wie Distribution, Arbeitsspeicher und v.a.m. können um eigene Informationen erweitert werden, etwa die Rack-Nummer. Das grains-System ist für eher statische Daten gedacht.

Ein flexiblerer Reaktionsweg auf Minion-Zustandsänderungen sind die beacons: Hier beginnt die MesssageQueue ihre Stärke an den Tag zu legen. Läuft etwa die Festplatte eines Minions voll, ist ein Schwellwert als Auslöser eines beacon-events konfigurierbar, der auf dem Master von einem `reactor` verarbeitet wird. Diese Events kommen in Form eines Pfades an, so dass auch mit Wildcards eine Reaktion getriggert werden kann.

Neben der Messagequeue beruht die Funktionsweise stark auf Dateisynchronisation: Damit ein Minion eine Module-Funktion ausführen kann, muss die entsprechende Datei auf dem Minion vorhanden sein. Saltstack synchronisiert daher die mitgelieferten oder vom Benutzer erstellten Python-Dateien im Hintergrund. Auch dieser Austausch ist in ZeroMq implementiert.

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

Eine verbreitete Anwendung von `grains` ist, damit einen oder mehrere Werte für einen Schlüssel `role` zu setzen. In den Definitionen der Zielzustände werden dann solcherart "rollenbasiert" die Minions adressiert.

Auch auf der Kommandozeile kann ein `grains`-Paar gesetzt werden:

```
sudo salt 'minion-on-saltmaster' grains.setval roles  "['desktop', 'developer']"
```

Das Resultat:

```
cat /etc/salt/grains 
roles:
- desktop
- developer
sudo salt -G 'roles:desktop' test.ping
minion-on-saltmaster:
    True
```


Nicht alle Konfigurationsparameter eignen sich für den `grains` Mechanismus, denn `grains` sind allen Minions zugänglich. Benutzerpasswörter, Lizenzschlüssel oder andere vertrauliche Daten werden unter Saltstack in einem "pillar" genannten Modul verwaltet.

Üblicherweise zeigt die Master Konfiguration mittels `pillar_roots` auf /srv/pillar mit einer Dateistruktur analog zu den state files unter `/srv/salt`.

Die folgenden Kommandos stellen, immer noch innerhalb zuvorder installierten Testumgebung, ein Schlüssel-Werte-Paar `editor: vim` her:

```
if [ ! -d "/srv/pillar" ]; then sudo mkdir -p /srv/pillar; fi
if [ -f "/srv/pillar/top.sls" ]; then sudo mv /srv/pillar/top.sls /srv/pillar/top.sls.bak; fi
cat <<EOF | sudo tee -a /srv/pillar/top.sls > /dev/null
base:
  'minion-on-saltmaster':
    - editor
EOF
sed 's/^[ ]*//' <<EOF | sudo tee /srv/pillar/editor.sls > /dev/null
myeditor: vim
EOF
sudo salt 'minion-on-saltmaster' saltutil.refresh_pillar
```

Jetzt ist auf dem Master und nur auf dem Minion `minion-on-saltmaster` der Wert von `myeditor` bekannt. Andere Minions erfahren davon nichts, weil die Datei editor.sls (die Endung wird in der top.sls Datei weggelassen) auf den Minion `minion-on-saltmaster` beschränkt ist.

Ein Einstieg in die Pillar-Dokumentation findet sich unter https://docs.saltstack.com/en/latest/topics/pillar/ .

Nun wird es allerhöchste Zeit, zur zentralen Konfiguration zu kommen: Die Textdateien der `state` Zielzustände.

Jede `state`-Definition ist einer Umgebung `environment` zugeordnet, die mit dem Namen `base` ist immer (verpflichtend) vorhanden und ist sozusagen die Produktivumgebung.

Im Auslieferungszustand zeigt der Master Konfigurationsparameter `file_roots` für die `base`-Umgebung auf den Pfad `/srv/salt`. Ein Auszug aus der `/etc/salt/master`:

```
#file_roots:
#  base:
#    - /srv/salt
```

Eine typische Eweiterung eines Saltstack Konzeptes würde parallel dazu eine "testing" oder "development" Umgebung definieren. Die Reihenfolge, in der mögliche Neudefinitionen durch Kombinationen der Master Konfigurationsparameter `file_roots`, `env_order` oder `default_top` festlegbar.

In den `state` (und `pillar` funktioniert nach dem gleichen Muster) Konfigurationen ist die Datei mit dem Namen `top.sls` eine besondere Datei: Sie ist der Einstieg in die Applikation und wird nach dem Start des Masters als erstes eingelesen, etwa wie eine Konfiguration eines Frontcontrollers einer Webapplikation.

Diese Datei adressiert dann Minions, und verweist auf deren Zustandsdefinitionen. Ein Minimalbeispiel:

```
if [ -f "/srv/salt/top.sls" ]; then sudo mv /srv/salt/top.sls /srv/salt/top.sls.bak; fi
cat <<EOF | sudo tee -a /srv/salt/top.sls > /dev/null
base:
  '*':
    - common
  'minion-on-saltmaster':
    - editor
EOF
cat <<EOF | sudo tee /srv/salt/common.sls > /dev/null
#minimal example:
sudo:
  pkg.installed

#the first line is just an ID, and must be unique
multiplexer:
  pkg.installed:
    #if no -name is given, the ID is assumed to be -name
    - name: screen
EOF
```

Es wird in der Standard-Umgebung `base` für jeden Minion der Zustand aus der Datei `/srv/salt/common.sls` definiert, und für den speziellen Minion `minion-on-saltmaster` noch die editor.sls.

In der common.sls wird aus den vielen `state`-Modulen `pkg` als Abstraktion über den Paketmanager der Distributionen verwendet, um `installed` festzuschreiben. Die Liste der `state`-Module findet sich unter https://docs.saltstack.com/en/latest/ref/states/all/index.html .

Der Zielzustand `editor` existiert noch nicht, und soll im Gegensatz zur common.sls in Form eines Ordners angelegt werden:

if [ ! -d "/srv/salt/editor" ]; then sudo mkdir -p /srv/salt/editor; fi
cat <<EOF | sudo tee /srv/salt/editor/init.sls > /dev/null
{% if grains['os_family'] == 'Gentoo' %}
gentoo-specific-package-name:
  pkg.installed:
    - name: app-editors/{{ pillar['myeditor'] }}
#the other contition is elif, in case you are wondering
{% else %}
works-on-other-distros:
  pkg.installed:
    - name: {{ pillar['myeditor'] }}
{% endif %}
EOF

Die Strukturierung in einen Unterordner ist zum Beispiel dann sinnvoll, wenn in der `init.sls` mit `include:\n  - myeditorsetup` ein umfangreichere Datei eingebunden werden soll, oder wenn dotfiles mit `file.managed` verteilt werden sollen.

Bleibt nur noch, die wichtigsten Varianten vorzustellen, die Zielzustände auch anzuwenden. In der Reihenfolge von sehr spezifisch zu Rundumerneuerung:

```
sudo salt 'minion-on-saltmaster' state.sls editor
sudo salt 'minion-on-saltmaster' state.apply
sudo salt '*' state.highstate
```

Weil dies die Aufrufe mittels `/usr/bin/salt` sind, ist es das remote execution module `state`, welches hier ausgeführt wurde. Mit `state.apply` wird der benannte Zustand `editor` angewendet, `state.apply` kombiniert alle Zustandsdefinitionen, und `state.highstate` ist ein historisch gewachsener Alias.

Einem Minion kann in seiner Konfiguration mittels `startup_states` bei seinem Start die Ausführung eines Abgleichs der Zielzustände konfiguriert werden.

### Wiederaufgewärmte Formeln

In dem Beispiel mit den Besonderheiten des Gentoo-Paketmanagers wurde eine sehr einfache Bedingung geprüft. Mit den `formulas` gibt es eine Vielzahl an vorgefertigten `state`-Definitionen, dokumentiert unter https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html und verfügbar auf GitHub unter https://github.com/saltstack-formulas .

Zur Einführung soll die Benutzerverwaltung mittels der `users-formula` vorgestellt werden:

```
if [ ! -d "/srv/formulas" ]; then sudo mkdir -p /srv/formulas; fi
cd /srv/formulas
if [ ! -d "users-formula" ]; then 
  git clone https://github.com/saltstack-formulas/users-formula.git
else
  cd users-formula; git pull;
fi
if [ ! -d "/etc/salt/master.d" ]; then sudo mkdir -p /etc/salt/master.d; fi
cat <<EOF | sudo tee /etc/salt/master.d/99_fileremotes.conf > /dev/null
file_roots:
  base:
    - /srv/formulas/users-formula
EOF
if [ ! -d "/srv/pillar" ]; then sudo mkdir -p /srv/pillar; fi
if [ -f "/srv/pillar/top.sls" ]; then sudo mv /srv/pillar/top.sls /srv/pillar/top.sls.bak; fi
cat <<EOF | sudo tee -a /srv/pillar/top.sls > /dev/null
base:
  'minion-on-saltmaster':
    - editor
    - users
EOF
cat <<EOF | sudo tee /srv/pillar/users.sls > /dev/null
users:
  john:
    fullname: John Doe
    #python3 -c 'import crypt; print(crypt.crypt("john2017", crypt.mksalt(crypt.METHOD_SHA512)))'
    password: $6$xjCUEpgvWTktWz18$LF8Wcsgqg4PGY5nVGT8dsgXsMzH5ZFFewCgrCcaCRCpt5S.4y8e/mShHkgLwhRAZz4DlRn5GgOuOpfscgj3AQ.
    enforce_password: True
    sudouser: True
    sudo_rules:
      - ALL=(ALL) NOPASSWD:ALL
EOF
sudo salt 'minion-on-saltmaster' saltutil.refresh_pillar
sudo systemctl restart salt-master.service
```

Hier wurde das Git Repository lokal geklont, und ein weiterer Pfad zu `file_roots` hinzugfügt. Dadurch findet der Aufruf des remote execution moduls `state.sls users` die Datei `/srv/formulas/users-formula/users/init.sls` und wendet die im `pillar` Pfad hinterlegten, nur dem adressierten Minion mitgeteilten, beispielsweise definierten Benutzerinformationen an.

In der Datei `/srv/formulas/users-formula/users/map.jinja` ist zu sehen, wie mittels der eingebetteten Templatesprache `Jinja2` eine umfassende Abstraktion nach Distributionen festgelegt wird.

Unter `/home` ist nun das Verzeichnis `/home/john` zu sehen, er hat das Passwort `john2017`.

Die YAML-Datei `/srv/pillar/users.sls` beginnt mit dem Schlüssel `users`, der nach YAML-Art nur einmal vorkommen kann. Deshalb ist das folgende Beispiel für das salt-automatisierte Löschen von Benutzern entsprechend eingerückt:

```
  pi:
    absent: True
    purge: True
    force: True
  alarm:
    absent: True
    purge: True
    force: True
```

Dies sind typische Konfigurationen, um auch Raspbian oder Arch Linux den Standardbenutzer zu entfernen.

Hiermit endet der Mitmachteil. Die folgenden Codebeispiele und Kommandos sind zwar auch funktionierende Beispiele, aber mitunter nur illustrativ und nicht notwendigerweise vollständig -- und prüfen nicht auf vorhandene Einstellungen.

## Fortgeschrittene Anwendung

### GitHub remote

Leider ist die Installation der Abhängigkeiten unter allen Distributionen nicht einheitlich, deswegen kann nicht copy&paste-fertig ein Minimalbeispiel angeboten werden. Aber dass Saltstack es besonders trivial macht, Systemadminstration aus einem Repository (Git, svn, Mercurial und andere) zu speisen macht die Verwendung in der Praxis so angenehm.

An dieser Stelle einige Anmerkungen zur Verwendung von Git Repositories.

Weil bei der Python-basierten Synchronisation mit entfernten Repositories eine Vielzahl von Abhängigkeiten bestehen (URLs, SSL, Authenifizierung u.v.a.m.), kann an dieser Stelle nur auf https://docs.saltstack.com/en/latest/topics/tutorials/gitfs.html und http://www.pygit2.org/install.html verwiesen werden. Es ist zu empfehlen, Pygit2 zu verwenden und insbesondere unter Debian-basierten Distributionen den auf der Pygit2-Seite genannten manuellen Schritte zu installieren, nachdem zuvor `cmake`, `cffi` und `libssl-dev` installiert wurde.

Letztlich muss `python -c "import pygit2"` keinen Fehler zurückgeben, und im Master Logfiles kein Fehler wie "Failed to resolve address for https" zu finden.

Dies ist jedoch nur auf dem Master notwendig, und vor allem deswegen aufwändig, weil zum Beispiel unter Ubuntu 16.04 das Paket zu Pygit2 nicht gegen die libssl kompiliert ist -- wird dann mit den https-Adressen eines Github-Repos fehlschlagen.

Mit Pygit2 sind auch SSH-Schlüssel möglich, und Unterpfade des Repositories können an passender Stelle im Dateisystem des Masters eingehängt werden.

Mit `gitfs_remote` ist unter Verwendung der Zugriffsrechteverwaltung des Sourcecodeverwaltungssystems dann auch leicht möglich, Branches auf `environments` zu mappen.

In einem privaten Repository kann dann beispielsweise das auf eine bare-metal-Installation folgende customizing hinterlegt werden.

### Proxy-Minion

Ein weiteres interessantes Konzept ist das der Proxy-Minions. Wenn ein Gerät keine Resourcen für Python hat, also kein richtiger Minion-Client installiert werden kann, aber eine andere Art von Schnittstelle aufweist, dann kann ein normaler Minion dessen Steuerung übernehmen.

Am Beispiel des in der Enthusiastenszene beliebten Microcontrollers ESP8266 kann ein Proxy-Minion wie folgt aussehen:

Auf dem ESP8266 gibt es die alternative Firmware Micropython, welche auch die bekannt solide serielle Kommunikation mittels `pyserial` ermöglicht. Dadurch erhält der ESP8266 ein von außen programmatisch ansprechbares Interface; andere sind ebenfalls möglich, Saltstack gibt keine Einschränkung vor.

In Salt schreibt man dann ein eigenes `module` in Python. Diese `module` kann man sich auch für die Kommandozeile oder `state`-Definitionen schreiben. Es ist (lediglich) üblich, die unbeabsichtigte Verwendung in `state`-Definitionen und von der Kommandozeile zu sperren.

Nachdem Saltstack um ein generisches Modul erweitert wird, schreibt man dann ein `proxymodule` Wrapper um dieses `module` herum. Es ist dieser Wrapper, der dann bsw. in State-Definitionen angesprochen wird. Die Besonderheit bei einem für einen Proxy-Minion gedachten `proxymodule` ist lediglich, dass es zwingend die Funktionen init(), shutdown(), ping(), grains(), initialized() und __virtual__() implementieren muss.

Die Dokumentation unter https://docs.saltstack.com/en/latest/topics/proxyminion/index.html zeigt den generellen Aufbau.

Die Micropython-Portierung auf dem ESP8266 verwendet man meinstens mit einem Wrapper um `pyserial`. Die konkrete Implementation sieht dann so aus, dass ein `module` prüft, ob alle Abhängigkeiten erfüllt sind, und ansonsten als sehr leichtgewichtiger Code an das `proxymodule` übergibt. Im `proxymodule` wird dann die serielle Verbindung hergestellt, der Status dieser Verbindung wird dann als Rückgabewert von `ping()` verwendet. Ein Aufruf von `grains()` schickt dann über die serielle Verbindung einen Einzeiler nach der Art "retourniere mir ein Dictionary mit IP-Adressen, Seriennummer und dem freien Speicher". Mit ein wenig (serieller Kommunikation geschuldeter) Umwandlung hat man damit im Aufruf von `salt '*' grains.items` auch die IP-Adresse seines IoT-Devices.

Zusammen mit Dateitransfer via `pyserial` (denn Saltstack hat zwingend die Abhängigkeit von Python2.7, `pyserial` steht also immer zur Verfügung) ist auch das Update von Konfigurationsparametern leicht zu implemetieren -- mit allen Salt-Vorteilen oben drauf (diese Datei kann in einem Git-Repo ilegen, kann auf Events in der Messagequeue reagieren und die Anzahl der Proxy-Minions ist hochgradig skalierbar.)

Es existieren Referenz-Implemantationen via SSH und REST-API in der oben genannten Saltstack-Dokumentation, und der Autor hat seinen wenig eleganten ESP8266-Testcode unter https://github.com/cprior/micropython_esp8266 abgelegt.


### salt-cloud mit DigitalOcean

Wie alle anderen Could-Provider von virtuellen Maschinen bietet auch DigitalOcean eine API an und in den Knotoeinstellungen kann ein Auth-Token generiert werden. Es gibt fertige Basis-Images, man kann darauf aufbauend eigene Images (`droplets`) administrieren.

Saltstack beinhaltet einen Wrapper um diese API, und in den vier Ordnern `/etc/salt/cloud*` konfiguriert man zuerst den Zugang:

```
cat /etc/salt/cloud.providers.d/sample.conf
digitalocean:
  driver: digital_ocean
  personal_access_token: foobar
  ssh_key_file: /etc/salt/pki/cloud/salt-cloud-digitalocean_rsa
  ssh_key_names: salt-cloud-digitalocean_rsa.pub,cpr
  script: bootstrap-salt
  location: Frankfurt 1
```

Welche Images als Vorlagen existeiren, kann man sich mit Saltstack als Wrapper ebenso ansehen wie andere (anbieterspezifische) Informationen: `salt-cloud --list-images digitalocean`. Es kommt eine lange Liste zurück, inklusive `16.04.1 x64`.

Die Festlegung des zu verwendeten Images kann dann so aussehen:

```
cat /etc/salt/cloud.profiles.d/ubuntu-digitalocean.conf
digitalocean-ubuntu:
  provider: digitalocean
  script_args: " -P -p screen -p vim git v2016.3.2 "
  image: 16.04.1 x64
  size: 512MB
  private_networking: True
  backups_enabled: False
  ipv6: False
  create_dns_record: False

test-saltmaster:
  extends: digitalocean-ubuntu
  minion:
    grains:
      env: test

test-minion:
  extends: digitalocean-ubuntu
  minion:
    grains:
      env: test
```

Hier wurden also drei Minions festgelegt. Um sie zu erstellen, werden diese Profile aufgerufen:

`salt-cloud -p digitalocean test-saltmaster test-minion`

Die Option `-d` zerstört die virtuelle Instanz wieder.


### Das andere Betriebssystem

Saltstack kann auch Windows-Minions verwalten und bringt in einem Installer eine Python-Installation samt Abhängigkeiten mit (was insbesondere bei den ZeroMQ-Abhängigkeiten sehr dankbar macht). Der Minion läuft dann als Windows-Dienst (eingerichtet mittels nssm) und kann auch "silent" installiert werden, unter Angabe des Master. Die Dokuentation unter https://docs.saltstack.com/en/latest/topics/installation/windows.html bietet einen guten Einstieg.

Der Minion meldet sich dann ganz normal mit seinem Schlüssel zur Bestätigung beim Master. Der Aufruf vom Master aus `salt -G 'os:windows' pkg.list_pkgs` liefert das Software-Inventory des Windows-Rechners.

Es gibt ein Repository mit OpenSource-Software `state`-Defintionen, beschrieben unter https://docs.saltstack.com/en/latest/topics/windows/windows-package-manager.html und dort ist zum Beispiel alles hinterlegt, was die Installation von Notepad++ oder auch Blender ausmacht.
Wer dieses Repository mal schnell ausprobieren will, sollte in der Konfiguration des Master `winrepo_provider: gitpython` verwenden, weil dann nicht der auf manchen Distributionen holprige Weg der Installation von `pygit` notwendig ist.

In der Liste der mitgelieferten State-Modules unter https://docs.saltstack.com/en/latest/ref/states/all/index.html finden sich mit dem Prefix `win_` einige für Windows-Administratoren interessante Funktionen. Salstack reicht natürlich in keinster Weise an Active-Directory heran, aber um nur den einen oder anderen CAD-Rechner oder Buchhaltungs-PC zumindest in das `grains`-System einzubinden ist Saltstack sehr gut brauchbar. Und nicht zuletzt rundet es eine Erkundung der Möglichkeiten ab, auch auf solchen Minions mal eben folgendes ausführen zu können:

```
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

Wer sich tiefer mit Saltstack beschäftigen möchte, sei abschliessend empfohlen, sich zu gegebener Zeit auch die Events in der Messagequeue anzusehen mit `salt-run state.event pretty=True` (mittels salt-run von Master oder Minion).

Das System der `beacons` und `reactor` ist unter anderem geeignet, mit `inotify` auf den Minions den Status von Konfigurationsdateien zu überwachen, und vom Master aus darauf adäquat zu reagieren.

Alle Jobs auf den Minions sind auf dem Master mit ihren Rückgabewerten archivierbar.

Saltstack arbeitet als Python-Software letztlich mit dem Datentyp dictionary. Dass in Saltstack normalerweise YAML-Dateien geschrieben werden, ist nur die Oberfläche des Salzbergs. Saltstack kann letztlich alles entgegennehmen, was ein Python dictionary ausgibt, auch die YAML-Dateien laufen nur durch PyYAML. Im Verbund mit einer netzwerkfähigen Messagequeue und Dateisynchronisation erscheint der aktuelle Saltstack Slogan "Automatisierung des Rechenzentrums" sehr eng gegriffen. Vielmehr ist in allen Umgebungen, wo ein Python-Interpreter vorstellbar ist und noch kein Scheduler notwendig, Saltstack als Messagebus-Statemachine eine umfassende und verlässliche Variante, hochkomplexe Umgebungen zu verwalten.


