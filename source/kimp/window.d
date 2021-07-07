/**
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 7 Jul 2021
 */
module kimp.window;

/** Import GtkD widgets */
import gtk.Window;

/** Import GtkD tools */
import gtk.Builder;

/**
 * Main apps' window
 */
class MainWindow : Window {
    /** 
     * Create the window and prepare it for work
     * Params:
     *   uiBuilder = Builder object for UI getting
     */
    public this (ref Builder uiBuilder) {
        super ((cast(Window)uiBuilder.getObject ("main_win")).getWindowStruct ());
        show ();
    }
}
