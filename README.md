## Argosbx一键无交互小钢炮脚本💣：极简 + 轻量 + 快速

---------------------------------------

<img width="757" height="255" alt="d89e2542c513e705106371acc7fa1d33" src="https://github.com/user-attachments/assets/7d7a4678-4223-478c-afe2-d303ba0f85a4" />


### 【Argosbx当前版本：V25.11.20】

---------------------------------------

#### 1、基于Sing-box + Xray + Cloudflared-Argo 三内核自动分配

#### 2、支持Linux类主流VPS系统（建议最新版系统），SSH脚本支持非root环境运行，几乎无需依赖，无脑一次回车搞定

#### 3、支持各种容器系统，Docker镜像部署，公开镜像库：```ygkkk/argosbx```

#### 4、根据Sing-box与Xray不同内核，可选15种WARP出站组合，更换落地IP为WARP的IP，解锁流媒体

#### 5、所有代理协议都无需域名（除了argo固定隧道、IP端口CDN），支持单个或多个代理协议任意组合并快速重置更换
【 已支持：AnyTLS、Any-reality、Vless-xhttp-reality-vison-enc、Vless-tcp-reality-vision、Vless-xhttp-vison-enc、Vless-ws-vision-enc、Shadowsocks-2022、Vmess-ws、Socks5、Hysteria2、Tuic、Argo临时/固定隧道支持Vless-ws-vision-enc或Vmess-ws 】

#### 6、建议配合SSH一键脚本命令生成器网页使用：https://yonggekkk.github.io/argosbx/

#### 7、如需要多样的功能，推荐使用VPS专用四合一脚本[Sing-box-yg](https://github.com/yonggekkk/sing-box-yg)

#### 8、Argosbx客户端推荐：

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
| 12、warp开关 | warp | 详见下方15种warp出站模式图 | 关闭warp | singbox与xray内核协议都启用warp全局V4+V6 | 可选，详见下方15种warp出站模式图 |
| 13、argo开关 | argo | 填写vwpt或者vmpt | 关闭argo隧道 | 关闭argo隧道 | 可选，填写vmpt或vwpt时，vmess-ws或vless-ws变量vmpt或vwpt必须启用，且固定隧道必须填写vmpt或vwpt端口 |
| 14、argo固定隧道域名 | agn | 托管在CF上的域名 | 使用临时隧道 | 使用临时隧道 | 可选，argo填写vmpt或vwpt时才可激活固定隧道|
| 15、argo固定隧道token | agk | CF获取的ey开头的token | 使用临时隧道 | 使用临时隧道 | 可选，argo填写vmpt或vwpt时才可激活固定隧道 |
| 16、uuid密码 | uuid | 符合uuid规定格式 | 随机生成 | 随机生成 | 可选 |
| 17、reality域名（仅支持reality类协议） | reym | 符合reality域名规定 | apple官网 | apple官网 | 可选，使用CF类域名时：服务器ip:节点端口的组合，可作为ProxyIP/客户端地址反代IP（建议高位端口或纯IPV6下使用，以防被扫泄露）|
| 18、vmess-ws、vless-xhttp/ws-enc在客户端的host地址 | cdnym | CF解析IP的域名 | vmess-ws、vless-xhttp/ws-enc为直连 | vmess-ws、vless-xhttp/ws-enc为直连 | 可选，使用80系CDN或者回源CDN时可设置，否则客户端host地址需手动更改为CF解析IP的域名|
| 19、切换ipv4或ipv6配置 | ippz | 填写4或者6 | 自动识别IP配置 | 自动识别IP配置 | 可选，4表示IPV4配置输出，6表示IPV6配置输出 |
| 20、添加所有节点名称前缀 | name | 任意字符 | 默认协议名前缀 | 默认协议名前缀 | 可选 |
| 21、当前系统开放所有端口 | oap | 填写y | 禁止开放所有端口 | 禁止开放所有端口 | 可选，开启运行一次即可，后续删除变量，没必要每次运行 |
| 22、【仅容器类docker】监听端口，网页查询 | PORT | 端口指定 | 3000 | 3000 | 可选 |
| 23、【仅容器类docker】启用vless-ws-tls | DOMAIN | 服务器域名 | 关闭vless-ws-tls | 关闭vless-ws-tls | 可选，vless-ws-tls可独立存在，uuid变量必须启用 |

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

* 必选其一的协议端口变量：```vwpt=""```、```vmpt=""```、```vmpt="" argo="vmpt"```、```vwpt="" argo="vwpt"```、```vlpt=""```、```xhpt=""```、```anpt=""```、```arpt=""```、```hypt=""```、```tupt=""```、```sspt=""```、```vxpt=""```、```sopt=""```

* 可选的功能类变量：```warp=""```、```uuid=""```、```reym=""```、```cdnym=""```、```argo=""```、```agn=""```、```agk=""```、```ippz=""```、```name=""```、```oap=""```

请参考```一、自定义变量参数说明```中变量的作用说明，变量值填写在```" "```之间，变量之间空一格，不用的变量可以删除

-------------------------------------------------------------

* ### 模版1：多个任意协议组合运行
```
sspt="" vlpt="" vmpt="" vwpt="" hypt="" tupt="" xhpt="" vxpt="" anpt="" arpt="" sopt="" bash <(curl -Ls https://raw.githubusercontent.com/yonggekkk/argosbx/main/argosbx.sh)
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

## 三、多功能SSH快捷方式命令组

#### 说明：首次安装成功后需重连SSH，```agsbx 命令```的快捷方式才可生效；如未生效，请使用```主脚本 命令```的快捷方式

1、查看Argo的固定域名、固定隧道的token、临时域名、当前已安装的节点信息命令：```agsbx list``` 或者 ```主脚本 list```

2、更换、增加、删除变量组命令：```自定义各种协议变量组 agsbx rep``` 或者 ```自定义各种协议变量组 主脚本 rep```

3、更新脚本命令：```原已安装的自定义各种协议变量组 主脚本 rep``` 

4、更新Xray或Singbox内核命令：agsbx upx或ups 【或者】 主脚本 upx或ups

5、重启脚本命令：```agsbx res``` 或者 ```主脚本 res```

6、卸载脚本命令：```agsbx del``` 或者 ```主脚本 del```

7、临时切换IPV4/IPV6节点配置 (双栈VPS专享)：

显示IPV4节点配置：```ippz=4 agsbx list```或者```ippz=4 主脚本 list```

显示IPV6节点配置：```ippz=6 agsbx list```或者```ippz=6 主脚本 list```

----------------------------------------------------------

#### 相关教程可参考[甬哥博客](https://ygkkk.blogspot.com/2025/08/argosb.html)，视频教程如下：

[🥇搭建代理9大问题排行榜：第4名全网99%的人被误导！第1名每个人都被折腾到爆！](https://youtu.be/pJwJBqBkcfw)

[🥇2025年度代理协议"拉到夯"综合排名](https://youtu.be/IoFtykGXDao)

[ArgoSBX小钢炮脚本更新说明：新增VLESS ENC抗量子加密；80端口也能开启TLS加密？无需域名也能CDN优选？](https://youtu.be/X8BFVyeiY9g)

[Argo隧道代理节点终极教程：VPS+容器搭建最强CDN节点 | 无视端口IP被封 | Argo临时/固定隧道区别 | CDN优选IP加速](https://youtu.be/K35NhrNiLK8)

[ArgoSBX一键无交互小钢炮脚本💣（四）：一键SSH命令生成器发布，只要点几下，各大代理协议任你选](https://youtu.be/4u6W4c-t3oU)

[ArgoSB一键无交互小钢炮脚本💣（三）：内置15种WARP出站组合，轻松替代独立的WARP脚本](https://youtu.be/iywjT8fIka4)

[ArgoSB一键无交互小钢炮脚本💣（二）：代理节点的IP、端口被封依旧可用！ArgoSB脚本套CDN优选4大方案教程](https://youtu.be/RnUT1CNbCr8)

[ArgoSB一键无交互小钢炮脚本💣（一）：VPS/nat VPS在主协议下的应用；仅按一次回车，多协议自由搭配](https://youtu.be/CiXmttY7mhw)

[Clawcloud爪云、IDX Google VPS的福音：解决服务器IP访问困扰！Argosb脚本新增WARP出站功能，轻松更换落地IP为Cloudflare WARP IP](https://youtu.be/HO_XLBmIYJw)

[Claw.cloud免费VPS搭建代理最终教程（五）：ArgoSB脚本docker镜像更新支持AnyTLS、Xhttp-Reality](https://youtu.be/-mhZIhHRyno)

[Claw.cloud免费VPS搭建代理最终教程（四）：最低仅1美分，4套价格+7组协议的套餐组合任你选；查看节点、重启升级、更换IP、更改配置的操作说明](https://youtu.be/xOQV_E1-C84)

[SAP搭建免费节点一条龙教程：多平台多账号搭建+保活一次搞定，支持Argo/workers/pags多种CDN方式](https://youtu.be/NRYZNKWoLj8)

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
