/**
 * GET /api/script?t=TOKEN
 * - Navegador → redirige a la web (sin mensaje de bloqueo)
 * - Executor → script real
 */
const fs = require("fs");
const path = require("path");

const TOKEN = process.env.SCRIPT_TOKEN || "vx7k2m9gold";

function isBrowserRequest(req) {
  const accept = (req.headers["accept"] || "").toLowerCase();
  const mode = (req.headers["sec-fetch-mode"] || "").toLowerCase();
  const dest = (req.headers["sec-fetch-dest"] || "").toLowerCase();
  return accept.includes("text/html") || mode === "navigate" || dest === "document";
}

function readScript() {
  if (process.env.SCRIPT_SOURCE && process.env.SCRIPT_SOURCE.length > 30) {
    return process.env.SCRIPT_SOURCE;
  }
  const candidates = [
    path.join(process.cwd(), "private", "script.lua"),
    path.join(__dirname, "..", "private", "script.lua"),
    path.join("/var/task", "private", "script.lua"),
  ];
  for (const p of candidates) {
    try {
      if (fs.existsSync(p)) {
        const data = fs.readFileSync(p, "utf8");
        if (data && data.length > 30) return data;
      }
    } catch (_) {}
  }
  return null;
}

module.exports = function handler(req, res) {
  res.setHeader("Cache-Control", "no-store");
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("X-Robots-Tag", "noindex");

  if (req.method === "OPTIONS") {
    return res.status(204).end();
  }

  // Abrir en Google/Chrome → ir a la web (sin "blocked browser")
  if (isBrowserRequest(req)) {
    const host = req.headers["x-forwarded-host"] || req.headers.host || "vortex-x-sage.vercel.app";
    const proto = req.headers["x-forwarded-proto"] || "https";
    res.writeHead(302, { Location: `${proto}://${host}/` });
    return res.end();
  }

  const token = (req.query && req.query.t) || "";
  if (token !== TOKEN) {
    return res.status(403).send("-- forbidden");
  }

  const source = readScript();
  if (!source) {
    return res.status(500).send("-- empty script (sube private/script.lua)");
  }

  res.setHeader("Content-Type", "text/plain; charset=utf-8");
  return res.status(200).send(source);
};
