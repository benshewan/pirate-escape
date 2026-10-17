use bevy::prelude::*;

fn main() {
    // Nicer panic messages in the browser console (no-op on native).
    #[cfg(target_arch = "wasm32")]
    console_error_panic_hook::set_once();

    App::new().add_plugins(DefaultPlugins).run();
}
