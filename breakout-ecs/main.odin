package breakout

import "core:fmt"
import "core:thread"

ctx: Game
gui: GUI

main :: proc() {

  Init(&ctx, "breakout", 800, 600)
  defer Deinit(&ctx)

  Setup(&ctx)
  InitGUI(&gui)
  //p := thread.create_and_start_with_data(&ctx, procGUI)

  fmt.println("Starting game")
  for Running(&ctx) {
    HandleEvents(&ctx)
    Update(&ctx, &gui)
    Render(&ctx, &gui)
  }

  Clean(&ctx)
}
