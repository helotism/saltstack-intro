python-pygit2:
  pkg.installed

#unsuccessful
#import pygit2
#bool(pygit2.features & pygit2.GIT_FEATURE_HTTPS)
#bool(pygit2.features & pygit2.GIT_FEATURE_SSH)
libssl-dev:
  pkg.installed

#workaround
#https://github.com/saltstack/salt/issues/35993#issuecomment-244584996
python-git:
  pkg.installed

workaround configuration:
  file.managed:
    - name: /etc/salt/master.d/90_winrepo_provider.conf
    - contents: |
        winrepo_provider: gitpython