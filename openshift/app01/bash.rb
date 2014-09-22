module CodeRay module Scanners

  # http://www.redmine.org/boards/3/topics/29926
  # by Jared Bloomer

  # add rhc -- kill

  # cd ~/app-root/repo/vendor/bundle/ruby/1.9.1/gems/coderay-1.1.0/lib/coderay/scanners
  # bash.rb
  # cd ../helpers/
  # vi file_type.rb
  # ctl_all restart
  class BASH < Scanner

    register_for :bash

    KEYWORDS = %w(
      case   
      env
      exit export function
      getopts hash if import info  
      let local logname 
      read select seq set shift
      source trap
      tr true type ulimit umask uname unexpand uniq units unset unshar
      until 
      which while xargs yes # else done for in do then fi
    )

    OBJECTS = %w(
      $ -
    )

    COMMANDS = %w(
    rhc quota rake mysqldump cd cp cat mkdir touch pushd popd wget chmod rm ln awk mv tar kill
    arch basename bash cgclassify cgcreate cgdelete cgexec cgget cgset dash 
    dbus-cleanup-sockets dbus-daemon dbus-monitor dbus-send dmesg ed gettext 
    ipcalc kbd_mode keyctl link loadkeys login mktemp nano ping ping6 plymouth 
    readlink red rpm setfont setserial sort taskset tcsh tracepath tracepath6 
    true uname  accton arp arping audispd auditctl auditd aureport ausearch 
    autrace badblocks busybox cbq cfdisk cgconfigparser cgrulesengd chkconfig 
    consoletype crda cryptsetup ctrlaltdel debugfs delpart depmod dhclient 
    dhclient-script dm_dso_reg_tool dmsetup dosfsck dosfslabel e2fsck e2image 
    e2label e2undo echo ethtool faillock fdisk fixfiles fsadm fsck fsck.cramfs 
    fsck.ext2 fsck.ext3 fsck.ext4 fstab-decode fstrim fuser getkey grub grubby 
    grub-crypt grub-install grub-md5-crypt ifcfg ifconfig ifrename ifup init 
    initctl insmod install-info installkernel ip ip6tables-multi iptables-multi 
    iptunnel kexec kpartx ldconfig load_policy losetup MAKEDEV matchpathcon mdadm 
    mdmon microcode_ctl mii-diag mii-tool mkdosfs mke2fs mkfs mkfs.cramfs 
    mkfs.ext2 mkfs.ext3 mkfs.ext4 mkinitrd modinfo nameif netreport nologin 
    pam_console_apply pam_tally2 parted partx pccardctl plipconfig plymouthd rdisc 
    reboot request-key resize2fs rngd route rpcbind rsyslogd rtmon runuser setfiles 
    setpci setregdomain setsysfont sfdisk sgpio slattach sysctl tc telinit tune2fs  
    a2p ab abrt-action-analyze-backtrace abrt-action-analyze-c 
    abrt-action-analyze-core abrt-action-analyze-python 
    abrt-action-generate-backtrace abrt-action-install-debuginfo 
    abrt-action-list-dsos abrt-action-trim-files abrt-cli abrt-handle-upload ac 
    aconnect afs5log amixer aplay apu-1-config ar as aseqnet assistant_adp 
    assistant-qt4 at attr aulast aulastlog ausyscall autoconf automake 
    automake-1.11 autoreconf autoscan base64 bashbug-32 batch bc bison blkiomon 
    blkparse blktrace bmp2tiff bno_plot.py btparser btrace btrecord btreplay btt 
    c++ c2ph c89 c99 cal callgrind_annotate callgrind_control cas cas-admin 
    certmaster-getcert certutil c++filt cg_annotate cg_merge chacl chage chattr 
    chcon checkpolicy chfn chrt chsh ci cjpeg ck-launch-session ck-list-sessions 
    cloog cmp co col colcrt column comm compile_et config_data consolehelper 
    corelist crash crlutil cscope cscope-indexer ctags curl curl-config cytune 
    db_checkpoint db_codegen db_deadlock db_hotbackup dbilogstrip db_load db_upgrade 
    dbus-binding-tool dc debuginfo-install dig djpeg doxygen doxytag easy_install 
    easy_install-2.6 elinks enc2xs encode_keychange eqn eqn2graph erb eu-ar 
    eu-elfcmp eu-elflint eu-nm eu-readelf eu-size eu-strings eu-strip eu-unstrip 
    execstack expand factor fastjar fax2tiff fc-cache fc-list fc-match fc-query 
    fc-scan fgconsole file flex flock floppy fmt fold font2c fonttosfnt 
    foomatic-combo-xml foomatic-compiledb foomatic-configure foomatic-perl-data 
    foomatic-ppd-options foomatic-ppd-to-xml foomatic-rip funzip g++ gcc gcj-dbtool 
    gcore gdb gdk-pixbuf-query-loaders-32 genkey GET getcert getconf getent getfacl 
    getfattr getkeycodes gettextize gettext.sh gfortran gif2tiff gij git git-shell 
    git-upload-pack gjar gjarsigner gkeytool gorbd gpg2 gpg-agent gpgconf 
    gpg-connect-agent gpg-error gpgkey2ssh gpg-zip grn groff groffer grog grolbp 
    grolj4 gs gsbj gsdj gsdj500 gslj gslp gsnd gss-client gstack gst-feedback 
    gst-feedback-0.10 gst-inspect gst-inspect-0.10 gst-launch gst-launch-0.10 
    gst-xmlinspect gst-xmlinspect-0.10 gst-xmllaunch gst-xmllaunch-0.10 gzexe h2ph 
    h2xs hal-disable-polling hal-is-caller-locked-out hal-lock hal-setup-keymap 
    HEAD host hpftodit htdbm htdigest hugeadm hugectl hugeedit 
    huge_page_setup_helper.py hunspell i686-redhat-linux-c++ i686-redhat-linux-g++ 
    i686-redhat-linux-gcc iecset ifnames indent indxbib info infocmp infokey install 
    instmodsh intltool-extract intltoolize intltool-merge ipa-getcert ipcmk ipcs 
    isosize isql iusql join jpegtran kadmin kbdrate kdestroy keyrand keyutil kinit 
    klist krb5-config ktutil last lastcomm lastlog latrace lchfn lchsh ld ldb3del 
    ldb3edit ldb3modify ldb3rename ldb3search libnetcfg libtool libtoolize lkbib 
    logger logname look lookbib lpoptions ltrace lua luac lzmadec lzmainfo make man 
    man2html mbchk mcookie memhog merge mesg migratepages migspeed mkfontscale 
    mp2bug msgattrib msgcmp msgcomm msgen msgexec msgfilter msgfmt msghack msginit 
    msgmerge msgunfmt msguniq msql2mysql myisamchk myisamlog myisampack mysql 
    mysqlaccess mysqladmin mysqlbug mysqlcheck mysql_config mysqld_multi mysqld_safe 
    mysql_fix_extensions mysqlhotcopy mysqlimport mysql_install_db 
    mysql_secure_installation mysql_tzinfo_to_sql mysql_upgrade mysql_zap namei 
    ncurses5-config neqn net nfs4_getfacl nfs4_setfacl ngettext nm nmblookup nroff 
    nslookup numactl numademo objcopy ocs od odbc_config odbcinst opannotate 
    opcontrol openssl ophelp opimport package-cleanup pagesize pal2rgb patch pax 
    pdbedit pear pecl peekfd perf perl perl5.10.1 perlbug perldoc perlthanks perror 
    pf2afm phar.phar php php-cgi pic pic2graph pinentry pinentry-curses pinfo pinky 
    pk12util pkaction pkcheck pkexec pkg-config pl2pm pmap png2theora pod2html 
    pod2latex pod2man pod2text pod2usage podchecker podselect POST post-grohtml ppdc 
    ppdhtml ppdi ppdmerge ppdpo ppl-config ppm2tiff ptx pydoc python python2.6 qdbus 
    qtconfig-qt4 ras2tiff rcs rcsclean rcsmerge rdjpgcom readelf recode-sr-latin 
    refer rename replace repo-graph repomanage repoquery repo-rss report report-cli 
    reporter-upload repotrack resizecons rgb2ycbcr rlog rpcclient rpcgen rpmbuild 
    ruby runcon run-parts s2p sar sasl2-sample-client sclient script scriptreplay 
    secon selfsign-getcert seq setfacl setfattr setkeycodes setleds setmetamode 
    setup-nsssysinit.sh sharesec shred shuf signtool sim_client size smbclient 
    smbcontrol smbget smbspool smbtree snmpbulkget snmpconf snmpdelta snmpget 
    snmpgetnext snmptable snmptranslate snmptrap snmpusm soelim splain sqlite3 ssh 
    ssh-agent ssh-keygen ssh-keyscan ssltap stap stap-merge stap-report stdbuf 
    strace strings strip tabs tac tbl tfmtodit theora_encode theora_player 
    theora_player.bin thumbnail tic tiff2rgba tiffcmp tiffcrop tiffdither tiffinfo 
    tiffmedian tiffset tload toe tput tr trace-cmd troff tset tzselect ucs2any ul 
    unexpand uniq unshare unzip urlgrabber uuclient xargs xdg-icon-resource xdg-mime 
    xdg-open xdg-settings xgettext xmllint xml_merge xml_pp xml_spellcheck xxd xz 
    xzdec yacc yes ypchfn ypchsh ypmatch yum yum-config-manager yum-debug-restore 
    zcmp zforce zip zipcloak zipinfo zipnote  abrtd apachectl applygnupgdefaults 
    apxs arpd atd atrun biosdecode brctl certmonger cifs.upcall console-kit-daemon 
    cracklib-check cracklib-packer cracklib-unpacker create-cracklib-dict efibootmgr 
    eject exportfs filefrag foomatic-extract-text foomatic-fix-xml 
    foomatic-getpjloptions foomatic-kitload getcap getenforce getsebool 
    glibc_post_upgrade.i686 groupdel groupmems groupmod grpck gss_destroy_creds hald 
    htcacheclean httpd httxt2dbm ipa-client-install ipa-getkeytab ipa-join irqbalance 
    lchage ldattach lgroupdel lgroupmod logrotate lokkit lpadmin lpinfo luserdel 
    matahari-brokerd matahari-dbus-hostd matahari-qmf-hostd matahari-qmf-sysconfigd 
    mklost+found mksock mtr ntpd ntpdc ntp-keygen ntpq open_init_pty pethtool 
    pifconfig plymouth-set-default-theme postalias postconf postdrop postfix 
    postkick postlock postlog postmap postmulti postqueue restorecond rotatelogs 
    rpc.gssd rpcinfo rpc.nfsd rtacct run_init sa sasl2-shared-mechlist saslauthd 
    selinuxdefcon selinuxenabled setcap setenforce setsebool setup smartctl smartd 
    sm-notify smtp-sink smtp-source snmpd snmptrapd sosreport ss sshd sssd 
    sys-unconfig tickadj togglesebool try-from tunelp userdel userhelper usernetctl 
    ypbind yppoll yum-complete-transaction yumdb zic 
    accept accton adduser alsactl arping authconfig authconfig-tui cupsdisable cupsenable 
    cupsreject ethtool hwclock load_policy lpc lsusb matchpathcon mkdict packer ping6 
    pm-hibernate pm-suspend pm-suspend-hybrid reject sendmail system-config-network-cmd 
    system-config-network-tui tracepath tracepath6 update-alternatives vigr
    )

    PREDEFINED_TYPES = %w(
      char varchar varchar2 enum binary text tinytext mediumtext
      longtext blob tinyblob mediumblob longblob timestamp
      date time datetime year double decimal float int
      integer tinyint mediumint bigint smallint unsigned bit
      bool boolean hex bin oct
    )

    PREDEFINED_FUNCTIONS = %w( sum cast substring abs pi count min max avg now )

    DIRECTIVES = %w( 
      auto_increment unique default charset initially deferred
      deferrable cascade immediate read write asc desc after
      primary foreign return engine
    )

    PREDEFINED_CONSTANTS = %w( null true false )

    IDENT_KIND = WordList::CaseIgnoring.new(:ident).
      add(KEYWORDS, :keyword).
      add(OBJECTS, :type).
      add(COMMANDS, :class).
      add(PREDEFINED_TYPES, :predefined_type).
      add(PREDEFINED_CONSTANTS, :predefined_constant).
      add(PREDEFINED_FUNCTIONS, :predefined).
      add(DIRECTIVES, :directive)

    ESCAPE = / [rbfntv\n\\\/'"] | x[a-fA-F0-9]{1,2} | [0-7]{1,3} | . /mx
    UNICODE_ESCAPE =  / u[a-fA-F0-9]{4} | U[a-fA-F0-9]{8} /x

    STRING_PREFIXES = /[xnb]|_\w+/i

    def scan_tokens encoder, options

      state = :initial
      string_type = nil
      string_content = ''
      name_expected = false

      until eos?

        if state == :initial

          if match = scan(/ \s+ | \\\n /x)
            encoder.text_token match, :space

          elsif match = scan(/(?:--\s?|#).*/)
            encoder.text_token match, :comment

          elsif match = scan(%r( /\* (!)? (?: .*? \*/ | .* ) )mx)
            encoder.text_token match, self[1] ? :directive : :comment

          elsif match = scan(/ [*\/=<>:;,!&^|()\[\]{}~%] | [-+\.](?!\d) /x)
            name_expected = true if match == '.' && check(/[A-Za-z_]/)
            encoder.text_token match, :operator

          elsif match = scan(/(#{STRING_PREFIXES})?([`"'])/o)
            prefix = self[1]
            string_type = self[2]
            encoder.begin_group :string
            encoder.text_token prefix, :modifier if prefix
            match = string_type
            state = :string
            encoder.text_token match, :delimiter

          elsif match = scan(/ \$? [A-Za-z_][A-Za-z_0-9]* /x)
            encoder.text_token match, name_expected ? :ident : (match[0] == ?$ ? :variable : IDENT_KIND[match])
            name_expected = false

          elsif match = scan(/0[xX][0-9A-Fa-f]+/)
            encoder.text_token match, :hex

          elsif match = scan(/0[0-7]+(?![89.eEfF])/)
            encoder.text_token match, :octal

          elsif match = scan(/[-+]?(?>\d+)(?![.eEfF])/)
            encoder.text_token match, :integer

          elsif match = scan(/[-+]?(?:\d[fF]|\d*\.\d+(?:[eE][+-]?\d+)?|\d+[eE][+-]?\d+)/)
            encoder.text_token match, :float

          elsif match = scan(/\\N/)
            encoder.text_token match, :predefined_constant

          else
            encoder.text_token getch, :error

          end

        elsif state == :string
          if match = scan(/[^\\"'`]+/)
            string_content << match
            next
          elsif match = scan(/["'`]/)
            if string_type == match
              if peek(1) == string_type  # doubling means escape
                string_content << string_type << getch
                next
              end
              unless string_content.empty?
                encoder.text_token string_content, :content
                string_content = ''
              end
              encoder.text_token match, :delimiter
              encoder.end_group :string
              state = :initial
              string_type = nil
            else
              string_content << match
            end
          elsif match = scan(/ \\ (?: #{ESCAPE} | #{UNICODE_ESCAPE} ) /mox)
            unless string_content.empty?
              encoder.text_token string_content, :content
              string_content = ''
            end
            encoder.text_token match, :char
          elsif match = scan(/ \\ . /mox)
            string_content << match
            next
          elsif match = scan(/ \\ | $ /x)
            unless string_content.empty?
              encoder.text_token string_content, :content
              string_content = ''
            end
            encoder.text_token match, :error
            state = :initial
          else
            raise "else case \" reached; %p not handled." % peek(1), encoder
          end

        else
          raise 'else-case reached', encoder

        end

      end

      if state == :string
        encoder.end_group state
      end

      encoder

    end

  end

end end

