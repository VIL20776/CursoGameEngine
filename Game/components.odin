package game

import rl "vendor:raylib"

Name :: string

Texture :: struct {
    data: rl.Texture2D,
    path: cstring
}

Tilemap :: struct {
    positions: []rl.Vector2,
    tiles: []rl.Vector2,
    tile_size: int
}

Animation :: struct {
    start: rl.Rectangle,
    offset: int,
    frames: int,
    size: int,
    time: f64,
    nextTime: f64
}

Movement :: struct{
    speed: f32,
    axis_x: f32,
    axis_y: f32,
}

Position :: rl.Vector2
