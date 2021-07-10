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
        test_plot = new Plot("Woof!", "t", "amp");
        test_plot.setSignal (new SinSignal (1), 50);

        (cast(Box)uiBuilder.getObject("plot_box")).append(test_plot);
    }

    private Plot test_plot;
}
