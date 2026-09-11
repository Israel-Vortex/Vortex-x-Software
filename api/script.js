/**
 * GET /api/script?t=TOKEN
 * Entrega el script real. Bloqueo básico de navegadores.
 */
const fs = require("fs");
const path = require("path");

const TOKEN = process.env.SCRIPT_TOKEN || "vx7k2m9gold";

function isBrowser(ua) {
  if (!ua) return false;
  const u = ua.toLowerCase();
  return (
    u.includes("mozilla") ||
    u.includes("chrome") ||
    u.includes("safari") ||
    u.includes("firefox") ||
    u.includes("edg/") ||
    u.includes("opr/")
  );
}

module.exports = function handler(req, res) {
  res.setHeader("Cache-Control", "no-store");
  res.setHeader("Content-Type", "text/plain; charset=utf-8");
  res.setHeader("X-Robots-Tag", "noindex");

  if (req.method === "OPTIONS") {
    res.setHeader("Access-Control-Allow-Origin", "*");
    return res.status(204).end();
  }

  const token = (req.query && req.query.t) || "";
  if (token !== TOKEN) {
    return res.status(403).send("-- forbidden");
  }

  const ua = req.headers["user-agent"] || "";
  if (isBrowser(ua)) {
    return res.status(403).send("-- Browser blocked. Use a Roblox executor.");
  }

  // En Vercel el código está en /var/task; private/ se incluye si está en el repo
  // Alternativa: SCRIPT_SOURCE en variable de entorno (recomendado si el script es grande)
  let source = process.env.SCRIPT_SOURCE || "";

  if (!source) {
    const candidates = [
      path.join(process.cwd(), "private", "script.lua"),
      path.join(__dirname, "..", "private", "script.lua"),
      path.join("/var/task", "private", "script.lua"),
    ];
    for (const p of candidates) {
      try {
        if (fs.existsSync(p)) {
          source = fs.readFileSync(p, "utf8");
          break;
        }
      } catch (_) {}
    }
  }

  if (!source || source.length < 30) {
    return res.status(500).send("-- empty script (sube private/script.lua o define SCRIPT_SOURCE)");
  }

  return res.status(200).send(source);
};
