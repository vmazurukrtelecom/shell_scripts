#!/usr/bin/env bash
## filename: install_awx17_OL8.sh
## ver. 202501
## add to Vagrantfile:
## config.vm.provision "shell", path: "https://raw.githubusercontent.com/vmazurukrtelecom/shell_scripts/refs/heads/main/install_awx17_OL8.sh"
### AWX 17 - last ver running in Docker!
### starting AWX 18 - installation only via awx-operator and k8s (k3s)
##
## OL8 only !!
## OL9 not work via  kernel change cgroups (libcgroup) to v2
###
## REF MAIN: https://github.com/ansible/awx/blob/17.1.0/INSTALL.md#docker-compose
#####
## AWX v 17.1.0 = docker-compose format v1
# last Docker Compose, supporting format v1 (old file formats docker-compose.yml) = Docker Compose 1.28.x.
## so need install specific ver of:
# python (3.6 (3.9 (?)))
# docker 20.10.x (v1 comp. max 23.0) // prefer 19.x !!
# docker-compose via pip 1.28.x (max)
# ansible (via pip) 2.9.x (max) 
# docker (via pip) 6.* (max) (docker-py alternative (?))
##
## START
start=$(date +%s)
echo "start time:"
date
##
sudo dnf install python3 python3-pip python3-wheel
alternatives --list
sudo alternatives --set python /usr/bin/python3
sudo alternatives --list
# [vagrant@localhost installer]$ sudo alternatives --list
# libnssckbi.so.x86_64    auto    /usr/lib64/pkcs11/p11-kit-trust.so
# python                  manual  /usr/bin/python3
# ld                      auto    /usr/bin/ld.bfd
# modules.sh              auto    /usr/share/Modules/init/profile.sh
# python3                 auto    /usr/bin/python3.6
# [vagrant@localhost installer]$
#
python3 -V
python -V
sudo python3 -m pip install --upgrade pip
sudo python -m pip -V
##
sudo python -m pip install ansible==2.9.*
ansible --version
# [vagrant@localhost ~]$ ansible --version
# /usr/local/lib/python3.6/site-packages/ansible/parsing/vault/__init__.py:44: CryptographyDeprecationWarning: Python 3.6 is no longer supported by the Python core team. Therefore, support for it is deprecated in cryptography. The next release of cryptography will remove support for Python 3.6.
# from cryptography.exceptions import InvalidSignature
# ansible 2.9.27
# config file = None
# configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
# ansible python module location = /usr/local/lib/python3.6/site-packages/ansible
# executable location = /usr/local/bin/ansible
# python version = 3.6.8 (default, Dec  4 2024, 01:35:34) [GCC 8.5.0 20210514 (Red Hat 8.5.0-22.0.1)]
# [vagrant@localhost ~]$
##
##
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf list docker-ce --showduplicates
sudo dnf install docker-ce-3:19.03.15-3.el8 -y --setopt=install_weak_deps=False
##
sudo systemctl enable docker
sudo docker version
sudo systemctl start docker
sudo systemctl status docker
sudo docker version
# [vagrant@localhost installer]$ sudo docker version
# Client: Docker Engine - Community
# Version:           26.1.3
# API version:       1.40 (downgraded from 1.45)
# Go version:        go1.21.10
# Git commit:        b72abbb
# Built:             Thu May 16 08:34:39 2024
# OS/Arch:           linux/amd64
# Context:           default
###
# Server: Docker Engine - Community
# Engine:
# Version:          19.03.15
# API version:      1.40 (minimum version 1.12)
# Go version:       go1.13.15
# Git commit:       99e3ed8919
# Built:            Sat Jan 30 03:15:19 2021
# OS/Arch:          linux/amd64
# Experimental:     false
# containerd:
# Version:          1.6.32
# GitCommit:        8b3b7ca2e5ce38e8f31a34f35b2b68ceb8470d89
# runc:
# Version:          1.1.12
# GitCommit:        v1.1.12-0-g51d5e94
# docker-init:
# Version:          0.18.0
# GitCommit:        fec3683
# [vagrant@localhost installer]$
##
sudo usermod -aG docker $USER
newgrp docker
id
## TEST:
docker run hello-world
##
##
ansible-galaxy collection install community.docker
# [vagrant@localhost ~]$ ansible-galaxy collection install community.docker
# /usr/local/lib/python3.6/site-packages/ansible/parsing/vault/__init__.py:44: CryptographyDeprecationWarning: Python 3.6 is no longer supported by the Python core team. Therefore, support for it is deprecated in cryptography. The next release of cryptography will remove support for Python 3.6.
# from cryptography.exceptions import InvalidSignature
# Process install dependency map
# Starting collection install process
# Installing 'community.docker:4.3.1' to '/home/vagrant/.ansible/collections/ansible_collections/community/docker'
# Installing 'community.library_inventory_filtering_v1:1.0.2' to '/home/vagrant/.ansible/collections/ansible_collections/community/library_inventory_filtering_v1'
# [vagrant@localhost ~]$ 
##
##
python -m pip install docker-compose==1.28.*
##
docker-compose version
##
#/home/vagrant/.local/lib/python3.6/site-packages/paramiko/transport.py:32: CryptographyDeprecationWarning: Python 3.6 is no longer supported by the Python core team. Therefore, support for it is deprecated in cryptography. The next release of cryptography will remove support for Python 3.6.
#  from cryptography.hazmat.backends import default_backend
#docker-compose version 1.28.6, build unknown
#docker-py version: 4.4.4
#CPython version: 3.6.8
#OpenSSL version: OpenSSL 1.1.1k  FIPS 25 Mar 2021
#
## VERSIONS:
# [vagrant@localhost installer]$ pip list
# Package            Version
# ------------------ ---------
# ansible            2.9.27
# attrs              22.2.0
# bcrypt             4.0.1
# cached-property    1.5.2
# certifi            2025.1.31
# cffi               1.15.1
# charset-normalizer 2.0.12
# configshell-fb     1.1.28
# cryptography       40.0.2
# dbus-python        1.2.4
# decorator          4.2.1
# distro             1.9.0
# docker             4.4.4
# docker-compose     1.28.6
# dockerpty          0.4.1
# docopt             0.6.2
# gpg                1.13.1
# idna               3.10
# importlib-metadata 4.8.3
# Jinja2             3.0.3
# jsonschema         3.2.0
# kmod               0.1
# libcomps           0.1.18
# MarkupSafe         2.0.1
# nftables           0.1
# nvmetcli           0.7
# paramiko           3.5.0
# pip                21.3.1
# pycparser          2.21
# PyGObject          3.28.3
# PyNaCl             1.5.0
# pyparsing          2.1.10
# pyrsistent         0.18.0
# python-dateutil    2.6.1
# python-dotenv      0.20.0
# PyYAML             5.4.1
# requests           2.27.1
# rpm                4.14.3
# selinux            2.9
# sepolicy           1.1
# setools            4.3.0
# setuptools         39.2.0
# six                1.11.0
# slip               0.6.4
# slip.dbus          0.6.4
# systemd-python     234
# texttable          1.7.0
# typing_extensions  4.1.1
# urllib3            1.26.20
# urwid              1.3.1
# websocket-client   0.59.0
# wheel              0.31.1
# zipp               3.6.0
# [vagrant@localhost installer]$
####
## AWX 17
git clone -b 17.1.0 https://github.com/ansible/awx.git
cd ./awx
# git log
sed -i 's/# admin_password=password/admin_password=Ansible123!/' ./installer/inventory
git diff
cd ./installer
cat inventory |grep -v "#" |grep .
#
## RUN:
ansible-playbook -i inventory install.yml -vv
##
# ERR:
# TASK [local_docker : Check for existing Postgres data (run from inside the container for access to file)] **********************************************************
# task path: /home/vagrant/awx/installer/roles/local_docker/tasks/upgrade_postgres.yml:16
# fatal: [localhost]: FAILED! => {"changed": true, "cmd": "docker run --rm -v '/home/vagrant/.awx/pgdocker:/var/lib/postgresql' centos:8 bash -c  \"[[ -f /var/lib/postgresql/10/data/PG_VERSION ]] && echo 'exists'\"\n", "delta": "0:00:36.572735", "end": "2025-01-30 19:10:53.677222", "msg": "non-zero return code", "rc": 1, "start": "2025-01-30 19:10:17.104487", "stderr": "Unable to find image 'centos:8' locally\n8: Pulling from library/centos\na1d0c7532777: Pulling fs layer\na1d0c7532777: Verifying Checksum\na1d0c7532777: Download complete\na1d0c7532777: Pull complete\nDigest: sha256:a27fd8080b517143cbbbab9dfb7c8571c40d67d534bbdee55bd6c473f432b177\nStatus: Downloaded newer image for centos:8", "stderr_lines": ["Unable to find image 'centos:8' locally", "8: Pulling from library/centos", "a1d0c7532777: Pulling fs layer", "a1d0c7532777: Verifying Checksum", "a1d0c7532777: Download complete", "a1d0c7532777: Pull complete", "Digest: sha256:a27fd8080b517143cbbbab9dfb7c8571c40d67d534bbdee55bd6c473f432b177", "Status: Downloaded newer image for centos:8"], "stdout": "", "stdout_lines": []}
# ...ignoring
# --- its normal via there are not yet amy postgress container
####
# FIN_ERR (all ok but only not finished create_preload_data (def org, etc)
#
# TASK [local_docker : Wait for launch script to create user] ********************************************************************************************************
# task path: /home/vagrant/awx/installer/roles/local_docker/tasks/compose.yml:64
# ok: [localhost -> localhost] => {"changed": false, "elapsed": 10, "match_groupdict": {}, "match_groups": [], "path": null, "port": null, "search_regex": null, "state": "started"}
#
# TASK [local_docker : Create Preload data] **************************************************************************************************************************
# task path: /home/vagrant/awx/installer/roles/local_docker/tasks/compose.yml:69
# fatal: [localhost]: FAILED! => {"changed": false, "cmd": ["docker", "exec", "awx_task", "bash", "-c", "/usr/bin/awx-manage create_preload_data"], "delta": "0:00:16.562424", "end": "2025-01-30 19:21:43.636726", "msg": "non-zero return code", "rc": 1, "start": "2025-01-30 19:21:27.074302", "stderr": "Traceback (most recent call last):\n  File \"/usr/bin/awx-manage\", line 8, in <module>\n    sys.exit(manage())\n  File \"/var/lib/awx/venv/awx/lib/python3.6/site-packages/awx/__init__.py\", line 154, in manage\n    execute_from_command_line(sys.argv)\n  File \"/var/lib/awx/venv/awx/lib/python3.6/site-packages/django/core/management/__init__.py\", line 381, in execute_from_command_line\n    utility.execute()\n  File \"/var/lib/awx/venv/awx/lib/python3.6/site-packages/django/core/management/__init__.py\", line 375, in execute\n    self.fetch_command(subcommand).run_from_argv(self.argv)\n  File \"/var/lib/awx/venv/awx/lib/python3.6/site-packages/django/core/management/base.py\", line 323, in run_from_argv\n    self.execute(*args, **cmd_options)\n  File \"/var/lib/awx/venv/awx/lib/python3.6/site-packages/django/core/management/base.py\", line 364, in execute\n    output = self.handle(*args, **options)\n  File \"/var/lib/awx/venv/awx/lib/python3.6/site-packages/awx/main/management/commands/create_preload_data.py\", line 41, in handle\n    'username': superuser.username\nAttributeError: 'NoneType' object has no attribute 'username'", "stderr_lines": ["Traceback (most recent call last):", "  File \"/usr/bin/awx-manage\", line 8, in <module>", "    sys.exit(manage())", "  File \"/var/lib/awx/venv/awx/lib/python3.6/site-packages/awx/__init__.py\", line 154, in manage", "    execute_from_command_line(sys.argv)", "  File \"/var/lib/awx/venv/awx/lib/python3.6/site-packages/django/core/management/__init__.py\", line 381, in execute_from_command_line", "    utility.execute()", "  File \"/var/lib/awx/venv/awx/lib/python3.6/site-packages/django/core/management/__init__.py\", line 375, in execute", "    self.fetch_command(subcommand).run_from_argv(self.argv)", "  File \"/var/lib/awx/venv/awx/lib/python3.6/site-packages/django/core/management/base.py\", line 323, in run_from_argv", "    self.execute(*args, **cmd_options)", "  File \"/var/lib/awx/venv/awx/lib/python3.6/site-packages/django/core/management/base.py\", line 364, in execute", "    output = self.handle(*args, **options)", "  File \"/var/lib/awx/venv/awx/lib/python3.6/site-packages/awx/main/management/commands/create_preload_data.py\", line 41, in handle", "    'username': superuser.username", "AttributeError: 'NoneType' object has no attribute 'username'"], "stdout": "", "stdout_lines": []}
#
# PLAY RECAP *********************************************************************************************************************************************************
# localhost                  : ok=20   changed=11   unreachable=0    failed=1    skipped=73   rescued=0    ignored=1
#
# [vagrant@localhost installer]$
####
####
## ADDIT CHECKS:
# docker logs -f awx_task  
docker ps -a
docker images -a
##
# [vagrant@localhost ~]$ docker ps -a
# CONTAINER ID   IMAGE                COMMAND                  CREATED          STATUS                      PORTS                  NAMES
# f9857e04b09d   ansible/awx:17.1.0   "/usr/bin/tini -- /u…"   51 seconds ago   Up 44 seconds               8052/tcp               awx_task
# 23b342e6b88b   ansible/awx:17.1.0   "/usr/bin/tini -- /b…"   8 minutes ago    Up 44 seconds               0.0.0.0:80->8052/tcp   awx_web
# fecef8ded0e5   redis                "docker-entrypoint.s…"   9 minutes ago    Up 44 seconds               6379/tcp               awx_redis
# 20640123b4fc   postgres:12          "docker-entrypoint.s…"   9 minutes ago    Up 44 seconds               5432/tcp               awx_postgres
# 784028388dd1   hello-world          "/hello"                 43 minutes ago   Exited (0) 43 minutes ago                          agitated_solomon
# [vagrant@localhost ~]$ docker images -a
# REPOSITORY    TAG       IMAGE ID       CREATED        SIZE
# hello-world   latest    74cc54e27dc4   9 days ago     10.1kB
# redis         latest    4075a3f8c3f8   3 weeks ago    117MB
# postgres      12        56fe80523f20   2 months ago   419MB
# centos        8         5d0da3dc9764   3 years ago    231MB
# ansible/awx   17.1.0    599918776cf2   3 years ago    1.41GB
# [vagrant@localhost ~]$
##
## CHECK USER:
# docker exec -it awx_postgres /bin/bash
# psql -U awx
# SELECT username FROM auth_user WHERE is_superuser = true LIMIT 1;
# quit;
##
######
######
## awx-python - its VENV inside of awx_task
# docker exec -it awx_task /bin/bash
# source /var/lib/awx/venv/awx/bin/activate
## and than python -m pip install **
##
##### TRY OL9:
sudo dnf install -y docker-ce-3:19.03.15-3
# Last metadata expiration check: 0:00:47 ago on Thu 30 Jan 2025 09:20:25 PM EET.
# No match for argument: docker-ce-3:19.03.15-3
# Error: Unable to find a match: docker-ce-3:19.03.15-3
## wget https://download.docker.com/linux/centos/8/x86_64/stable/Packages/docker-ce-19.03.15-3.el8.x86_64.rpm
## sudo dnf localinstall --nobest ./docker-ce-19.03.15-3.el8.x86_64.rpm
# Error:
# Problem: conflicting requests
# - nothing provides libcgroup needed by docker-ce-3:19.03.15-3.el8.x86_64 from @commandline
# sudo dnf search libcgroup
# Last metadata expiration check: 0:01:39 ago on Thu 30 Jan 2025 09:28:48 PM EET.
# No matches found.
# wget ftp://ftp.icm.edu.pl/vol/rzm7/linux-centos-vault/8.0.1905/BaseOS/x86_64/kickstart/Packages/libcgroup-0.41-19.el8.x86_64.rpm
# sudo dnf localinstall --nobest ./libcgroup-0.41-19.el8.x86_64.rpm
# sudo dnf localinstall ./docker-ce-19.03.15-3.el8.x86_64.rpm --setopt=install_weak_deps=False
docker run hello-world
# docker: Error response from daemon: cgroups: cgroup mountpoint does not exist: unknown.
# [vagrant@localhost ~]$ ll /sys/fs/cgroup/systemd
# ls: cannot access '/sys/fs/cgroup/systemd': No such file or directory
# !!!
# edit the /etc/docker/daemon.json file (create it if it doesn't exist) and add the following:
# json
# {
#  "exec-opts": ["native.cgroupdriver=systemd"]
# }
# 
# [vagrant@localhost ~]$ sudo mkdir /sys/fs/cgroup/systemd
# [vagrant@localhost ~]$ sudo mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd
# [vagrant@localhost ~]$ sudo systemctl restart docker
# REF: https://github.com/docker/for-linux/issues/219#issuecomment-375160449
#
#
### BUT OL9 fail (( VIA cgroups ))
# ERR:
# #TASK [local_docker : Remove AWX containers before migrating postgres so that the old postgres container does not get used] *****************************************
# task path: /home/vagrant/awx/installer/roles/local_docker/tasks/compose.yml:39
# fatal: [localhost]: FAILED! => {"changed": false, "msg": "Error connecting: Error while fetching server API version: Not supported URL scheme http+docker"}
# ...ignoring

# TASK [local_docker : Run migrations in task container] *************************************************************************************************************
# task path: /home/vagrant/awx/installer/roles/local_docker/tasks/compose.yml:45
# fatal: [localhost]: FAILED! => {"changed": true, "cmd": "docker-compose run --rm --service-ports task awx-manage migrate --no-input", "delta": "0:00:00.892207", "end": "2025-01-31 11:56:06.286698", "msg": "non-zero return code", "rc": 1, "start": "2025-01-31 11:56:05.394491", "stderr": "Traceback (most recent call last):\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/requests/adapters.py\", line 633, in send\n    conn = self.get_connection_with_tls_context(\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/requests/adapters.py\", line 489, in get_connection_with_tls_context\n    conn = self.poolmanager.connection_from_host(\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/urllib3/poolmanager.py\", line 303, in connection_from_host\n    return self.connection_from_context(request_context)\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/urllib3/poolmanager.py\", line 325, in connection_from_context\n    raise URLSchemeUnknown(scheme)\nurllib3.exceptions.URLSchemeUnknown: Not supported URL scheme http+docker\n\nDuring handling of the above exception, another exception occurred:\n\nTraceback (most recent call last):\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/docker/api/client.py\", line 214, in _retrieve_server_version\n    return self.version(api_version=False)[\"ApiVersion\"]\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/docker/api/daemon.py\", line 181, in version\n    return self._result(self._get(url), json=True)\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/docker/utils/decorators.py\", line 46, in inner\n    return f(self, *args, **kwargs)\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/docker/api/client.py\", line 237, in _get\n    return self.get(url, **self._set_request_timeout(kwargs))\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/requests/sessions.py\", line 602, in get\n    return self.request(\"GET\", url, **kwargs)\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/requests/sessions.py\", line 589, in request\n    resp = self.send(prep, **send_kwargs)\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/requests/sessions.py\", line 703, in send\n    r = adapter.send(request, **kwargs)\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/requests/adapters.py\", line 637, in send\n    raise InvalidURL(e, request=request)\nrequests.exceptions.InvalidURL: Not supported URL scheme http+docker\n\nDuring handling of the above exception, another exception occurred:\n\nTraceback (most recent call last):\n  File \"/home/vagrant/.local/bin/docker-compose\", line 8, in <module>\n    sys.exit(main())\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/compose/cli/main.py\", line 81, in main\n    command_func()\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/compose/cli/main.py\", line 198, in perform_command\n    project = project_from_options('.', options)\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/compose/cli/command.py\", line 60, in project_from_options\n    return get_project(\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/compose/cli/command.py\", line 152, in get_project\n    client = get_client(\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/compose/cli/docker_client.py\", line 41, in get_client\n    client = docker_client(\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/compose/cli/docker_client.py\", line 170, in docker_client\n    client = APIClient(use_ssh_client=not use_paramiko_ssh, **kwargs)\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/docker/api/client.py\", line 197, in __init__\n    self._version = self._retrieve_server_version()\n  File \"/home/vagrant/.local/lib/python3.9/site-packages/docker/api/client.py\", line 221, in _retrieve_server_version\n    raise DockerException(\ndocker.errors.DockerException: Error while fetching server API version: Not supported URL scheme http+docker", "stderr_lines": ["Traceback (most recent call last):", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/requests/adapters.py\", line 633, in send", "    conn = self.get_connection_with_tls_context(", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/requests/adapters.py\", line 489, in get_connection_with_tls_context", "    conn = self.poolmanager.connection_from_host(", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/urllib3/poolmanager.py\", line 303, in connection_from_host", "    return self.connection_from_context(request_context)", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/urllib3/poolmanager.py\", line 325, in connection_from_context", "    raise URLSchemeUnknown(scheme)", "urllib3.exceptions.URLSchemeUnknown: Not supported URL scheme http+docker", "", "During handling of the above exception, another exception occurred:", "", "Traceback (most recent call last):", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/docker/api/client.py\", line 214, in _retrieve_server_version", "    return self.version(api_version=False)[\"ApiVersion\"]", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/docker/api/daemon.py\", line 181, in version", "    return self._result(self._get(url), json=True)", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/docker/utils/decorators.py\", line 46, in inner", "    return f(self, *args, **kwargs)", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/docker/api/client.py\", line 237, in _get", "    return self.get(url, **self._set_request_timeout(kwargs))", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/requests/sessions.py\", line 602, in get", "    return self.request(\"GET\", url, **kwargs)", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/requests/sessions.py\", line 589, in request", "    resp = self.send(prep, **send_kwargs)", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/requests/sessions.py\", line 703, in send", "    r = adapter.send(request, **kwargs)", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/requests/adapters.py\", line 637, in send", "    raise InvalidURL(e, request=request)", "requests.exceptions.InvalidURL: Not supported URL scheme http+docker", "", "During handling of the above exception, another exception occurred:", "", "Traceback (most recent call last):", "  File \"/home/vagrant/.local/bin/docker-compose\", line 8, in <module>", "    sys.exit(main())", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/compose/cli/main.py\", line 81, in main", "    command_func()", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/compose/cli/main.py\", line 198, in perform_command", "    project = project_from_options('.', options)", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/compose/cli/command.py\", line 60, in project_from_options", "    return get_project(", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/compose/cli/command.py\", line 152, in get_project", "    client = get_client(", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/compose/cli/docker_client.py\", line 41, in get_client", "    client = docker_client(", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/compose/cli/docker_client.py\", line 170, in docker_client", "    client = APIClient(use_ssh_client=not use_paramiko_ssh, **kwargs)", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/docker/api/client.py\", line 197, in __init__", "    self._version = self._retrieve_server_version()", "  File \"/home/vagrant/.local/lib/python3.9/site-packages/docker/api/client.py\", line 221, in _retrieve_server_version", "    raise DockerException(", "docker.errors.DockerException: Error while fetching server API version: Not supported URL scheme http+docker"], "stdout": "", "stdout_lines": []}

# PLAY RECAP *********************************************************************************************************************************************************
# localhost                  : ok=15   changed=3    unreachable=0    failed=1    
#
## RESULT in WEB http://IP/
# Ansible AWX
# ______________ 
# <  AWX 17.1.0  >
# -------------- 
# \
# \   ^__^
# (oo)\_______
# (__)      A )\
# ||----w |
# ||     ||
#
# Ansible Version
# 2.9.18
# Copyright 2019 Red Hat, Inc.
##
echo "finish time:"
date
## runtime
end=$(date +%s)
runtime=$((end-start))
minutes=$((runtime / 60))
seconds=$((runtime % 60))
echo "runtime=$minutes minutes and $seconds seconds"
## FINISH
