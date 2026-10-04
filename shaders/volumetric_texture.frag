#version 460 core
#include <flutter/runtime_effect.glsl>
uniform vec2 uSize;
uniform float uPhase;
uniform sampler2D uLight;
out vec4 fragColor;
void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float envelope = smoothstep(0.0, 0.08, uv.y) * (1.0 - smoothstep(0.35, 0.66, uv.y));
  float a = uv.x * 7.0 + uv.y * 4.0;
  float b = uv.x * 11.0 - uv.y * 6.0;
  // Phase zero is the exact static study. Source stays anchored to the surface.
  uv.x += envelope * (0.020 * (sin(uPhase * 5.0 + a) - sin(a))
      + 0.007 * (sin(uPhase * 3.0 + b) - sin(b)));
  uv.y += envelope * 0.007 * (sin(uPhase * 3.0 + a) - sin(a));
  vec4 light = texture(uLight, clamp(uv, vec2(0.0), vec2(1.0)));
  float breath = 1.0 + 0.18 * (sin(uPhase * 5.0 + a) - sin(a));
  float cutoff = 1.0 - smoothstep(0.63, 0.66, uv.y);
  // Flutter's sampler is premultiplied; scale all channels together.
  fragColor = light * breath * cutoff;
}
