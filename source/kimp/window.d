/**
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 7 Jul 2021
 */
module kimp.window;

/** Import GtkD widgets */
import gtk.Window, gtk.Box, gtk.EditableIF, gtk.Entry, gtk.SpinButton;

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

        initPlots (uiBuilder);
        connectSignals (uiBuilder);

        localBuilder = uiBuilder;
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

    /** 
     * Connect signal handlers
     * Params:
     *   uiBuilder = Builder for getting objects
     */
    private void connectSignals (ref Builder uiBuilder) {
        (cast(EditableIF)uiBuilder.getObject("bits_en")).addOnChanged(&onBitsChanged);

        (cast(SpinButton)uiBuilder.getObject("info_spin")).addOnValueChanged( (spin) {updatePlots ();});
        (cast(SpinButton)uiBuilder.getObject("snr_spin")).addOnValueChanged( (spin) {updatePlots ();});
        (cast(SpinButton)uiBuilder.getObject("freq_spin")).addOnValueChanged( (spin) {updatePlots ();});
    }

    /** 
     * Update plot's properties
     */
    private void updatePlots () {
        string bits = (cast(Entry)localBuilder.getObject ("bits_en")).getText ();

        double info = (cast(SpinButton)localBuilder.getObject ("info_spin")).getValue ();
        double snr = (cast(SpinButton)localBuilder.getObject ("snr_spin")).getValue ();
        double freq = (cast(SpinButton)localBuilder.getObject ("freq_spin")).getValue ();
    
        video_plot.setSignal (new VideoPulse (bits, info), bits.length / info);

        video_plot.drawRequest ();
    }

    /** 
     * Allows to enter just '1' and '0' to the bits
     * Params:
     *   en = Editable of bits entry
     */
    protected void onBitsChanged (EditableIF en) {
        string inputSym = en.getChars (en.getPosition (), en.getPosition () + 1);
        
        if (inputSym.length) {
            if(inputSym[0] != '0' && inputSym[0] != '1') {
                string correctOut = en.getChars (0, en.getPosition ()) ~ en.getChars (en.getPosition () + 1, -1);

                en.deleteText (0, -1); int zero = 0;
                en.insertText (correctOut, cast(int)correctOut.length, zero);
            }
        }

        updatePlots ();
    }

    /** Local builder for getting ui elements */
    private Builder localBuilder;

    /** Plots for display */
    private Plot video_plot;
}
