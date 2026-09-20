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

      if (request.method === "HEAD") {
        const object = await env.APK_BUCKET.head("latest.apk");
        if (object === null) {
          return new Response("APK is not available yet.", { status: 404 });
        }

        const headers = new Headers();
        object.writeHttpMetadata(headers);
        headers.set("etag", object.httpEtag);
        headers.set("Content-Type", "application/vnd.android.package-archive");
        headers.set(
          "Content-Disposition",
          'attachment; filename="my-lock-latest.apk"',
        );
        headers.set("Content-Length", String(object.size));
        headers.set("Accept-Ranges", "bytes");
        headers.set("Cache-Control", "no-store, max-age=0");
        headers.set("X-Content-Type-Options", "nosniff");
        return new Response(null, { status: 200, headers });
      }

      const object = await env.APK_BUCKET.get("latest.apk", {
        onlyIf: request.headers,
        range: request.headers,
      });

      if (object === null) {
        return new Response("APK is not available yet.", {
          status: 404,
          headers: { "Cache-Control": "no-store" },
        });
      }

      const headers = new Headers();
      object.writeHttpMetadata(headers);
      headers.set("etag", object.httpEtag);
      headers.set("Content-Type", "application/vnd.android.package-archive");
      headers.set(
        "Content-Disposition",
        'attachment; filename="my-lock-latest.apk"',
      );
      headers.set("Accept-Ranges", "bytes");
      headers.set("Cache-Control", "no-store, max-age=0");
      headers.set("X-Content-Type-Options", "nosniff");

      if (!("body" in object)) {
        return new Response(null, { status: 412, headers });
      }

      let status = 200;
      if (object.range && request.headers.has("Range")) {
        const start = object.range.offset ?? 0;
        const length = object.range.length ?? object.size;
        const end = start + length - 1;
        headers.set("Content-Range", `bytes ${start}-${end}/${object.size}`);
        headers.set("Content-Length", String(length));
        status = 206;
      } else {
        headers.set("Content-Length", String(object.size));
      }

      return new Response(object.body, { status, headers });
    }

    return env.ASSETS.fetch(request);
  },
};
