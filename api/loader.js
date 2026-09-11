/**
 * GET /api/loader
 * - Navegador → redirige a la web (/)
 * - Executor / HttpGet → devuelve el loader Lua
 */
module.exports = function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Cache-Control", "no-store");

  if (req.method === "OPTIONS") {
    return res.status(204).end();
  }

  const ua = (req.headers["user-agent"] || "").toLowerCase();
  const isBrowser =
    ua.includes("mozilla") ||
    ua.includes("chrome") ||
    ua.includes("safari") ||
    ua.includes("firefox") ||
    ua.includes("edg/") ||
    ua.includes("opr/") ||
    ua.includes("mobile");

  if (isBrowser) {
    const host = req.headers["x-forwarded-host"] || req.headers.host || "vortex-x-sage.vercel.app";
    const proto = req.headers["x-forwarded-proto"] || "https";
    res.writeHead(302, { Location: `\( {proto}:// \){host}/` });
    return res.end();
  }

  res.setHeader("Content-Type", "text/plain; charset=utf-8");

  const host = req.headers["x-forwarded-host"] || req.headers.host || "vortex-x-sage.vercel.app";
  const proto = req.headers["x-forwarded-proto"] || "https";
  const base = `\( {proto}:// \){host}`;

  const TOKEN = process.env.SCRIPT_TOKEN || "vx7k2m9gold";

  const lua = `-- Vortex X Sage Loader (Vercel)
local url = "\( {base}/api/script?t= \){TOKEN}"
local body
local ok, res = pcall(function()
  if syn and syn.request then
    return syn.request({ Url = url, Method = "GET", Headers = { ["User-Agent"] = "VortexExecutor/1.0" } })
  elseif request then
    return request({ Url = url, Method = "GET", Headers = { ["User-Agent"] = "VortexExecutor/1.0" } })
  elseif http and http.request then
    return http.request({ Url = url, Method = "GET", Headers = { ["User-Agent"] = "VortexExecutor/1.0" } })
  else
    return { StatusCode = 200, Body = game:HttpGet(url) }
  end
end)
if not ok or not res then
  return warn("[Vortex] No se pudo contactar el servidor")
end
body = res.Body or res.body or (type(res) == "string" and res)
local code = tonumber(res.StatusCode or res.status_code or 200)
if code \~= 200 or not body or #tostring(body) < 20 then
  return warn("[Vortex] Script no disponible (" .. tostring(code) .. ")")
end
local fn, err = loadstring(body)
if not fn then
  return warn("[Vortex] Error loadstring: " .. tostring(err))
end
fn()
`;

  return res.status(200).send(lua);
};
