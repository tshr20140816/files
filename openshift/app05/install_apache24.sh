#!/bin/bash

export TZ=JST-9
set -x
quota -s
oo-cgroup-read memory.usage_in_bytes
oo-cgroup-read memory.failcnt

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

# pcre

cd /tmp
tmp_dir=$(mktemp -d tmp.XXXXX)
cd ${tmp_dir}
wget -q ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.bz2
tar xf pcre-8.38.tar.bz2
cd pcre-8.38
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr --mandir=${OPENSHIFT_TMP_DIR}/gomi/man --docdir=${OPENSHIFT_TMP_DIR}/gomi/doc
time make -j4
make install

# apache

cd /tmp
rm -rf ${tmp_dir}
tmp_dir=$(mktemp -d tmp.XXXXX)
cd ${tmp_dir}
wget -q http://ftp.yz.yamagata-u.ac.jp/pub/network/apache//httpd/httpd-2.4.20.tar.bz2
tar xf httpd-2.4.20.tar.bz2
wget -q http://ftp.tsukuba.wide.ad.jp/software/apache//apr/apr-1.5.2.tar.bz2
tar xf apr-1.5.2.tar.bz2
mv -f ./apr-1.5.2 ./httpd-2.4.20/srclib/apr
wget -q http://ftp.tsukuba.wide.ad.jp/software/apache//apr/apr-util-1.5.4.tar.bz2
tar xf apr-util-1.5.4.tar.bz2
mv -f ./apr-util-1.5.4 ./httpd-2.4.20/srclib/apr-util
rm -f *.bz2

cd httpd-2.4.20
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr --mandir=${OPENSHIFT_TMP_DIR}/gomi/man --docdir=${OPENSHIFT_TMP_DIR}/gomi/doc \
 -enable-mods-shared='all proxy' --with-mpm=event --with-pcre=${OPENSHIFT_DATA_DIR}/usr
time make -j4
make install

cat << '__HEREDOC__' > /dev/null
Optional Features:
  --disable-option-checking  ignore unrecognized --enable/--with options
  --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
  --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
  --enable-layout=LAYOUT
  --enable-dtrace         Enable DTrace probes
  --enable-hook-probes    Enable APR hook probes
  --enable-exception-hook Enable fatal exception hook
  --enable-load-all-modules
                          Load all modules
  --enable-maintainer-mode
                          Turn on debugging and compile time warnings and load
                          all compiled modules
  --enable-debugger-mode  Turn on debugging and compile time warnings and turn
                          off optimization
  --enable-pie            Build httpd as a Position Independent Executable
  --enable-modules=MODULE-LIST
                          Space-separated list of modules to enable | "all" |
                          "most" | "few" | "none" | "reallyall"
  --enable-mods-shared=MODULE-LIST
                          Space-separated list of shared modules to enable |
                          "all" | "most" | "few" | "reallyall"
  --enable-mods-static=MODULE-LIST
                          Space-separated list of static modules to enable |
                          "all" | "most" | "few" | "reallyall"
  --disable-authn-file    file-based authentication control
  --enable-authn-dbm      DBM-based authentication control
  --enable-authn-anon     anonymous user authentication control
  --enable-authn-dbd      SQL-based authentication control
  --enable-authn-socache  Cached authentication control
  --disable-authn-core    core authentication module
  --disable-authz-host    host-based authorization control
  --disable-authz-groupfile
                          'require group' authorization control
  --disable-authz-user    'require user' authorization control
  --enable-authz-dbm      DBM-based authorization control
  --enable-authz-owner    'require file-owner' authorization control
  --enable-authz-dbd      SQL based authorization and Login/Session support
  --disable-authz-core    core authorization provider vector module
  --enable-authnz-ldap    LDAP based authentication
  --enable-authnz-fcgi    FastCGI authorizer-based authentication and
                          authorization
  --disable-access-compat mod_access compatibility
  --disable-auth-basic    basic authentication
  --enable-auth-form      form authentication
  --enable-auth-digest    RFC2617 Digest authentication
  --enable-allowmethods   restrict allowed HTTP methods
  --enable-isapi          isapi extension support
  --enable-file-cache     File cache
  --enable-cache          dynamic file caching. At least one storage
                          management module (e.g. mod_cache_disk) is also
                          necessary.
  --enable-cache-disk     disk caching module
  --enable-cache-socache  shared object caching module
  --enable-socache-shmcb  shmcb small object cache provider
  --enable-socache-dbm    dbm small object cache provider
  --enable-socache-memcache
                          memcache small object cache provider
  --enable-socache-dc     distcache small object cache provider
  --enable-so             DSO capability. This module will be automatically
                          enabled unless you build all modules statically.
  --enable-watchdog       Watchdog module
  --enable-macro          Define and use macros in configuration files
  --enable-dbd            Apache DBD Framework
  --enable-bucketeer      buckets manipulation filter. Useful only for
                          developers and testing purposes.
  --enable-dumpio         I/O dump filter
  --enable-echo           ECHO server
  --enable-example-hooks  Example hook callback handler module
  --enable-case-filter    Example uppercase conversion filter
  --enable-case-filter-in Example uppercase conversion input filter
  --enable-example-ipc    Example of shared memory and mutex usage
  --enable-buffer         Filter Buffering
  --enable-data           RFC2397 data encoder
  --enable-ratelimit      Output Bandwidth Limiting
  --disable-reqtimeout    Limit time waiting for request from client
  --enable-ext-filter     external filter module
  --enable-request        Request Body Filtering
  --enable-include        Server Side Includes
  --disable-filter        Smart Filtering
  --enable-reflector      Reflect request through the output filter stack
  --enable-substitute     response content rewrite-like filtering
  --enable-sed            filter request and/or response bodies through sed
  --disable-charset-lite  character set translation. Enabled by default only
                          on EBCDIC systems.
  --enable-charset-lite   character set translation. Enabled by default only
                          on EBCDIC systems.
  --enable-deflate        Deflate transfer encoding support
  --enable-xml2enc        i18n support for markup filters
  --enable-proxy-html     Fix HTML Links in a Reverse Proxy
  --enable-http           HTTP protocol handling. The http module is a basic
                          one that enables the server to function as an HTTP
                          server. It is only useful to disable it if you want
                          to use another protocol module instead. Don't
                          disable this module unless you are really sure what
                          you are doing. Note: This module will always be
                          linked statically.
  --disable-mime          mapping of file-extension to MIME. Disabling this
                          module is normally not recommended.
  --enable-ldap           LDAP caching and connection pooling services
  --disable-log-config    logging configuration. You won't be able to log
                          requests to the server without this module.
  --enable-log-debug      configurable debug logging
  --enable-log-forensic   forensic logging
  --enable-logio          input and output logging
  --enable-lua            Apache Lua Framework
  --enable-luajit         Enable LuaJit Support
  --disable-env           clearing/setting of ENV vars
  --enable-mime-magic     automagically determining MIME type
  --enable-cern-meta      CERN-type meta files
  --enable-expires        Expires header control
  --disable-headers       HTTP header control
  --enable-ident          RFC 1413 identity check
  --enable-usertrack      user-session tracking
  --enable-unique-id      per-request unique ids
  --disable-setenvif      basing ENV vars on headers
  --disable-version       determining httpd version in config files
  --enable-remoteip       translate header contents to an apparent client
                          remote_ip
  --enable-proxy          Apache proxy module
  --enable-proxy-connect  Apache proxy CONNECT module. Requires and is enabled
                          by --enable-proxy.
  --enable-proxy-ftp      Apache proxy FTP module. Requires and is enabled by
                          --enable-proxy.
  --enable-proxy-http     Apache proxy HTTP module. Requires and is enabled by
                          --enable-proxy.
  --enable-proxy-fcgi     Apache proxy FastCGI module. Requires and is enabled
                          by --enable-proxy.
  --enable-proxy-scgi     Apache proxy SCGI module. Requires and is enabled by
                          --enable-proxy.
  --enable-proxy-fdpass   Apache proxy to Unix Daemon Socket module. Requires
                          --enable-proxy.
  --enable-proxy-wstunnel Apache proxy Websocket Tunnel module. Requires and
                          is enabled by --enable-proxy.
  --enable-proxy-ajp      Apache proxy AJP module. Requires and is enabled by
                          --enable-proxy.
  --enable-proxy-balancer Apache proxy BALANCER module. Requires and is
                          enabled by --enable-proxy.
  --enable-proxy-express  mass reverse-proxy module. Requires --enable-proxy.
  --enable-session        session module
  --enable-session-cookie session cookie module
  --enable-session-crypto session crypto module
  --enable-session-dbd    session dbd module
  --enable-slotmem-shm    slotmem provider that uses shared memory
  --enable-slotmem-plain  slotmem provider that uses plain memory
  --enable-ssl            SSL/TLS support (mod_ssl)
  --enable-ssl-staticlib-deps
                          link mod_ssl with dependencies of OpenSSL's static
                          libraries (as indicated by "pkg-config --static").
                          Must be specified in addition to --enable-ssl.
  --enable-optional-hook-export
                          example optional hook exporter
  --enable-optional-hook-import
                          example optional hook importer
  --enable-optional-fn-import
                          example optional function importer
  --enable-optional-fn-export
                          example optional function exporter
  --enable-dialup         rate limits static files to dialup modem speeds
  --enable-static-support Build a statically linked version of the support
                          binaries
  --enable-static-htpasswd
                          Build a statically linked version of htpasswd
  --enable-static-htdigest
                          Build a statically linked version of htdigest
  --enable-static-rotatelogs
                          Build a statically linked version of rotatelogs
  --enable-static-logresolve
                          Build a statically linked version of logresolve
  --enable-static-htdbm   Build a statically linked version of htdbm
  --enable-static-ab      Build a statically linked version of ab
  --enable-static-checkgid
                          Build a statically linked version of checkgid
  --enable-static-htcacheclean
                          Build a statically linked version of htcacheclean
  --enable-static-httxt2dbm
                          Build a statically linked version of httxt2dbm
  --enable-static-fcgistarter
                          Build a statically linked version of fcgistarter
  --enable-http2          HTTP/2 protocol handling in addition to HTTP
                          protocol handling. Implemented by mod_http2. This
                          module requires a libnghttp2 installation. See
                          --with-nghttp2 on how to manage non-standard
                          locations. This module is usually linked shared and
                          requires loading.
  --enable-nghttp2-staticlib-deps
                          link mod_http2 with dependencies of libnghttp2's
                          static libraries (as indicated by "pkg-config
                          --static"). Must be specified in addition to
                          --enable-http2.
  --enable-lbmethod-byrequests
                          Apache proxy Load balancing by request counting
  --enable-lbmethod-bytraffic
                          Apache proxy Load balancing by traffic counting
  --enable-lbmethod-bybusyness
                          Apache proxy Load balancing by busyness
  --enable-lbmethod-heartbeat
                          Apache proxy Load balancing from Heartbeats
  --enable-mpms-shared=MPM-LIST
                          Space-separated list of MPM modules to enable for
                          dynamic loading. MPM-LIST=list | "all"
  --enable-unixd          unix specific support
  --enable-privileges     Per-virtualhost Unix UserIDs and enhanced security
                          for Solaris
  --enable-heartbeat      Generates Heartbeats
  --enable-heartmonitor   Collects Heartbeats
  --enable-dav            WebDAV protocol handling. --enable-dav also enables
                          mod_dav_fs
  --disable-status        process/thread monitoring
  --disable-autoindex     directory listing
  --enable-asis           as-is filetypes
  --enable-info           server information
  --enable-suexec         set uid and gid for spawned processes
  --enable-cgid           CGI scripts. Enabled by default with threaded MPMs
  --enable-cgi            CGI scripts. Enabled by default with non-threaded
                          MPMs
  --enable-dav-fs         DAV provider for the filesystem. --enable-dav also
                          enables mod_dav_fs.
  --enable-dav-lock       DAV provider for generic locking
  --enable-vhost-alias    mass virtual hosting module
  --enable-negotiation    content negotiation
  --disable-dir           directory request handling
  --enable-imagemap       server-side imagemaps
  --enable-actions        Action triggering on requests
  --enable-speling        correct common URL misspellings
  --enable-userdir        mapping of requests to user-specific directories
  --disable-alias         mapping of requests to different filesystem parts
  --enable-rewrite        rule based URL manipulation
  --enable-v4-mapped      Allow IPv6 sockets to handle IPv4 connections

Optional Packages:
  --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
  --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
  --with-included-apr     Use bundled copies of APR/APR-Util
  --with-apr=PATH         prefix for installed APR or the full path to
                             apr-config
  --with-apr-util=PATH    prefix for installed APU or the full path to
                             apu-config
  --with-pcre=PATH        Use external PCRE library
  --with-port=PORT        Port on which to listen (default is 80)
  --with-sslport=SSLPORT  Port on which to securelisten (default is 443)
  --with-distcache=PATH   Distcache installation directory
  --with-z=PATH           use a specific zlib library
  --with-libxml2=PATH     location for libxml2
  --with-lua=PATH         Path to the Lua 5.2/5.1 prefix
  --with-ssl=PATH         OpenSSL installation directory
  --with-nghttp2=PATH     nghttp2 installation directory
  --with-mpm=MPM          Choose the process model for Apache to use by
                          default. MPM={event|worker|prefork|winnt} This will
                          be statically linked as the only available MPM
                          unless --enable-mpms-shared is also specified.
  --with-module=module-type:module-file
                          Enable module-file in the modules/<module-type>
                          directory.
  --with-program-name     alternate executable name
  --with-suexec-bin       Path to suexec binary
  --with-suexec-caller    User allowed to call SuExec
  --with-suexec-userdir   User subdirectory
  --with-suexec-docroot   SuExec root directory
  --with-suexec-uidmin    Minimal allowed UID
  --with-suexec-gidmin    Minimal allowed GID
  --with-suexec-logfile   Set the logfile
  --with-suexec-safepath  Set the safepath
  --with-suexec-umask     umask for suexec'd process

mod_access_compat.so
mod_actions.so
mod_alias.so
mod_allowmethods.so
mod_asis.so
mod_auth_basic.so
mod_auth_digest.so
mod_auth_form.so
mod_authn_anon.so
mod_authn_core.so
mod_authn_dbd.so
mod_authn_dbm.so
mod_authn_file.so
mod_authn_socache.so
mod_authz_core.so
mod_authz_dbd.so
mod_authz_dbm.so
mod_authz_groupfile.so
mod_authz_host.so
mod_authz_owner.so
mod_authz_user.so
mod_autoindex.so
mod_buffer.so
mod_cache_disk.so
mod_cache.so
mod_cache_socache.so
mod_cgid.so
mod_charset_lite.so
mod_data.so
mod_dav_fs.so
mod_dav_lock.so
mod_dav.so
mod_dbd.so
mod_deflate.so
mod_dialup.so
mod_dir.so
mod_dumpio.so
mod_echo.so
mod_env.so
mod_expires.so
mod_ext_filter.so
mod_file_cache.so
mod_filter.so
mod_headers.so
mod_heartbeat.so
mod_heartmonitor.so
mod_include.so
mod_info.so
mod_lbmethod_bybusyness.so
mod_lbmethod_byrequests.so
mod_lbmethod_bytraffic.so
mod_lbmethod_heartbeat.so
mod_log_config.so
mod_log_debug.so
mod_log_forensic.so
mod_logio.so
mod_lua.so
mod_macro.so
mod_mime_magic.so
mod_mime.so
mod_negotiation.so
mod_proxy_ajp.so
mod_proxy_balancer.so
mod_proxy_connect.so
mod_proxy_express.so
mod_proxy_fcgi.so
mod_proxy_fdpass.so
mod_proxy_ftp.so
mod_proxy_html.so
mod_proxy_http.so
mod_proxy_scgi.so
mod_proxy.so
mod_proxy_wstunnel.so
mod_ratelimit.so
mod_reflector.so
mod_remoteip.so
mod_reqtimeout.so
mod_request.so
mod_rewrite.so
mod_sed.so
mod_session_cookie.so
mod_session_dbd.so
mod_session.so
mod_setenvif.so
mod_slotmem_plain.so
mod_slotmem_shm.so
mod_socache_dbm.so
mod_socache_memcache.so
mod_socache_shmcb.so
mod_speling.so
mod_ssl.so
mod_status.so
mod_substitute.so
mod_unique_id.so
mod_unixd.so
mod_userdir.so
mod_usertrack.so
mod_version.so
mod_vhost_alias.so
mod_watchdog.so
mod_xml2enc.so

__HEREDOC__

# php

cd /tmp
rm -rf ${tmp_dir}
tmp_dir=$(mktemp -d tmp.XXXXX)
cd ${tmp_dir}

wget -q http://us1.php.net/get/php-7.0.5.tar.xz/from/this/mirror -O php-7.0.5.tar.xz
tar xf php-7.0.5.tar.xz
cd php-7.0.5
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr --mandir=${OPENSHIFT_TMP_DIR}/gomi/man --docdir=${OPENSHIFT_TMP_DIR}/gomi/doc \
 --enable-fpm --with-apxs2=${OPENSHIFT_DATA_DIR}/usr/bin/apxs \
 --disable-ipv6 --without-sqlite3 --enable-mbstring --with-pcre=${OPENSHIFT_DATA_DIR}/usr
time make -j1
make install

cat << '__HEREDOC__' > /dev/null
Optional Features and Packages:
  --disable-option-checking  ignore unrecognized --enable/--with options
  --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
  --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
  --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
  --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
  --with-libdir=NAME      Look for libraries in .../NAME rather than .../lib
  --disable-rpath         Disable passing additional runtime library
                          search paths
  --enable-re2c-cgoto     Enable -g flag to re2c to use computed goto gcc extension
  --disable-gcc-global-regs
                          whether to enable GCC global register variables

SAPI modules:

  --with-apxs2=FILE       Build shared Apache 2.0 Handler module. FILE is the optional
                          pathname to the Apache apxs tool apxs
  --disable-cli           Disable building CLI version of PHP
                          (this forces --without-pear)
  --enable-embed=TYPE     EXPERIMENTAL: Enable building of embedded SAPI library
                          TYPE is either 'shared' or 'static'. TYPE=shared
  --enable-fpm            Enable building of the fpm SAPI executable
  --with-fpm-user=USER    Set the user for php-fpm to run as. (default: nobody)
  --with-fpm-group=GRP    Set the group for php-fpm to run as. For a system user, this
                          should usually be set to match the fpm username (default: nobody)
  --with-fpm-systemd      Activate systemd integration
  --with-fpm-acl          Use POSIX Access Control Lists
  --with-litespeed        Build PHP as litespeed module
  --enable-phpdbg            Build phpdbg
  --enable-phpdbg-webhelper  Build phpdbg web SAPI support
  --enable-phpdbg-debug      Build phpdbg in debug mode
  --disable-cgi           Disable building CGI version of PHP

General settings:

  --enable-gcov           Enable GCOV code coverage (requires LTP) - FOR DEVELOPERS ONLY!!
  --enable-debug          Compile with debugging symbols
  --with-layout=TYPE      Set how installed files will be laid out.  Type can
                          be either PHP or GNU [PHP]
  --with-config-file-path=PATH
                          Set the path in which to look for php.ini [PREFIX/lib]
  --with-config-file-scan-dir=PATH
                          Set the path where to scan for configuration files
  --enable-sigchild       Enable PHP's own SIGCHLD handler
  --enable-libgcc         Enable explicitly linking against libgcc
  --disable-short-tags    Disable the short-form <? start tag by default
  --enable-dmalloc        Enable dmalloc
  --disable-ipv6          Disable IPv6 support
  --enable-dtrace         Enable DTrace support
  --enable-fd-setsize     Set size of descriptor sets

Extensions:

  --with-EXTENSION=shared[,PATH]

    NOTE: Not all extensions can be build as 'shared'.

    Example: --with-foobar=shared,/usr/local/foobar/

      o Builds the foobar extension as shared extension.
      o foobar package install prefix is /usr/local/foobar/


  --disable-all           Disable all extensions which are enabled by default

  --disable-libxml        Disable LIBXML support
  --with-libxml-dir=DIR   LIBXML: libxml2 install prefix
  --with-openssl=DIR      Include OpenSSL support (requires OpenSSL >= 0.9.8)
  --with-kerberos=DIR     OPENSSL: Include Kerberos support
  --with-system-ciphers   OPENSSL: Use system default cipher list instead of hardcoded value
  --with-pcre-regex=DIR   Include Perl Compatible Regular Expressions support.
                          DIR is the PCRE install prefix BUNDLED
  --without-sqlite3=DIR   Do not include SQLite3 support. DIR is the prefix to
                          SQLite3 installation directory.
  --with-zlib=DIR         Include ZLIB support (requires zlib >= 1.0.9)
  --with-zlib-dir=<DIR>   Define the location of zlib install directory
  --enable-bcmath         Enable bc style precision math functions
  --with-bz2=DIR          Include BZip2 support
  --enable-calendar       Enable support for calendar conversion
  --disable-ctype         Disable ctype functions
  --with-curl=DIR         Include cURL support
  --enable-dba            Build DBA with bundled modules. To build shared DBA
                          extension use --enable-dba=shared
  --with-qdbm=DIR         DBA: QDBM support
  --with-gdbm=DIR         DBA: GDBM support
  --with-ndbm=DIR         DBA: NDBM support
  --with-db4=DIR          DBA: Oracle Berkeley DB 4.x or 5.x support
  --with-db3=DIR          DBA: Oracle Berkeley DB 3.x support
  --with-db2=DIR          DBA: Oracle Berkeley DB 2.x support
  --with-db1=DIR          DBA: Oracle Berkeley DB 1.x support/emulation
  --with-dbm=DIR          DBA: DBM support
  --with-tcadb=DIR        DBA: Tokyo Cabinet abstract DB support
  --without-cdb=DIR       DBA: CDB support (bundled)
  --disable-inifile       DBA: INI support (bundled)
  --disable-flatfile      DBA: FlatFile support (bundled)
  --disable-dom           Disable DOM support
  --with-libxml-dir=DIR   DOM: libxml2 install prefix
  --with-enchant=DIR      Include enchant support.
                          GNU Aspell version 1.1.3 or higher required.
  --enable-exif           Enable EXIF (metadata from images) support
  --disable-fileinfo      Disable fileinfo support
  --disable-filter        Disable input filter support
  --with-pcre-dir         FILTER: pcre install prefix
  --enable-ftp            Enable FTP support
  --with-openssl-dir=DIR  FTP: openssl install prefix
  --with-gd=DIR           Include GD support.  DIR is the GD library base
                          install directory BUNDLED
  --with-webp-dir=DIR      GD: Set the path to libwebp install prefix
  --with-jpeg-dir=DIR     GD: Set the path to libjpeg install prefix
  --with-png-dir=DIR      GD: Set the path to libpng install prefix
  --with-zlib-dir=DIR     GD: Set the path to libz install prefix
  --with-xpm-dir=DIR      GD: Set the path to libXpm install prefix
  --with-freetype-dir=DIR GD: Set the path to FreeType 2 install prefix
  --enable-gd-native-ttf  GD: Enable TrueType string function
  --enable-gd-jis-conv    GD: Enable JIS-mapped Japanese font support
  --with-gettext=DIR      Include GNU gettext support
  --with-gmp=DIR          Include GNU MP support
  --with-mhash=DIR        Include mhash support
  --disable-hash          Disable hash support
  --without-iconv=DIR     Exclude iconv support
  --with-imap=DIR         Include IMAP support. DIR is the c-client install prefix
  --with-kerberos=DIR     IMAP: Include Kerberos support. DIR is the Kerberos install prefix
  --with-imap-ssl=DIR     IMAP: Include SSL support. DIR is the OpenSSL install prefix
  --with-interbase=DIR    Include Firebird support.  DIR is the Firebird base
                          install directory /opt/firebird
  --enable-intl           Enable internationalization support
  --with-icu-dir=DIR      Specify where ICU libraries and headers can be found
  --disable-json          Disable JavaScript Object Serialization support
  --with-ldap=DIR         Include LDAP support
  --with-ldap-sasl=DIR    LDAP: Include Cyrus SASL support
  --enable-mbstring       Enable multibyte string support
  --disable-mbregex       MBSTRING: Disable multibyte regex support
  --disable-mbregex-backtrack
                          MBSTRING: Disable multibyte regex backtrack check
  --with-libmbfl=DIR      MBSTRING: Use external libmbfl.  DIR is the libmbfl base
                          install directory BUNDLED
  --with-onig=DIR         MBSTRING: Use external oniguruma. DIR is the oniguruma install prefix.
                          If DIR is not set, the bundled oniguruma will be used
  --with-mcrypt=DIR       Include mcrypt support
  --with-mysqli=FILE      Include MySQLi support.  FILE is the path
                          to mysql_config.  If no value or mysqlnd is passed
                          as FILE, the MySQL native driver will be used
  --enable-embedded-mysqli
                          MYSQLi: Enable embedded support
                          Note: Does not work with MySQL native driver!
  --with-mysql-sock=SOCKPATH
                          MySQLi/PDO_MYSQL: Location of the MySQL unix socket pointer.
                          If unspecified, the default locations are searched
  --with-oci8=DIR         Include Oracle Database OCI8 support. DIR defaults to $ORACLE_HOME.
                          Use --with-oci8=instantclient,/path/to/instant/client/lib
                          to use an Oracle Instant Client installation
  --with-odbcver=HEX      Force support for the passed ODBC version. A hex number is expected, default 0x0300.
                             Use the special value of 0 to prevent an explicit ODBCVER to be defined.
  --with-adabas=DIR       Include Adabas D support /usr/local
  --with-sapdb=DIR        Include SAP DB support /usr/local
  --with-solid=DIR        Include Solid support /usr/local/solid
  --with-ibm-db2=DIR      Include IBM DB2 support /home/db2inst1/sqllib
  --with-ODBCRouter=DIR   Include ODBCRouter.com support /usr
  --with-empress=DIR      Include Empress support \$EMPRESSPATH
                          (Empress Version >= 8.60 required)
  --with-empress-bcs=DIR
                          Include Empress Local Access support \$EMPRESSPATH
                          (Empress Version >= 8.60 required)
  --with-birdstep=DIR     Include Birdstep support /usr/local/birdstep
  --with-custom-odbc=DIR  Include user defined ODBC support. DIR is ODBC install base
                          directory /usr/local. Make sure to define CUSTOM_ODBC_LIBS and
                          have some odbc.h in your include dirs. f.e. you should define
                          following for Sybase SQL Anywhere 5.5.00 on QNX, prior to
                          running this configure script:
                            CPPFLAGS=\"-DODBC_QNX -DSQLANY_BUG\"
                            LDFLAGS=-lunix
                            CUSTOM_ODBC_LIBS=\"-ldblib -lodbc\"
  --with-iodbc=DIR        Include iODBC support /usr/local
  --with-esoob=DIR        Include Easysoft OOB support /usr/local/easysoft/oob/client
  --with-unixODBC=DIR     Include unixODBC support /usr/local
  --with-dbmaker=DIR      Include DBMaker support
  --disable-opcache       Disable Zend OPcache support
  --disable-opcache-file  Disable file based caching
  --disable-huge-code-pages
                          Disable copying PHP CODE pages into HUGE PAGES
  --enable-pcntl          Enable pcntl support (CLI/CGI only)
  --disable-pdo           Disable PHP Data Objects support
  --with-pdo-dblib=DIR    PDO: DBLIB-DB support.  DIR is the FreeTDS home directory
  --with-pdo-firebird=DIR PDO: Firebird support.  DIR is the Firebird base
                          install directory /opt/firebird
  --with-pdo-mysql=DIR    PDO: MySQL support. DIR is the MySQL base directory
                          If no value or mysqlnd is passed as DIR, the
                          MySQL native driver will be used
  --with-zlib-dir=DIR     PDO_MySQL: Set the path to libz install prefix
  --with-pdo-oci=DIR      PDO: Oracle OCI support. DIR defaults to \$ORACLE_HOME.
                          Use --with-pdo-oci=instantclient,prefix,version
                          for an Oracle Instant Client SDK.
                          For example on Linux with 11.2 RPMs use:
                            --with-pdo-oci=instantclient,/usr,11.2
                          With 10.2 RPMs use:
                            --with-pdo-oci=instantclient,/usr,10.2.0.4
  --with-pdo-odbc=flavour,dir
                          PDO: Support for 'flavour' ODBC driver.
                          include and lib dirs are looked for under 'dir'.

                          'flavour' can be one of:  ibm-db2, iODBC, unixODBC, generic
                          If ',dir' part is omitted, default for the flavour
                          you have selected will be used. e.g.:

                            --with-pdo-odbc=unixODBC

                          will check for unixODBC under /usr/local. You may attempt
                          to use an otherwise unsupported driver using the \"generic\"
                          flavour.  The syntax for generic ODBC support is:

                            --with-pdo-odbc=generic,dir,libname,ldflags,cflags

                          When built as 'shared' the extension filename is always pdo_odbc.so
  --with-pdo-pgsql=DIR    PDO: PostgreSQL support.  DIR is the PostgreSQL base
                          install directory or the path to pg_config
  --without-pdo-sqlite=DIR
                          PDO: sqlite 3 support.  DIR is the sqlite base
                          install directory BUNDLED
  --with-pgsql=DIR        Include PostgreSQL support.  DIR is the PostgreSQL
                          base install directory or the path to pg_config
  --disable-phar          Disable phar support
  --disable-posix         Disable POSIX-like functions
  --with-pspell=DIR       Include PSPELL support.
                          GNU Aspell version 0.50.0 or higher required
  --with-libedit=DIR      Include libedit readline replacement (CLI/CGI only)
  --with-readline=DIR     Include readline support (CLI/CGI only)
  --with-recode=DIR       Include recode support
  --disable-session       Disable session support
  --with-mm=DIR           SESSION: Include mm support for session storage
  --enable-shmop          Enable shmop support
  --disable-simplexml     Disable SimpleXML support
  --with-libxml-dir=DIR   SimpleXML: libxml2 install prefix
  --with-snmp=DIR         Include SNMP support
  --with-openssl-dir=DIR  SNMP: openssl install prefix
  --enable-soap           Enable SOAP support
  --with-libxml-dir=DIR   SOAP: libxml2 install prefix
  --enable-sockets        Enable sockets support
  --enable-sysvmsg        Enable sysvmsg support
  --enable-sysvsem        Enable System V semaphore support
  --enable-sysvshm        Enable the System V shared memory support
  --with-tidy=DIR         Include TIDY support
  --disable-tokenizer     Disable tokenizer support
  --enable-wddx           Enable WDDX support
  --with-libxml-dir=DIR   WDDX: libxml2 install prefix
  --with-libexpat-dir=DIR WDDX: libexpat dir for XMLRPC-EPI (deprecated)
  --disable-xml           Disable XML support
  --with-libxml-dir=DIR   XML: libxml2 install prefix
  --with-libexpat-dir=DIR XML: libexpat install prefix (deprecated)
  --disable-xmlreader     Disable XMLReader support
  --with-libxml-dir=DIR   XMLReader: libxml2 install prefix
  --with-xmlrpc=DIR       Include XMLRPC-EPI support
  --with-libxml-dir=DIR   XMLRPC-EPI: libxml2 install prefix
  --with-libexpat-dir=DIR XMLRPC-EPI: libexpat dir for XMLRPC-EPI (deprecated)
  --with-iconv-dir=DIR    XMLRPC-EPI: iconv dir for XMLRPC-EPI
  --disable-xmlwriter     Disable XMLWriter support
  --with-libxml-dir=DIR   XMLWriter: libxml2 install prefix
  --with-xsl=DIR          Include XSL support.  DIR is the libxslt base
                          install directory (libxslt >= 1.1.0 required)
  --enable-zip            Include Zip read/write support
  --with-zlib-dir=DIR     ZIP: Set the path to libz install prefix
  --with-pcre-dir         ZIP: pcre install prefix
  --with-libzip=DIR       ZIP: use libzip
  --enable-mysqlnd        Enable mysqlnd explicitly, will be done implicitly
                          when required by other extensions
  --disable-mysqlnd-compression-support
                          Disable support for the MySQL compressed protocol in mysqlnd
  --with-zlib-dir=DIR     mysqlnd: Set the path to libz install prefix

PEAR:

  --with-pear=DIR         Install PEAR in DIR [PREFIX/lib/php]
  --without-pear          Do not install PEAR

Zend:

  --enable-maintainer-zts Enable thread safety - for code maintainers only!!
  --disable-inline-optimization
                          If building zend_execute.lo fails, try this switch
  --enable-zend-signals   Use zend signal handling

TSRM:

  --with-tsrm-pth=pth-config
                          Use GNU Pth
  --with-tsrm-st          Use SGI's State Threads
  --with-tsrm-pthreads    Use POSIX threads (default)

Libtool:

  --enable-shared=PKGS    Build shared libraries default=yes
  --enable-static=PKGS    Build static libraries default=yes
  --enable-fast-install=PKGS
                          Optimize for fast installation default=yes
  --with-gnu-ld           Assume the C compiler uses GNU ld default=no
  --disable-libtool-lock  Avoid locking (might break parallel builds)
  --with-pic              Try to use only PIC/non-PIC objects default=use both
  --with-tags=TAGS        Include additional configurations automatic
__HEREDOC__

cd /tmp
rm -rf ${tmp_dir}
