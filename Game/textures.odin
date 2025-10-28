package game

import "core:fmt"
import "core:os"
import rl "vendor:raylib"

TextureManager :: struct{
    textures: map[cstring]rl.Texture2D
}

LoadTexture :: proc(tm: ^TextureManager, path: cstring) -> (rl.Texture2D, bool) {
    if !(path in tm.textures) do tm.textures[path] = rl.LoadTexture(path)
    return tm.textures[path], rl.IsTextureValid(tm.textures[path])
}

UnloadTexture :: proc(tm: ^TextureManager, path: cstring) {
    if path in tm.textures { 
        rl.UnloadTexture(tm.textures[path])
        delete_key(&tm.textures, path)
    }
}

UnloadAllTextures :: proc(tm: ^TextureManager) {
    for path, _ in tm.textures do UnloadTexture(tm, path)
}

GetTexture :: proc(tm: ^TextureManager, path: cstring) -> (rl.Texture2D, bool) {
    return tm.textures[path]
}
