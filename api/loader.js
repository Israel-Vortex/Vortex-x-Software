module.exports = function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Cache-Control", "no-store");
  res.setHeader("Content-Type", "text/plain; charset=utf-8");

  if (req.method === "OPTIONS") {
    return res.status(204).end();
  }

  const host = req.headers["x-forwarded-host"] || req.headers.host || "vortex-x-sage.vercel.app";
  const proto = req.headers["x-forwarded-proto"] || "https";
  const base = `\( {proto}:// \){host}`;
  const TOKEN = process.env.SCRIPT_TOKEN || "vx7k2m9gold";
  const scriptUrl = `\( {base}/api/script?t= \){TOKEN}`;

  const lua = `-- Vortex X Sage Loader
local url = "${scriptUrl}"
local src
local ok, err = pcall(function()
  src = game:HttpGet(url)
end)
if not ok then
  warn("[Vortex] HttpGet fallo: " .. tostring(err))
  return
end
if type(src) \~= "string" then
  warn("[Vortex] Respuesta invalida")
  return
end
if #src < 30 then
  warn("[Vortex] Respuesta muy corta (" .. tostring(#src) .. ")")
  return
end
if src:find("forbidden", 1, true) or src:find("empty script", 1, true) then
  warn("[Vortex] Server: " .. src:sub(1, 200))
  return
end
local fn, lerr = loadstring(src)
if not fn then
  warn("[Vortex] loadstring: " .. tostring(lerr))
  return
end
fn()
`;

  return res.status(200).send(lua);
};