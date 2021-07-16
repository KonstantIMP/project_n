/**
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 7 Jul 2021
 */
module kimp.window;

/** Import GtkD widgets */
import gtk.Window, gtk.Box, gtk.EditableIF, gtk.Entry, gtk.SpinButton, gtk.ComboBox, gtk.Button;

/** Import GtkD tools */
import gtk.Builder : Builder;

/** Import ploting lib and signals */
import kimp.plot, kimp.signal, kimp.modulation;

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
        videoPlot = new Plot("Видеоимпульс", "t (сек)", "A");
        videoPlot.setSignal (new VideoPulse ("", 50), 0.0);

        radioPlot = new Plot("Радиосигнал", "t (сек.)", "A");
        radioPlot.setSignal (new RadioPulse ("", 100, 50, ModulationType.FREQUENCY), 0.0);

        noisePlot = new Plot("Полученный сигнал", "t (сек.)", "A");
        noisePlot.setSignal (new NoisedRadioPulse ("", 100, 50, 25, ModulationType.FREQUENCY), 0.0);

        (cast(Box)uiBuilder.getObject("plot_box")).append(videoPlot);
        (cast(Box)uiBuilder.getObject("plot_box")).append(radioPlot);
        (cast(Box)uiBuilder.getObject("plot_box")).append(noisePlot);
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

        (cast(ComboBox)uiBuilder.getObject("mod_cb")).addOnChanged( (spin) {updatePlots ();});

        (cast(Button)uiBuilder.getObject("regen_btn")).addOnClicked ( (btn) {updatePlots ();});
    }

    /** 
     * Update plot's properties
     */
    private void updatePlots () {
        string bits = (cast(Entry)localBuilder.getObject ("bits_en")).getText ();

        double info = (cast(SpinButton)localBuilder.getObject ("info_spin")).getValue ();
        double snr = (cast(SpinButton)localBuilder.getObject ("snr_spin")).getValue ();
        double freq = (cast(SpinButton)localBuilder.getObject ("freq_spin")).getValue ();
    
        ModulationType mod = cast(ModulationType)(cast(ComboBox)localBuilder.getObject ("mod_cb")).getActive ();

        videoPlot.setSignal (new VideoPulse (bits, info), bits.length / info);
        radioPlot.setSignal (new RadioPulse (bits, freq, info, mod), bits.length / info);
        noisePlot.setSignal (new NoisedRadioPulse (bits, freq, info, snr, mod), bits.length / info);

        videoPlot.drawRequest ();
        radioPlot.drawRequest ();
        noisePlot.drawRequest ();
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
    private Plot videoPlot;
    private Plot radioPlot;
    private Plot noisePlot;
}
