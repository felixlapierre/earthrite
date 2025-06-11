// ───────────────────────────────────────────────────────────────────────────
//  Genius‑level simple‑wind shader – 2‑D CanvasItem
//  Author: ChatGPT 2025   (CC‑0; use freely)
// ───────────────────────────────────────────────────────────────────────────
shader_type canvas_item;
render_mode blend_mix;

// ─────────────── General wind parameters ───────────────
uniform vec2  wind_dir        = vec2(1.0, 0.0);      // normalised in code
uniform float wind_speed      = 1.0;                 // multiplies TIME
uniform float min_strength    : hint_range(0.0, 1.0) = 0.01;
uniform float max_strength    : hint_range(0.0, 1.0) = 0.06;
uniform float strength_scale  = 100.0;

// ─────────────── Gust behaviour ───────────────
uniform float gust_interval   = 3.5;                 // seconds per cycle
uniform float gust_turbulence = 0.4;                 // 0 = smooth, 1 = wild

// ─────────────── Wave detail ───────────────
uniform float large_wave_freq = 1.0;                 // gentle sway
uniform float ripple_freq     = 8.0;                 // leaf flutter
uniform float distortion      : hint_range(0.0, 1.0) = 0.25;

// ─────────────── Geometry envelope ───────────────
uniform float height_offset   : hint_range(0.0, 1.0) = 0.0;

// ─────────────── Per‑sprite randomness ───────────────
uniform float instance_offset : hint_range(0.0, 100.0) = 0.0;

// ───────────────────────────────────────────────────────
//  Helper hash – tiny, fast, good enough for turbulence
// ───────────────────────────────────────────────────────
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Strength varies sinusoidally between min & max, plus a little hash noise
float compute_strength(float t) {
    float phase = (sin(t / gust_interval * 6.28318) * 0.5 + 0.5); // 0‥1
    float base  = mix(min_strength, max_strength, phase);
    float noise = (hash(vec2(t, phase)) - 0.5) * gust_turbulence;
    return (base + noise) * strength_scale;
}

void vertex() {
    // Time phase (unique per instance)
    float t = TIME * wind_speed + instance_offset;

    // Pre‑normalise direction once per vertex
    vec2  dir  = normalize(wind_dir);
    vec2  perp = vec2(-dir.y, dir.x);               // 90° for flutter offset

    // Compute composite wave
    float strength   = compute_strength(t);
    float large_wave = sin(t * large_wave_freq);
    float ripple     = sin(t * ripple_freq + UV.y * 6.28318);
    float sway       = (large_wave + ripple * distortion) * strength;

    // Fade effect based on sprite height (UV.y == 0 at top in Godot)
    float height_mask = clamp((1.0 - UV.y) - height_offset, 0.0, 1.0);

    // Apply distortion
    VERTEX += (dir * sway) * height_mask;
}
