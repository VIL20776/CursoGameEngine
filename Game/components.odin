package game

import rl "vendor:raylib"

Name :: string

Texture :: struct {
    data: rl.Texture2D,
    path: cstring
}

IntGrid :: struct {
    grid: []byte,
    width, height: int
}

Tilemap :: struct {
    positions: []rl.Vector2,
    tiles: []rl.Vector2,
    draw_size, tile_size: f32,
    size: int
}

Animation :: struct {
    start: rl.Vector2,
    size: rl.Vector2,
    offset: int,
    frames: int,
    time: f64,
    nextTime: f64
}

Movement :: struct {
    speed: f32,
    axis_x: f32,
    axis_y: f32,
}

Collider :: struct {
    collision_box: rl.Rectangle,
    offset: rl.Vector2,
    collision: bool
}

Camera :: rl.Camera2D

Position :: rl.Vector2


