This is a simple Worker that serves the web folder from the Earthrite game with the proper server response headers to avoid the [SharedArrayBuffer & Cross Origin Isolation issues](https://github.com/godotengine/godot/issues/69020). You can access it here:

[https://earthrite.tomsprojects.workers.dev/](https://earthrite.tomsprojects.workers.dev/)

It will use Cloudflare Workers' support for assets, hosted and served for free (https://developers.cloudflare.com/workers/static-assets/). This is configured in `wrangler.jsonc`. To serve assets with the appropriate headers, we must add a custom `_headers` (no file extension) in the web folder to indicate to Workers that those assets are to be served with the needed headers to resolve SharedArrayBuffer issues. The content should be:

```
/*
  Cross-Origin-Embedder-Policy: require-corp
  Cross-Origin-Opener-Policy: same-origin
```

(For more explanation on why this is needed, refer to my comment in Ffmpeg.wasm repo: [https://github.com/ffmpegwasm/ffmpeg.wasm/issues/263#issuecomment-2889447079](https://github.com/ffmpegwasm/ffmpeg.wasm/issues/263#issuecomment-2889447079))

We would typically be done at this point. But since the game has WASM assets that are larger than 25mb, and Cloudflare Workers static assets does not support 25mb, we will host the larger assets on R2 and manually serve the larger assets from the R2 bucket. You'll also notice that the larger file, in this case, index.wasm, is absent from `./web`.

Instead, this file was uploaded to an R2 bucket named `earthrite-assets` as configured in `wrangler.jsonc`. This file is then served from `/index.wasm` path, and all other requests return a `Not Found`.

> [!NOTE]  
> Instead of hosting on R2, it would also be technically possible to proxy the request to GitHub Release assets (if you were to upload them there) for a one-off, hacky/hobby project.
