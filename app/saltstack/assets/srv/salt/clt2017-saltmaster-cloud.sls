python-pygit2:
  pkg.installed

salt-master:
  service.running:
    - enable: True
    - name: salt-master
    - watch:
      - file: /etc/salt/*

/etc/salt/cloud.providers.d/cloudprovider_digitalocean.conf:
  file.managed:
    - source: salt://cloud-demo/cloudprovider_digitalocean.conf
    - template: jinja
/etc/salt/cloud.profiles.d/cloudprofile_digitalocean.conf:
  file.managed:
    - source: salt://cloud-demo/cloudprofile_digitalocean.conf

workaround configuration:
  file.managed:
    - name: /etc/salt/master.d/90_winrepo_provider.conf
    - contents: |
        winrepo_provider: gitpython