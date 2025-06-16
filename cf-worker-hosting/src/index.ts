/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run `npm run dev` in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run `npm run deploy` to publish your worker
 *
 * Bind resources to your worker in `wrangler.jsonc`. After adding bindings, a type definition for the
 * `Env` object can be regenerated with `npm run cf-typegen`.
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

export default {
	async fetch(request, env, ctx): Promise<Response> {
		// Parse the URL to get the pathname
		const url = new URL(request.url);
		const path = url.pathname.slice(1); // Remove leading slash

		// Check if the path is "index.wasm"
		if (path === 'index.wasm') {
			try {
				// Get the file from R2
				const object = await env.FALLBACK_ASSETS.get('index.wasm');

				if (object === null) {
					return new Response('WebAssembly file not found', { status: 404 });
				}

				// Return the file with appropriate headers
				return new Response(object.body, {
					headers: {
						'Content-Type': 'application/wasm',
						'Cache-Control': 'public, max-age=3600',
						'Cross-Origin-Embedder-Policy': 'require-corp',
						'Cross-Origin-Opener-Policy': 'same-origin',
					},
				});
			} catch (error) {
				const errorMessage = error instanceof Error ? error.message : 'Unknown error';
				return new Response('Error fetching WebAssembly file: ' + errorMessage, {
					status: 500,
				});
			}
		}

		// Return 404 for any other path
		return new Response('Not found', { status: 404 });
	},
} satisfies ExportedHandler<Env>;
