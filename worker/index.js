const APK_ORIGIN =
  "https://github.com/Dudozi-workshop/my-lock/releases/download/latest-debug/my-lock-latest.apk";

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname === "/latest.apk" || url.pathname === "/my-lock-latest.apk") {
      if (request.method !== "GET" && request.method !== "HEAD") {
        return new Response("Method Not Allowed", {
          status: 405,
          headers: { Allow: "GET, HEAD" },
        });
      }

      const upstream = await fetch(APK_ORIGIN, {
        method: request.method,
        redirect: "follow",
        headers: {
          "User-Agent": "MY-LOCK-APK-Downloader/1.0",
          Accept: "application/vnd.android.package-archive,application/octet-stream,*/*",
        },
      });

      if (!upstream.ok) {
        return new Response("APK is temporarily unavailable.", {
          status: 502,
          headers: { "Cache-Control": "no-store" },
        });
      }

      const headers = new Headers(upstream.headers);
      headers.set("Content-Type", "application/vnd.android.package-archive");
      headers.set(
        "Content-Disposition",
        'attachment; filename="my-lock-latest.apk"',
      );
      headers.set("Cache-Control", "no-store, max-age=0");
      headers.set("X-Content-Type-Options", "nosniff");

      return new Response(request.method === "HEAD" ? null : upstream.body, {
        status: 200,
        headers,
      });
    }

    return env.ASSETS.fetch(request);
  },
};
