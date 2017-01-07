base:
  'kernel:Linuxxxxx':
    - match: grain
    - common
    - users

  'minion-on-saltmaster':
    - saltmaster
    - dataanalysis


  'G@os_family:Arch and G@init:systemd':
    - match: compound
    - tutorial/remoteloggingdeps
