#!/usr/bin/env bash
## filename: install_zabbix.sh
## psql 17
## zabbix 7.2 (not LTS)
## ver. 20250107
#####
## user root:
## OS OracleLinux 9.5 tested
#####
## alternative to inline script: $install_zabbix = <<-SCRIPT .. SCRIPT
## place this file "general_ol9.sh" at the location of the root Vagrantfile for your project
## and add to Vagrantfile:
## config.vm.provision "shell", path: "install_zabbix.sh", privileged: true
###
## run provisioning on running machine:
## vagrant provision
## REF: https://developer.hashicorp.com/vagrant/docs/provisioning
## START
start=$(date +%s)
echo "run this script from user root"
echo "start time:"
date
# shellcheck disable=SC1091
# ls -la
# rm -f /root/.env
[[ -s /root/.env ]] && . /root/.env && cat /root/.env
# SERVER_NAME=$1
# PASS_LENGHT=$2
# psql_ver=16
SERVER_NAME=zabbix.local
PASS_LENGHT=8
psql_ver=17
RHEL_VER=$(rpm -E '%{rhel}')

if [[ -z "$POSTGRES_PASS" ]]; then
    POSTGRES_PASS=$(tr -dc 'A-Za-z0-9!#$%&*+,-.?@_' </dev/urandom | head -c "$PASS_LENGHT")
    echo "POSTGRES_PASS=${POSTGRES_PASS}" >> /root/.env
    echo "POSTGRES_PASS=${POSTGRES_PASS}"
fi

if [[ -z "$ZABBIX_PG_PASS" ]]; then
    ZABBIX_PG_PASS=$(tr -dc 'A-Za-z0-9!#$%&*+,-.?@_' </dev/urandom | head -c "$PASS_LENGHT")
    echo "ZABBIX_PG_PASS=${ZABBIX_PG_PASS}" >> /root/.env
    echo "ZABBIX_PG_PASS=${ZABBIX_PG_PASS}"
fi

# echo $POSTGRES_PASS
# echo $ZABBIX_PG_PASS

general () {
    dnf -y install glibc-all-langpacks
    dnf -y install oracle-epel-release-el9
    dnf config-manager --set-enabled ol9_codeready_builder
    dnf -y install mc unzip zstd pv neovim htop nethogs nload inxi lsof socat ncdu tmux
    dnf -y install bzip2-devel libffi-devel xz-devel xz-libs ncurses-devel sqlite-devel
    dnf -y install python3.11 python3.11-devel python3.11-test python3.11-idle python3.11-wheel
}

php_install () {
    # REF: https://rpms.remirepo.net/wizard/
    # # dnf config-manager --set-enabled crb # OL9 - crb replaced with ol9_codeready_builder
    dnf config-manager --enable ol9_codeready_builder
    dnf -y install https://rpms.remirepo.net/enterprise/remi-release-9.rpm
    sed -i -r 's/^#baseurl/baseurl/g;s/^mirrorlist=/#mirrorlist=/' /etc/yum.repos.d/remi*.repo
    dnf config-manager --set-enabled remi
    dnf module reset php
    dnf module list php
    dnf module enable php:remi-8.3 -y
    dnf -y module install php:remi-8.3
    # php --version
    # 20250106: php 8.4 total errors in zabbix UI:
    # CApiService::addAuditBulk(): Implicitly marking parameter $objects_old as nullable is deprecated, the explicit nullable type must be used instead require_once()
}

nginx_install () {
    #tee /etc/yum.repos.d/nginx.repo <<EOL
    #EOL
    {
        echo "[nginx-stable]"
        echo "name=nginx stable repo"
        echo 'baseurl=http://nginx.org/packages/centos/$releasever/$basearch/'
        echo "gpgcheck=1"
        echo "enabled=1"
        echo "gpgkey=https://nginx.org/keys/nginx_signing.key"
        echo "module_hotfixes=true"
        echo ""
        echo "[nginx-mainline]"
        echo "name=nginx mainline repo"
        echo 'baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/'
        echo "gpgcheck=1"
        echo "enabled=0"
        echo "gpgkey=https://nginx.org/keys/nginx_signing.key"
        echo "module_hotfixes=true"
    } > /etc/yum.repos.d/nginx.repo
    dnf -y install nginx
}

postgresql_install () {
    # shellcheck disable=SC1083
    dnf -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
    dnf -qy module disable postgresql
    dnf -y install -y postgresql$psql_ver-server postgresql$psql_ver-contrib #postgresql$psql_ver-devel 
    echo "export PATH=/usr/pgsql-$psql_ver/bin:\$PATH" >> /etc/bashrc
    # shellcheck disable=SC1091
    . /etc/bashrc
	echo '$PATH:'
	echo $PATH
    "/usr/pgsql-$psql_ver/bin/postgresql-$psql_ver-setup" initdb
    systemctl enable --now postgresql-"$psql_ver"
    sudo -u postgres /usr/pgsql-"$psql_ver"/bin/psql -c "ALTER USER postgres WITH PASSWORD '$POSTGRES_PASS';"
    sed -i 's|\(^local   all.*\) peer$|\1 scram-sha-256|g' "/var/lib/pgsql/$psql_ver/data/pg_hba.conf"
    systemctl restart postgresql-"$psql_ver"
}

timescaledb_install () {
    {
        echo "[timescale_timescaledb]"
        echo "name=timescale_timescaledb"
        echo 'baseurl=https://packagecloud.io/timescale/timescaledb/el/9/$basearch'
        echo "repo_gpgcheck=1"
        echo "gpgcheck=0"
        echo "enabled=1"
        echo "gpgkey=https://packagecloud.io/timescale/timescaledb/gpgkey"
        echo "sslverify=1"
        echo "sslcacert=/etc/pki/tls/certs/ca-bundle.crt"
        echo "metadata_expire=300"
    } > /etc/yum.repos.d/timescale_timescaledb.repo
    dnf -y install timescaledb-2-postgresql-$psql_ver
    timescaledb-tune -yes
    systemctl restart postgresql-"$psql_ver"
}

zabbix_install () {
    echo "excludepkgs=zabbix*" >> "/etc/yum.repos.d/oracle-epel-ol$RHEL_VER.repo"
    # # dnf -y install "https://repo.zabbix.com/zabbix/6.4/rhel/$RHEL_VER/x86_64/zabbix-release-6.4-1.el$RHEL_VER.noarch.rpm"
    rpm -Uvh https://repo.zabbix.com/zabbix/7.2/release/oracle/9/noarch/zabbix-release-latest-7.2.el9.noarch.rpm
    dnf -y install zabbix-server-pgsql zabbix-web-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent
    #
    sudo -u postgres env PGPASSWORD="$POSTGRES_PASS" bash -c "createuser -U postgres zabbix"
    sudo -u postgres env PGPASSWORD="$POSTGRES_PASS" ZABBIX_PG_PASSWORD="$ZABBIX_PG_PASS" bash -c "psql -U postgres -c \"ALTER USER zabbix WITH PASSWORD '\$ZABBIX_PG_PASSWORD';\""
    # PGPASSWORD="$POSTGRES_PASS" createdb -U postgres -O zabbix zabbix
    sudo -u postgres env PGPASSWORD="$POSTGRES_PASS" bash -c "createdb -U postgres -O zabbix zabbix"
    # CHECK zabbix user and db:
    # echo $ZABBIX_PG_PASS
    # psql -U zabbix
    # \l #list databases
    # \q
    zcat /usr/share/zabbix/sql-scripts/postgresql/server.sql.gz | PGPASSWORD="$ZABBIX_PG_PASS" psql -U zabbix -d zabbix
    PGPASSWORD="$POSTGRES_PASS" psql -U postgres -d zabbix -c "CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;"
    PGPASSWORD="$ZABBIX_PG_PASS" psql -U zabbix -d zabbix < /usr/share/zabbix/sql-scripts/postgresql/timescaledb/schema.sql

    # firewall-cmd --add-service=http --permanent
    # firewall-cmd --add-service=https --permanent
    # firewall-cmd --add-service=zabbix-agent --permanent
    # firewall-cmd --add-service=zabbix-server --permanent
    # firewall-cmd --permanent --zone=public --add-port=8080/tcp
    # firewall-cmd --reload

    sed -i -r "s/^#        listen          8080;/        listen          80;/" /etc/nginx/conf.d/zabbix.conf
    sed -i -r "s/^#        server_name     example.com;/        server_name     $SERVER_NAME;/" /etc/nginx/conf.d/zabbix.conf
    sed -i -r "s/^    listen       80;/    listen       8080;/" /etc/nginx/conf.d/default.conf
    sed -i -r "s/^    server_name  localhost;/    server_name  $SERVER_NAME;/" /etc/nginx/conf.d/default.conf

    sed -i -r "s/^# DBPassword=/DBPassword=$ZABBIX_PG_PASS/" /etc/zabbix/zabbix_server.conf
    sed -i -r "s/^StatsAllowedIP=127.0.0.1/StatsAllowedIP=127.0.0.1,$SERVER_NAME/" /etc/zabbix/zabbix_server.conf
    #CHECK zabbix conf:
	echo "zabbix conf extract:"
    cat /etc/zabbix/zabbix_server.conf | grep -Ev "^#|^$"
    echo "php_value[date.timezone] = Europe/Kyiv" >> /etc/php-fpm.d/zabbix.conf
    systemctl enable --now nginx php-fpm zabbix-server zabbix-agent
}
general
php_install
nginx_install
postgresql_install
timescaledb_install
zabbix_install
## restart:
# systemctl restart nginx
# systemctl restart php-fpm.service
# systemctl restart zabbix-server.service
#
# default login: Admin, passwprd: zabbix
# 
# tail /var/log/zabbix/zabbix_server.log
## runtime
end=$(date +%s)
runtime=$((end-start))
minutes=$((runtime / 60))
seconds=$((runtime % 60))
echo "runtime=$minutes minutes and $seconds seconds"
## REF runtime: https://unix.stackexchange.com/a/52347
echo "finish time:"
date
echo 'to finish setup Zabbix at WEB UI refer to https://www.zabbix.com/documentation/7.2/en/manual/installation/frontend'
## END
