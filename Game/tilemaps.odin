package game

import rl "vendor:raylib"

TilemapData :: struct {
    texture_path: cstring,
    bitmap: map[byte]rl.Vector2,
    bit_tiles: []byte,
    width, height: int,
}

AutoTilingSetup :: proc(tilemap: ^TilemapData) {
    dpos: [8][2]i8 = {
        {-1, -1}, {0, -1}, {1, -1},
        {-1, 0}, {1, 0},
        {-1, 1}, {0, 1}, {1, 1},
    }

    for y := 0; y < tilemap.height; y += 1 {
        for x := 0; x < tilemap.width; x += 1 {
            index := y * tilemap.width + x

            bit_tile := tilemap.bit_tiles[index]
            if bit_tile < 0 do continue

            bitmask: byte
            for dp, di in dpos {
                nx := x + int(dp.x)
                ny := y + int(dp.y)

                if nx < 0 || nx > tilemap.width || ny < 0 || ny > tilemap.height do continue;

                bit := tilemap.bit_tiles[ny * tilemap.width + nx]
                bitmask += bit * (1 << u8(di))
            }
            // TODO: Bitmask check
        }
    }

}
