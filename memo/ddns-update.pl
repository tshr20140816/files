#!/usr/bin/perl

# ieServer.Net 専用 DDNS IP アドレス更新スクリプト - ddns-update.pl
# 作成者：山本恭弘@Agora Inc.　作成日:2004/03/24
#
# 回線割り当てグローバルIPアドレスを確認し、変化があれば新IPアドレスを
# DDNSに登録。当コマンドを一定の間隔で実行し、IPアドレスの変化を監視＆
# 更新処理する。利用には perl wget cron が利用可能である必要あり。
#
# 回線に割り当てられた IPアドレス は http://ieserver.net/ipcheck.shtml
# へのアクセスによって確認。
#
# cron にて当コマンドを等間隔で実行し、回線IPを確認。変化があればDDNSに
# IPアドレスを登録。DDNSサーバーへの負荷軽減の点から実行間隔は10分以上と
# すること。
# crontab設定例(/usr/local/ddns/ddns.plにスクリプトを置き10分間隔で実行)
# 5,15,25,35,45,55 * * * * /usr/local/ddns/ddns-update.pl

# 以下２ファイルの配置ディレクトリは好みに応じ設定
# 1. 設定IPアドレスワークファイル
$CURRENT_IP_FILE = "ddns-update_current_ip";

#  2. 設定状況ログファイル
$LOG_FILE        = "ddns-update.log";

# 回線IP確認ページURL
$REMOTE_ADDR_CHK = "https://ieserver.net/ipcheck.shtml";
# DDNS更新ページURL
# wgetをSSL接続可能でビルドしているなら、https:// での接続を推奨
$DDNS_UPDATE     = "https://ieserver.net/cgi-bin/dip.cgi";

# ieServer.Netにて取得したアカウント（サブドメイン）情報を記入
$ACCOUNT         = "     ";     # アカウント(サブドメイン)名設定
$DOMAIN          = "dip.jp";     # ドメイン名設定
$PASSWORD        = "     ";     # パスワード設定

if(!open(FILE,"$CURRENT_IP_FILE")) {
    $CURRENT_IP = '0.0.0.0';
    } else {
    $CURRENT_IP = <FILE>;
    close FILE;
}

$NEW_IP = '0.0.0.0';
$NEW_IP = `wget -q -O - $REMOTE_ADDR_CHK`;

if ($NEW_IP ne "0.0.0.0" and $CURRENT_IP ne $NEW_IP) {

    $STATUS = `wget -q --post-data='updatehost=1&password=$PASSWORD&domain=$DOMAIN&username=$ACCOUNT' -O - '$DDNS_UPDATE'`;
    
    if ($STATUS =~ m/$NEW_IP/) {    
        open (FILE ,">$CURRENT_IP_FILE");
        print FILE $NEW_IP;
        close FILE;
        $TIME = localtime;
        open (FILE ,">>$LOG_FILE");
        print FILE "$TIME $ACCOUNT.$DOMAIN Updated $CURRENT_IP to $NEW_IP\n";
        close FILE;
    } else {
        $TIME = localtime;
        open (FILE ,">>$LOG_FILE");
        print FILE "$TIME $ACCOUNT.$DOMAIN Update aborted $CURRENT_IP to $NEW_IP\n";
        close FILE;
    }
}
exit;
