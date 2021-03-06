alias cd2='cd ../..'
alias cd3='cd ../../..'
alias cdcms='cd /js/websites/cms'
alias cdjslg='cd /js/logs'
alias cdm='cd /var/lib/mysql'
alias cdn='cd /opt/nginx/'
alias cdw='cd /js/websites'
alias cls='clear'
alias geml='gem list -ra  > /js/my/gem.lst 2>/dev/null & '
alias gemq='cat /js/my/gem.lst | grepi '
alias grepi='grep -i '
alias ldf='ls  --color=tty -ldF '
alias ldfa='ls --color=tty -ldF *'
alias ll='ls  --color=tty -la '
alias lld='clear;ls -l | grep ^d --color=tty'
alias llq='ls  --color=tty -la | grep -i '
alias myres='service mysqld restart'
alias nres='/opt/nginx/sbin/nginx -s stop;sleep 1;/opt/nginx/sbin/nginx'
alias nst='clear;netstat -anp | more'
alias on3='chkconfig --list | grep -i 3:on'
alias psq='ps -aux | grep -i '
alias reada='source /etc/profile.d/myalias.sh'
alias rpml='rpm -qa > /js/my/rpm.lst 2>/dev/null &'
alias rpmq='cat /js/my/rpm.lst | grepi '
alias via='vi /etc/profile.d/myalias.sh'
alias vimc='vi /etc/my.cnf'
alias vinc='vi /opt/nginx/conf/nginx.conf'
alias wgt='wget -S -O /dev/null '
alias yuml='yum list > /js/my/yum.lst 2>/dev/null & '
alias yumq='cat /js/my/yum.lst | grepi '
alias kusr1='kill -SIGUSR1 '
alias khup='kill -SIGHUP '
alias hisg='history | grep -i '
alias lsn='netstat -tunlp'
