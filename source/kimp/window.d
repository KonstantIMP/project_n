/**
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 7 Jul 2021
 */
module kimp.window;

/** Import GtkD widgets */
import gtk.Window, gtk.Box;

/** Import GtkD tools */
import gtk.Builder : Builder;

/** Import ploting lib and signals */
import kimp.plot, kimp.signal;

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

        initPlots(uiBuilder);

        show ();
    }

    /** 
     * Init plots and put it into the window
     * Params:
     *   uiBuilder = Builder for getting ui elements
     */
    private void initPlots (ref Builder uiBuilder) {
        video_plot = new Plot("Видеоимпульс", "t (сек)", "A");
        video_plot.setSignal (new VideoPulse ("", 50), 0.0);

        (cast(Box)uiBuilder.getObject("plot_box")).append(video_plot);
    }

    private Plot video_plot;
}
