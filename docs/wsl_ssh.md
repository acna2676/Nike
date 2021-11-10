# wslでWindowsのsshキーを使用してgithubに接続する方法

1.  wsl上のOSにて /etc/wsl.conf を下記の内容で作成する。
これによりWindows上のファイルのパーミッションを変更できるようになる。

```text
[automount]
options = "metadata"
```

2. 以下でパーミッション変更

```bash
chmod 600 ~/.ssh/id_rsa_win_github
chmod 600 ~/.ssh/config 
```
