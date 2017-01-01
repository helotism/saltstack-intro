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
