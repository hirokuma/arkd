# 使い方

データディレクトリは`./data/`。

## NigiriとPostgreSQLの起動

```bash
./scripts/start.sh
```

## arkd-walletとarkdの起動

`arkd-wallet`はバックグラウンド起動して`arkd`が起動し続ける。  
ログが邪魔だと思うので起動したターミナルはそのまま専用にしたほうがよいだろう。

`arkd-wallet`の起動後にしばらく待たせているので「7070」のようなログが出るまで待つこと。

```bash
./scripts/arkd.sh start
```

* 使用する環境変数
  * `arkd-wallet` : [envs/arkd-wallet.regtest.env](envs/arkd-wallet.regtest.env)
  * `arkd` : [envs/arkd.light.env](envs/arkd.light.env)

`_DELAY`が512未満の場合はブロック単位、512以上の場合は秒が使われる(512秒は8分半くらい)。  
以前は`ARKD_SCHEDULER_TYPE`もあったが現在は使用されていない。

ブロック単位はRegtestでのみ有効とされている。
そのせいか、ツールで期限の判定がブロックでうまくいっていないように思われる。
ここでは`arkd.light.env`の値を変更して時間単位にしている。

## arkd.sh, cli.sh共通

### generate

ブロック生成。
値がなければ1ブロック、あればその分を生成。

```bash
./scripts/arkd.sh generate
./scripts/cli.sh generate
```

### faucet

Nigiriのfaucetコマンドを実行する。  
送金した後で1ブロック生成される。

```bash
./scripts/arkd.sh faucet <アドレス> <送金sats>
./scripts/cli.sh faucet <アドレス> <送金sats>
```

## arkd関連

`./build/arkd-linux-amd64`の操作。

### 初期化

ウォレット生成して 10 BTC をデポジットする。

```bash
./scripts/arkd.sh init
```

### unlock

`arkd`はウォレット作成後や起動直後はウォレットがlock状態になっている。  
"init"した場合はunlockしているが、`arkd`を再起動した後はlock状態なのでunlockする。

```bash
./scripts/arkd.sh unlock
```

### balance

`arkd wallet balance`コマンドと同じ。

```bash
./scripts/arkd.sh balance
```

### その他

上記に当てはまらないコマンドはそのまま`arkd`に渡される。

```bash
./scripts/arkd.sh CMD1 [CMD2...]
```

## cli関連

`pkg/ark-cli/build/ark-linux-amd64`コマンドの操作。

データディレクトリは`./data/cli/<TARGET>`。`<TARGET>`は第1引数。

### init

TARGETのウォレットを生成、0.01 BTC をデポジット、

```bash
./scripts/cli.sh <TARGET> init
```


### balance

`ark-cli`コマンド。  
残高出力。値がゼロの場合は出力されない項目もある。

```bash
./scripts/cli.sh <TARGET> balance
```

* `onchain_balance` : オンチェーンで利用可能
  * `spendable_amount` = onchainSpendable + boardingSpendable + redeemSpendable (即座に使用可能)
  * `locked amount` = lockedOnchainBalance (timelockなどでロックされている)
* `offchain_balance` : Ark内のVTXOとして利用可能

[DeepWiki](https://deepwiki.com/search/arkcli-onboarding-addressbtcvt_6a556fc7-24ad-4080-9d8f-b332ba757ebd?mode=fast)

```json
{
  "onchain_balance": {
    "spendable_amount": 0
  },
  "offchain_balance": {
    "total": 1000000,
    "next_expiration": "9 minutes",
    "details": [
      {
        "expiry_time": "2026-06-16T11:55:41+09:00",
        "amount": 1000000
      }
    ]
  }
}
```

* `expiry_time`が過ぎていた場合、そのVTXOは期限切れである。
  * それでも`offchain_balance`に残っているのは"recoverable"という扱いになっている。
  * `ark-cli settle`コマンドには"recoverable"を復帰させる能力はない。SDKにあるとのこと。
    * [DeepWiki](https://deepwiki.com/search/arkcli-onboarding-addressbtcvt_6a556fc7-24ad-4080-9d8f-b332ba757ebd?mode=fast)

### receive

`ark-cli`コマンド。  
アドレスの取得。

```bash
./scripts/cli.sh <TARGET> receive
```

```json
{
  "boarding_address": "bcrt1p5dwmphxhuguhjzyey0pulm5mw8sve762ffxgyascm9c6g80lllqsg6xcjs",
  "offchain_address": "tark1qpt0syx7j0jspe69kldtljet0x9jz6ns4xw70m0w0xl30yfhn0mzm9jccywgdrkwpsqvny3ragh9gmq92xtncymvff05x7at7rdmc72yejvcq3",
  "onchain_address": "bcrt1pr20tc3cwqagacpq8gg2mv0c4xjwmux3da6h3m454cxdytttsne0s7khscj"
}
```

### vtxos

`ark-cli`コマンド。  
VTXO一覧取得。

```json
[
  {
    "Txid": "2357d6b7552ca722bbad253d69cccd751e73a51e0a99512f50e6799ad11d8f59",
    "VOut": 0,
    "Script": "51209658c11c868ece0c00c99223ea2e546c0551973c136c4a5f437babf0dbbc7944",
    "Amount": 1000000,
    "CommitmentTxids": [
      "d9222b06d5ca662a40e9b29771891632cb89524f25d19fef774700518dbb1374"
    ],
    "ExpiresAt": "2026-06-16T11:55:41+09:00",
    "CreatedAt": "2026-06-16T11:38:37+09:00",
    "Preconfirmed": false,
    "Swept": false,
    "Unrolled": false,
    "Spent": false,
    "SpentBy": "",
    "SettledBy": "",
    "ArkTxid": "",
    "Assets": null
  }
]
```

### pay

`ark-cli send`コマンドを相手アドレスの取得を行ってから実行する。

```bash
./scripts/cli.sh <TARGET> pay <送金先TARGET> <送金sats>
```

## 停止および後始末

関連するDockerコンテナ、`arkd-wallet`、`arkd`を停止し、データディレクトリを削除する。

```bash
scripts/stop.sh
```

## 手順

### ターミナル1

```bash
./scripts/start.sh
./scripts/arkd.sh start
```

### ターミナル2

```bash
./scripts/arkd.sh init
```

### ターミナル3

cli1とcli2を作る(数字でなくても良い)。  
データディレクトリはそれぞれ`./data/cli/1`, `./data/cli/2`になる。

```bash
./scripts/cli.sh 1 init
./scripts/cli.sh 2 init
```

1番から2番へ 1,000 sats 送金

```shell
$ ./scripts/cli.sh 1 pay 2 1000
{
        "txid": "821ad25defe625207f44232724e81aa977e6d7647c0377fbe7af5a8e2e7927a6"
}
```

個別のコマンドで送金を行った場合

```shell
$ addr2=$(./scripts/cli.sh 2 receive | jq -r .offchain_address)
$ ./scripts/cli.sh 1 send $addr2 2000
{
        "txid": "2eb31b75797a20525113f4421be88185365fb8d3700978d27d3315abc32d13d6"
}
```

