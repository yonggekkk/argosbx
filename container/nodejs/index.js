const os = require('os');
const http = require('http');
const fs = require('fs');
const path = require('path');
const net = require('net');
const { spawn } = require('child_process');
const { WebSocket, createWebSocketStream } = require('ws');
const subtxt = path.join(process.env.HOME, 'agsbx', 'jh.txt');
const mieruTxt = path.join(process.env.HOME, 'agsbx', 'mieru.txt');
const NAME = process.env.NAME || os.hostname();
const PORT = process.env.PORT || 3000;
const uuid = process.env.uuid || '79411d85-b0dc-4cd2-b46c-01789a18c650';
process.env.uuid = uuid;
const DOMAIN = process.env.DOMAIN || 'YOUR.DOMAIN';
const vlessInfo = `vless://${uuid}@${DOMAIN}:443?encryption=none&security=tls&sni=${DOMAIN}&fp=chrome&type=ws&host=${DOMAIN}&path=%2F#Vl-ws-tls-${NAME}`;
console.log(`vless-ws-tls节点分享: ${vlessInfo}`);

const startScript = path.join(__dirname, 'start.sh');
fs.chmodSync(startScript, 0o755);
const child = spawn('bash', [startScript], {
    cwd: __dirname,
    env: { ...process.env, uuid },
    stdio: ['ignore', 'pipe', 'pipe']
});
child.stdout.on('data', (data) => console.log(data.toString().trimEnd()));
child.stderr.on('data', (data) => console.error(data.toString().trimEnd()));
child.on('close', (code) => console.log(`Argosbx start script exited with code ${code}`));

const server = http.createServer((req, res) => {
    if (req.url === '/') {
        res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end('🟢恭喜！Argosbx小钢炮脚本-nodejs版部署成功！\n\n聚合节点：/你的uuid\nMieru 链接：/你的uuid/mieru.txt');
        return;
    }

    if (req.url === `/${uuid}/mieru.txt`) {
        if (!fs.existsSync(mieruTxt)) {
            res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
            res.end('Mieru 未启用，或当前平台不支持原生 TCP/UDP 端口。');
            return;
        }
        res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
        fs.createReadStream(mieruTxt).pipe(res);
        return;
    }

    if (req.url === `/${uuid}`) {
        res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
        if (fs.existsSync(subtxt)) {
            fs.readFile(subtxt, 'utf8', (err, data) => {
                if (err) {
                    console.error(err);
                    res.end(`${vlessInfo}`);
                } else {
                    res.end(`${vlessInfo}\n${data}`);
                }
            });
        } else {
            res.end(`${vlessInfo}`);
        }
        return;
    }

    res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('404 Not Found');
});

server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

const wss = new (require('ws').Server)({ server });
const uuidkey = uuid.replace(/-/g, "");
wss.on('connection', ws => {
    ws.once('message', msg => {
        const [VERSION] = msg;
        const id = msg.slice(1, 17);
        if (!id.every((v, i) => v == parseInt(uuidkey.substr(i * 2, 2), 16))) return;
        let i = msg.slice(17, 18).readUInt8() + 19;
        const port = msg.slice(i, i += 2).readUInt16BE(0);
        const ATYP = msg.slice(i, i += 1).readUInt8();
        const host = ATYP == 1 ? msg.slice(i, i += 4).join('.') :
            (ATYP == 2 ? new TextDecoder().decode(msg.slice(i + 1, i += 1 + msg.slice(i, i + 1).readUInt8())) :
                (ATYP == 3 ? msg.slice(i, i += 16)
                    .reduce((s, b, i, a) => (i % 2 ? s.concat(a.slice(i - 1, i + 1)) : s), [])
                    .map(b => b.readUInt16BE(0).toString(16)).join(':') : ''));
        ws.send(new Uint8Array([VERSION, 0]));
        const duplex = createWebSocketStream(ws);
        net.connect({ host, port }, function () {
            this.write(msg.slice(i));
            duplex.on('error', () => { }).pipe(this).on('error', () => { }).pipe(duplex);
        }).on('error', () => { });
    }).on('error', () => { });
});
