package ecs

import "core:fmt"
import "core:testing"
import "core:mem"

Entity :: distinct uint
Component_ID :: distinct uint

Entity_Info :: struct{
    tag: string,
    component_ids: [dynamic]Component_ID,
}

Component_Info :: struct {
    type: typeid,
    size: int, 
}

Component :: struct {
    info: Component_Info,
    entity: Entity,
}

Scene :: struct {
    next_entity: Entity,
    next_component: Component_ID,

    entities: map[Entity]Entity_Info,

    component_ids: map[typeid]Component_ID,
    components: map[Component_ID]Component_Info,

    registry: map[Component_ID][dynamic]byte,
}

find_or_add_component_info :: proc(scene: ^Scene, type: typeid) -> (Component_ID, Component_Info) {
    comp_id, ok := scene.component_ids[type]
    if (ok) do return comp_id, scene.components[comp_id]

    new_component := Component_Info{
        type = type,
        size = size_of(type)
    }

    new_id := scene.next_component

    scene.components[new_id] = new_component
    scene.component_ids[type] = new_id

    scene.next_component += 1

    return new_id, new_component
}

add_component :: proc(scene: ^Scene, entity: Entity, component: $T) {
    comp_id, comp_info := find_or_add_component_info(scene, T)

    ent_info := scene.entities[entity]
    for id in ent_info.components {
        if id == comp_id do return
    }

    component_row := &scene.registry[info.id]
    offset := len(component_row^)
    resize(component_row, offset + comp_info.size)
    mem.copy(component_row^[offset], &component, comp_info.size)
}

@(test)
_test_component :: proc(t: ^testing.T) {
    Position :: struct { x,y: int }
    pos_size := size_of(Position)

    pos1 := Position{4, 5}
    pos2 := Position{3, 4}
    pos3 := Position{6, 3}
    
    pos_data: [dynamic]byte
    defer delete(pos_data)
    resize(&pos_data, 3*pos_size)

    mem.copy(&pos_data[0], &pos1, pos_size)
    mem.copy(&pos_data[pos_size], &pos2, pos_size)
    mem.copy(&pos_data[2*pos_size], &pos3, pos_size)

    pos_slice := (cast(^[dynamic]Position)(&pos_data))[:3]

    for pos in pos_slice {
        fmt.println(pos, typeid_of(Position))
    }
}
