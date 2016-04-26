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

cd /tmp
rm -rf ${tmp_dir}
