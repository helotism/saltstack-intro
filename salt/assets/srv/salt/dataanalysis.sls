python3:
  pkg.installed:
    {% if grains['os'] == 'Ubuntu' %}
    - name: python3
    {% elif grains['os'] == 'Debian' %}
    - name: python3
    {% endif %}

pip3:
  pkg.installed:
    {% if grains['os'] == 'Ubuntu' %}
    - name: python3-pip 
    {% elif grains['os'] == 'Debian' %}
    - name: python3-pip 
    {% endif %}

pip3-needs-pip2:
  pkg.installed:
    {% if grains['os'] == 'Ubuntu' %}
    - name: python-pip 
    {% elif grains['os'] == 'Debian' %}
    - name: python-pip 
    {% endif %}

virtualenv3:
  pkg.installed:
    {% if grains['os'] == 'Ubuntu' %}
    - name: python3-venv
    {% elif grains['os'] == 'Debian' %}
    - name: python3-venv
    {% endif %}

jupyter notebook python3:
  pip.installed:
    - name: jupyter
    - bin_env: '/usr/bin/pip3'
#    - upgrade: True
    - require:
      - pkg: pip3
      - pkg: pip3-needs-pip2


dataanalysis python3-numpy:
  pkg.installed:
    - name: python3-numpy

dataanalysis python3-pandas:
  pkg.installed:
    - name: python3-pandas

dataanalysis python3-matplotlib:
  pkg.installed:
    - name: python3-matplotlib
