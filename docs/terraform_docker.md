# Terraform 仕様手引き書

1. Docker for Windows を起動
2. Terraform ディレクトリへ移動

```bash
$ cd |~/Nike/Terraform
```

3. Terraform 用 Docker の起動

```bash
$ docker-compose up -d
$ docker-compose exec terraform /bin/ash
```

4. Terraform コマンドでリソースの作成
   3 までの手順で Dcoker への接続が完了して「/terraform #」と表示されるので以下のコマンドを実行

```bash
$ terraform init ← 初回のみ
$ terraform plan
$ terraform apply
```
