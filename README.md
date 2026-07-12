## Argosbx一键无交互小钢炮脚本💣：极简 + 轻量 + 快速

---------------------------------------

<img width="757" height="255" alt="d89e2542c513e705106371acc7fa1d33" src="https://github.com/user-attachments/assets/7d7a4678-4223-478c-afe2-d303ba0f85a4" />

---------------------------------------

#### 1、基于 Sing-box + Xray + Cloudflared-Argo + Mita 四内核按需分配；Mieru 可独立运行

#### 2、支持Linux类主流VPS系统（建议最新版系统），SSH脚本支持非root环境运行，无脑一次回车搞定

#### 3、支持普通 Docker 容器部署，公开镜像库：```ygkkk/argosbx```；fork 的 Actions 默认发布多架构镜像到 ```ghcr.io/<fork-owner>/argosbx```

#### 4、根据Sing-box与Xray不同内核，可选15种WARP出站组合，更换落地IP为WARP的IP，解锁流媒体

#### 5、客户端支持各类单协议分享及 Clash/Mihomo/Sing-box 聚合订阅；Mieru 额外输出官方 ```mieru://```、```mierus://``` 和 Mihomo ```type: mieru``` 配置

#### 6、所有代理协议都无需域名（除了argo固定隧道、IP端口CDN），支持单个或多个代理协议任意组合并快速重置更换
【 已支持：AnyTLS、Any-reality、Vless-xhttp-reality-vison-enc、Vless-tcp-reality-vision、Vless-xhttp-vison-enc、Vless-ws-vision-enc、Shadowsocks-2022、Vmess-ws、Socks5、Hysteria2、Tuic、Mieru TCP/UDP；Argo 临时/固定隧道仅支持 Vless-ws-vision-enc 或 Vmess-ws 】

#### 7、个人 SSH 一键脚本命令生成器：https://fool076.github.io/argosbx/（命令默认从本 fork 下载脚本与配套资产）

#### 8、如需要多样的功能，推荐使用VPS专用五合一脚本[Sing-box-yg](https://github.com/yonggekkk/sing-box-yg)

#### 9、Argosbx客户端推荐：

安卓手机客户端：[Nekobox-starifly版(全协议支持)](https://github.com/starifly/NekoBoxForAndroid/releases)、[V2rayNG官方版](https://github.com/2dust/v2rayNG/releases)

电脑win客户端：[V2rayN官方版(全协议支持)](https://github.com/2dust/v2rayN/releases)

苹果IOS客户端：Happ、OneXray、Streisand

----------------------------------------------------------

## 一、自定义变量参数说明：

| 变量意义 | 变量名称| 在变量值""之间填写| 删除变量 | 在变量值""之间留空 | 变量要求及说明 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1、启用vless-tcp-reality-v | vlpt | 端口指定 | 关闭vless-tcp-reality-v | 端口随机 | 必选之一 【xray内核：TCP】 |
| 2、启用vless-xhttp-reality-enc | xhpt | 端口指定 | 关闭vless-xhttp-reality-enc | 端口随机 | 必选之一 【xray内核：TCP】 |
| 3、启用vless-xhttp-enc | vxpt | 端口指定 | 关闭vless-xhttp-enc | 端口随机 | 必选之一 【xray内核：TCP】 |
| 4、启用vless-ws-enc | vwpt | 端口指定 | 关闭vless-ws-enc | 端口随机 | 必选之一 【xray内核：TCP】 |
| 5、启用shadowsocks-2022 | sspt | 端口指定 | 关闭shadowsocks-2022 | 端口随机 | 必选之一 【singbox内核：TCP】 |
| 6、启用anytls | anpt | 端口指定 | 关闭anytls | 端口随机 | 必选之一 【singbox内核：TCP】 |
| 7、启用any-reality | arpt | 端口指定 | 关闭any-reality | 端口随机 | 必选之一 【singbox内核：TCP】 |
| 8、启用vmess-ws | vmpt | 端口指定 | 关闭vmess-ws | 端口随机 | 必选之一 【xray/singbox内核：TCP】 |
| 9、启用socks5 | sopt | 端口指定 | 关闭socks5 | 端口随机 | 必选之一 【xray/singbox内核：TCP】 |
| 10、启用hysteria2 | hypt | 端口指定 | 关闭hy2 | 端口随机 | 必选之一 【singbox内核：UDP】 |
| 11、启用tuic | tupt | 端口指定 | 关闭tuic | 端口随机 | 必选之一 【singbox内核：UDP】 |
| 12、启用 Mieru TCP | mitpt | 1025-65535 单端口或严格递增范围 | 关闭 Mieru TCP | 复用已保存端口；无保存则随机 | 必选之一 【Mita 内核：原生 TCP 直连】 |
| 13、启用 Mieru UDP | miupt | 1025-65535 单端口或严格递增范围 | 关闭 Mieru UDP | 复用已保存端口；无保存则随机 | 必选之一 【Mita 内核：原生 UDP 直连】 |
| 14、Mieru 用户名 | miuser | 1-64 位 URL-safe ASCII | 首装默认 argosbx；rep 保留旧值 | 首装默认 argosbx；rep 保留旧值 | 可选，仅允许字母、数字、点、下划线、波浪线、连字符 |
| 15、Mieru 密码 | mipass | 12-128 位 URL-safe ASCII | 首装随机；rep 保留旧值 | 首装随机；rep 保留旧值 | 可选，默认生成 32 字符 Base64URL 高熵密码 |
| 16、warp开关 | warp | 详见下方15种warp出站模式图 | 关闭warp | singbox与xray内核协议都启用warp全局V4+V6 | 可选；WARP 不作用于 Mieru |
| 17、argo开关 | argo | 填写vwpt或者vmpt | 关闭argo隧道 | 关闭argo隧道 | 可选；Mieru 不能选作 Argo/CDN 协议 |
| 18、argo固定隧道域名 | agn | 托管在CF上的域名 | 使用临时隧道 | 使用临时隧道 | 可选，argo填写vmpt或vwpt时才可激活固定隧道|
| 19、argo固定隧道token | agk | CF获取的ey开头的token | 使用临时隧道 | 使用临时隧道 | 可选，argo填写vmpt或vwpt时才可激活固定隧道 |
| 20、uuid密码 | uuid | 符合uuid规定格式 | 随机生成 | 随机生成 | 可选 |
| 21、reality域名（仅支持reality类协议） | reym | 符合reality域名规定 | apple官网 | apple官网 | 可选，使用CF类域名时：服务器ip:节点端口的组合，可作为ProxyIP/客户端地址反代IP（建议高位端口或纯IPV6下使用，以防被扫泄露）|
| 22、vmess-ws、vless-xhttp/ws-enc在客户端的host地址 | cdnym | CF解析IP的域名 | vmess-ws、vless-xhttp/ws-enc为直连 | vmess-ws、vless-xhttp/ws-enc为直连 | 可选，使用80系CDN或者回源CDN时可设置，否则客户端host地址需手动更改为CF解析IP的域名|
| 23、切换ipv4或ipv6配置 | ippz | 填写4或者6 | 自动识别IP配置 | 自动识别IP配置 | 可选，4表示IPV4配置输出，6表示IPV6配置输出 |
| 24、添加所有节点名称前缀 | name | 任意字符 | 默认协议名前缀 | 默认协议名前缀 | 可选 |
| 25、开启IP订阅链接 | sub | 填写y | 关闭IP订阅链接 | 关闭IP订阅链接 | 可选 |
| 26、IP订阅链接密码 | subid | 任意字符 | uuid | uuid | 可选 |
| 27、IP订阅链接端口 | subpt | 端口指定 | 随机端口 | 随机端口 | 可选 |
| 28、argo优选IP域名 | cfip | 填写IPV4或者[IPV6]或者域名 | 默认优选域名 | 默认优选域名 | 可选，IP域名之间留空格，仅限填写两个 |
| 29、hysteria2端口跳跃 | hyjpt | 范围端口或者单端口或者一起混用 | 关闭端口跳跃 | 关闭端口跳跃 | 可选，范围端口格式为小数字:大数字，每组端口之间留空格 |
| 30、【仅容器类docker】监听端口，网页查询 | PORT | 端口指定 | 3000 | 3000 | 可选 |
| 31、【仅容器类docker】启用vless-ws-tls | DOMAIN | 服务器域名 | 关闭vless-ws-tls | 关闭vless-ws-tls | 可选，vless-ws-tls可独立存在，uuid变量必须启用 |

> Mieru 端口范围不支持逗号列表或空格，且起始端口必须小于结束端口。TCP 与 UDP 可以使用相同数字；同时随机生成时会选择不同端口。脚本会在写入配置前检查现有 Argosbx 端口及系统监听冲突。

------------------------------------------------------------------

* #### 如下图：一键SSH命令生成器：[点击视频教程](https://youtu.be/4u6W4c-t3oU)

<img width="1201" height="800" alt="729cda77f5d7f29dcbab7915ec50b087" src="https://github.com/user-attachments/assets/c2c8d8ea-6526-4628-9a8a-8a5153f04987" />

------------------------------------------------------------------

* #### 如下图：Clawcloud爪云4套价格+7组协议的组合任你选：[点击视频教程](https://youtu.be/xOQV_E1-C84)

<img width="905" height="602" alt="9fdd57063373fb2c20b32c955e7d9894" src="https://github.com/user-attachments/assets/46632ce6-9a51-493a-82ee-8dd3eb297460" />

------------------------------------------------------------------

* #### 如下图：从此抛弃第三方独立的WARP脚本，xray+singbox双内核集成15种WARP出站组合：[点击视频教程](https://youtu.be/iywjT8fIka4)

<img width="1015" height="681" alt="e0b66a115b1cd6a5060c38cae6e45c55" src="https://github.com/user-attachments/assets/06e69e8e-f714-4ba5-a519-f09fdecb0bbf" />

----------------------------------------------------------

## 二、SSH一键变量脚本模版说明：

### 脚本以 ```变量名称="变量值"的单个或多个组合 + 主脚本``` 的形式运行

* 默认主脚本curl：```bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)```

* 如报错curl not found 可换用主脚本wget：```bash <(wget -qO- https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)```

* 必选其一的协议端口变量：```vwpt=""```、```vmpt=""```、```vmpt="" argo="vmpt"```、```vwpt="" argo="vwpt"```、```vlpt=""```、```xhpt=""```、```anpt=""```、```arpt=""```、```hypt=""```、```tupt=""```、```sspt=""```、```vxpt=""```、```sopt=""```、```mitpt=""```、```miupt=""```

请参考```一、自定义变量参数说明```中变量的作用说明，变量值填写在```" "```之间，变量之间空一格，不用的变量可以删除

-------------------------------------------------------------

* ### 模版1：多个任意协议组合运行
```
sspt="" vlpt="" vmpt="" vwpt="" hypt="" tupt="" xhpt="" vxpt="" anpt="" arpt="" sopt="" mitpt="" miupt="" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

* ### 模版2：主流TCP或UDP单个协议运行

Vless-Tcp-Reality-vision协议节点
```
vlpt="" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Vless-Xhttp-Reality-vision-enc协议节点 (默认开启ENC加密)
```
xhpt="" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Vless-Xhttp-vision-enc协议节点 (默认开启ENC加密，IDX-Google-VPS容器支持)
```
vxpt="" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Vless-ws-vision-enc协议节点 (默认开启ENC加密)
```
vwpt="" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Shadowsocks-2022协议节点
```
sspt="" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

AnyTLS协议节点
```
anpt="" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Any-Reality协议节点
```
arpt="" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Vmess-ws协议节点
```
vmpt="" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Socks5协议节点 (配合其他应用内置代理使用，勿做节点直接使用)
```
sopt="" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Hysteria2协议节点
```
hypt="" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Tuic协议节点
```
tupt="" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Mieru-only TCP 节点（不会下载或启动 Xray/Sing-box）
```
mitpt="" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Mieru-only UDP 节点
```
miupt="" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Mieru TCP + UDP 范围节点（自定义凭据）
```
mitpt="5000-5010" miupt="6000-6010" miuser="argosbx" mipass="change-this-password" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

* ### 模版3：开启CDN优选的节点运行

Argo临时/固定隧道运行优选节点，类似无公网的IDX-Google-VPS容器推荐使用此脚本，快速一键内网穿透获取节点

Vmess-ws-argo临时隧道CDN优选节点
```
vmpt="" argo="vmpt" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Vless-ws-vision-enc-argo临时隧道CDN优选节点
```
vwpt="" argo="vwpt" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Vmess-ws-argo-argo固定隧道CDN优选节点，必须填写端口(vmpt)、域名(agn)、token(agk)
```
vmpt="CF设置的URL端口" argo="vmpt" agn="解析的CF域名" agk="CF获取的token" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Vless-ws-vision-enc-argo固定隧道CDN优选节点，必须填写端口(vmpt)、域名(agn)、token(agk)
```
vwpt="CF设置的URL端口" argo="vwpt" agn="解析的CF域名" agk="CF获取的token" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Vmess-ws的80系端口、回源端口的CDN优选节点
```
vmpt="80系端口、指定回源端口" cdnym="CF解析IP的域名" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Vless-Xhttp-vision-enc的80系端口、回源端口的CDN优选节点
```
vxpt="80系端口、指定回源端口" cdnym="CF解析IP的域名" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

Vless-ws-vision-enc的80系端口、回源端口的CDN优选节点
```
vwpt="80系端口、指定回源端口" cdnym="CF解析IP的域名" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
```

* #### 如下图：节点IP、端口被封依旧可用！套CDN优选5大方案三步视频教程：
  
[视频1：80系+回源cdn](https://youtu.be/RnUT1CNbCr8)

[视频2：Argo临时/固定隧道区别与设置](https://youtu.be/K35NhrNiLK8)

[视频3：黑科技80端口CDN](https://youtu.be/X8BFVyeiY9g)

<img width="1776" height="960" alt="f51af75fcc76bae7e76fe0ef5b9ecc86" src="https://github.com/user-attachments/assets/028b780d-bd48-4c79-8c60-940b3c3d1937" />

---------------------------------------------------------

## 三、Mieru 客户端、订阅、Docker 与限制

### 1、运行架构与平台限制

- 固定集成 [Mieru v3.34.0](https://github.com/enfein/mieru/tree/v3.34.0)。服务端仅常驻 `mita`；`mieru` 客户端二进制只用于生成和自检分享链接。
- v1 仅支持公网 IPv4、IPv6 或域名的原生 TCP/UDP 直连，不接入 Argo、CDN、普通 Cloudflare Tunnel，也不走现有 WARP 出站。选择 `warp` 时，WARP 仍只作用于 Xray/Sing-box。
- Cloud Foundry、SAP 等仅提供 HTTP 路由的平台不支持 Mieru；Node 容器检测到这些环境时会拒绝启动 Mita并输出提示。普通 Docker 必须允许原生 TCP/UDP 端口映射。
- 服务端和客户端时间需要同步。脚本只对系统时钟状态给出告警，不阻断安装；时间偏差过大时可能无法连接。

### 2、客户端与输出矩阵

| 客户端/格式 | 输出 | 说明 |
| :--- | :--- | :--- |
| 官方 Mieru | `$HOME/agsbx/mieru.txt` | 包含标准 `mieru://` 和简单 `mierus://`；TCP+UDP 时同时保存组合、TCP 独立、UDP 独立简单链接 |
| Clash/Mihomo | `$HOME/agsbx/clmi.yaml` | TCP、UDP 分别生成 `type: mieru` 节点；单端口使用 `port`，范围使用 `port-range` |
| 原版 Sing-box | `$HOME/agsbx/sbox.json` | 不写入 Mieru outbound；需要兼容 Mieru 时请使用 `mbox` 等实现 |
| 聚合单节点 | `$HOME/agsbx/jhsub.txt` | 仅追加 Mieru 组合简单链接，避免重复节点 |

启用本地订阅 `sub=y` 后可访问 `http://服务器IP:订阅端口/<token>/mieru.txt`。Node 容器地址为 `http://容器地址:PORT/<uuid>/mieru.txt`。运行 `agsbx list` 会重新生成 Mieru 链接和 Mihomo YAML，因此 `ippz=4/6` 切换也会同步更新地址。

### 3、Docker/GHCR 部署

fork 的 Actions 默认构建 `linux/amd64`、`linux/arm64` 并发布 `ghcr.io/<fork-owner>/argosbx`。容器中建议显式指定端口；若让脚本随机选端口，Docker 无法预先映射该随机端口。

单端口 TCP/UDP 使用相同数字：

```bash
docker run -d --name argosbx \
  -e mitpt=5000 -e miupt=5000 \
  -e miuser=argosbx -e mipass=change-this-password \
  -p 3000:3000 \
  -p 5000:5000/tcp -p 5000:5000/udp \
  ghcr.io/<fork-owner>/argosbx
```

完整范围映射：

```bash
docker run -d --name argosbx \
  -e mitpt=5000-5010 -e miupt=6000-6010 \
  -p 3000:3000 \
  -p 5000-5010:5000-5010/tcp \
  -p 6000-6010:6000-6010/udp \
  ghcr.io/<fork-owner>/argosbx
```

同时在系统防火墙和云厂商安全组放行完整 TCP/UDP 单端口或范围；只映射范围中的一个端口会导致部分 Mieru 连接失败。

### 4、内核发布、升级与许可证

- fork 的 Release 标签为 `mieru-core-v3.34.0`，包含 `mita-linux-amd64`、`mita-linux-arm64`、`mieru-linux-amd64`、`mieru-linux-arm64`、`SHA256SUMS`、`MIERU-LICENSE` 和 `mieru-v3.34.0-source.tar.gz`。
- Actions 构建的容器和 fork 的 GitHub Pages 命令生成器默认使用当前 fork。直接通过 raw URL/process substitution 执行主脚本时无法自动获知来源，因此首次从 fork 安装请显式设置 `ARGOSBX_ASSET_REPO=<fork-owner>/argosbx`；该值会保存到 `$HOME/agsbx/asset_repo`，后续 `rep`、`upm` 和快捷脚本继续复用。Release 和 GHCR 应由同一 fork 发布。
- `agsbx upm` 同时升级 `mita` 与 `mieru`：先下载到临时文件并校验 SHA-256，成功后原子替换、重启 Mita、重新生成链接；失败会保留旧二进制和正在运行的服务。
- Argosbx 与 Mieru 均采用 GPL-3.0。再分发二进制时须保留 Mieru 原作者声明，并同时提供许可证、校验和及对应版本源码包。

---------------------------------------------------------

## 四、多功能SSH快捷方式命令组

#### 说明：首次安装成功后需重连SSH，```agsbx 命令```的快捷方式才可生效；如未生效，请使用```主脚本 命令```的快捷方式

1、查看Argo的固定域名、固定隧道的token、临时域名、当前已安装的节点信息命令：```agsbx list``` 或者 ```主脚本 list```

2、更换、增加、删除变量组命令：```自定义各种协议变量组 agsbx rep``` 或者 ```自定义各种协议变量组 主脚本 rep```

3、更新脚本命令：```原已安装的自定义各种协议变量组 主脚本 rep``` 

4、更新 Xray、Sing-box 或 Mieru 内核命令：```agsbx upx```、```agsbx ups```、```agsbx upm```【或者】主脚本加对应参数

5、重启脚本命令：```agsbx res``` 或者 ```主脚本 res```

6、卸载脚本命令：```agsbx del``` 或者 ```主脚本 del```

7、临时切换IPV4/IPV6节点配置 (双栈VPS专享)：

显示IPV4节点配置：```ippz=4 agsbx list```或者```ippz=4 主脚本 list```

显示IPV6节点配置：```ippz=6 agsbx list```或者```ippz=6 主脚本 list```

----------------------------------------------------------

#### 相关教程可参考[甬哥博客](https://ygkkk.blogspot.com/2025/08/argosb.html)，视频教程如下：

[小白一分钟快速自建翻墙VPN代理：一键生成SSH命令；解决IP限制、IP质量太差问题；Argo固定隧道设置要点](https://youtu.be/xHzZFP_ywLs)

[🥇搭建代理9大问题排行榜：第4名全网99%的人被误导！第1名每个人都被折腾到爆！](https://youtu.be/pJwJBqBkcfw)

[🥇2025年度代理协议"拉到夯"综合排名](https://youtu.be/IoFtykGXDao)

[ArgoSBX小钢炮脚本更新说明：新增VLESS ENC抗量子加密；80端口也能开启TLS加密？无需域名也能CDN优选？](https://youtu.be/X8BFVyeiY9g)

[Argo隧道代理节点终极教程：VPS+容器搭建最强CDN节点 | 无视端口IP被封 | Argo临时/固定隧道区别 | CDN优选IP加速](https://youtu.be/K35NhrNiLK8)

[ArgoSBX一键无交互小钢炮脚本💣（四）：一键SSH命令生成器发布，只要点几下，各大代理协议任你选](https://youtu.be/4u6W4c-t3oU)

[ArgoSB一键无交互小钢炮脚本💣（三）：内置15种WARP出站组合，轻松替代独立的WARP脚本](https://youtu.be/iywjT8fIka4)

[ArgoSB一键无交互小钢炮脚本💣（二）：代理节点的IP、端口被封依旧可用！ArgoSB脚本套CDN优选4大方案教程](https://youtu.be/RnUT1CNbCr8)

[ArgoSB一键无交互小钢炮脚本💣（一）：VPS/nat VPS在主协议下的应用；仅按一次回车，多协议自由搭配](https://youtu.be/CiXmttY7mhw)

----------------------------------------------------------

### 交流平台：[甬哥博客地址](https://ygkkk.blogspot.com)、[甬哥YouTube频道](https://www.youtube.com/@ygkkk)、[甬哥TG电报群组](https://t.me/+jZHc6-A-1QQ5ZGVl)、[甬哥TG电报频道](https://t.me/+DkC9ZZUgEFQzMTZl)

----------------------------------------------------------
### 感谢支持！微信打赏甬哥侃侃侃ygkkk
![41440820a366deeb8109db5610313a1](https://github.com/user-attachments/assets/e5b1f2c0-bd2c-4b8f-8cda-034d3c8ef73f)

----------------------------------------------------------
### 感谢你右上角的star🌟
[![Stargazers over time](https://starchart.cc/yonggekkk/ArgoSB.svg)](https://starchart.cc/yonggekkk/ArgoSB)

----------------------------------------------------------
### 声明：所有代码来源于Github社区与ChatGPT的整合

### Thanks to [zmto/vtexs](https://console.zmto.com/?affid=1558) for the sponsorship support
