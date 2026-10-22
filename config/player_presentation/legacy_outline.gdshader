shader_type canvas_item;
uniform vec4 outline_color : source_color = vec4(1.0, 0.2, 0.15, 1.0);
uniform float outline_width = 1.0;

void fragment() {
    vec4 base = texture(TEXTURE, UV);
    float nearby = 0.0;
    vec2 px = TEXTURE_PIXEL_SIZE * outline_width;
    nearby = max(nearby, texture(TEXTURE, UV + vec2(px.x, 0.0)).a);
    nearby = max(nearby, texture(TEXTURE, UV - vec2(px.x, 0.0)).a);
    nearby = max(nearby, texture(TEXTURE, UV + vec2(0.0, px.y)).a);
    nearby = max(nearby, texture(TEXTURE, UV - vec2(0.0, px.y)).a);
    COLOR = base;
    if (base.a < 0.01 && nearby > 0.01) {
        COLOR = outline_color;
    }
}
