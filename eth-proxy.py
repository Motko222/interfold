#!/usr/bin/env python3
"""
Lightweight HTTP+WS proxy for interfold ciphernode.

Interfold uses a single rpc_url for both:
  - HTTP JSON-RPC calls (non-subscription methods)
  - WebSocket subscriptions (eth_subscribe)

Geth exposes these on separate ports:
  - HTTP: 8645
  - WS:   8646

This proxy listens on 8647 and routes:
  - Upgrade: websocket  →  ws://localhost:8646
  - Plain HTTP          →  http://localhost:8645
"""

import asyncio
import aiohttp
from aiohttp import web

HTTP_BACKEND = "http://localhost:8645"
WS_BACKEND   = "ws://localhost:8646"
LISTEN_PORT  = 8647


async def ws_handler(req):
    async with aiohttp.ClientSession() as session:
        async with session.ws_connect(WS_BACKEND) as backend:
            client = await req.ws_connect()

            async def forward_to_backend():
                async for msg in client:
                    if msg.type == aiohttp.WSMsgType.TEXT:
                        await backend.send_str(msg.data)
                    elif msg.type == aiohttp.WSMsgType.BINARY:
                        await backend.send_bytes(msg.data)
                    elif msg.type in (aiohttp.WSMsgType.CLOSE, aiohttp.WSMsgType.ERROR):
                        break

            async def forward_to_client():
                async for msg in backend:
                    if msg.type == aiohttp.WSMsgType.TEXT:
                        await client.send_str(msg.data)
                    elif msg.type == aiohttp.WSMsgType.BINARY:
                        await client.send_bytes(msg.data)
                    elif msg.type in (aiohttp.WSMsgType.CLOSE, aiohttp.WSMsgType.ERROR):
                        break

            await asyncio.gather(forward_to_backend(), forward_to_client())
            return client


async def http_handler(req):
    async with aiohttp.ClientSession() as session:
        body = await req.read()
        async with session.request(
            method=req.method,
            url=HTTP_BACKEND + req.path_qs,
            headers={k: v for k, v in req.headers.items()
                     if k.lower() not in ("host", "content-length")},
            data=body,
        ) as resp:
            content = await resp.read()
            return web.Response(
                status=resp.status,
                headers={k: v for k, v in resp.headers.items()
                         if k.lower() not in ("transfer-encoding", "content-encoding")},
                body=content,
            )


async def router(req):
    if req.headers.get("Upgrade", "").lower() == "websocket":
        return await ws_handler(req)
    return await http_handler(req)


app = web.Application()
app.router.add_route("*", "/{path_info:.*}", router)

if __name__ == "__main__":
    web.run_app(app, host="0.0.0.0", port=LISTEN_PORT)
