package game

import rl "vendor:raylib"
import "core:fmt"

TilemapData :: struct {
    name: Name,
    texture_path: cstring,
    bitmap: map[byte]rl.Vector2,
    bit_tiles: []byte,
    width, height: int,
}

AutoTilingSetup :: proc(data: ^TilemapData) -> (tilemap: Tilemap) {
    dpos: [8][2]int = {
        {-1, -1}, {0, -1}, {1, -1},
        {-1, 0}, {1, 0},
        {-1, 1}, {0, 1}, {1, 1},
    }

    positions := make([dynamic]rl.Vector2, 0)
    tiles := make([dynamic]rl.Vector2, 0)
    for y := 0; y < data.height; y += 1 {
        for x := 0; x < data.width; x += 1 {
            index := (y * data.width) + x

            bit_tile := data.bit_tiles[index]
            if bit_tile == 0 do continue

            bitmask: byte
            for dp, di in dpos {
                nx := x + int(dp.x)
                ny := y + int(dp.y)

                if nx < 0 || nx >= data.width || ny < 0 || ny >= data.height do continue;

                bit := data.bit_tiles[(ny * data.width) + nx]
                bitmask |= bit * (1 << u8(di))
            }
            
            append(&tiles, data.bitmap[bitmask])
            append(&positions, rl.Vector2{f32(x), f32(y)})
        }
    }

    tilemap.positions = positions[:]
    tilemap.tiles = tiles[:]
    tilemap.size = len(tiles)

    return tilemap
}
