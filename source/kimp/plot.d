/**
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 7 Jul 2021
 */
module kimp.plot;

/** Import gtk widgets */
import gtk.Overlay, gtk.ScrolledWindow, gtk.DrawingArea, gtk.Label;

/** Import cairo lib */
import cairo.Context : Context;

/** Import signal class */
import kimp.signal : Signal, FRAMERATE;

/** Import standart functions */
import std.algorithm : min, max;
import std.math.rounding : ceil;
import std.conv : to;

/** 
 * Class for signal displaing
 */
class Plot : Overlay {
    /** 
     * Create new plot
     * Params:
     *   name = Plot's name
     *   x = Name for X axis
     *   y = Name for Y axis
     */
    public this (string name, string x, string y) { super();
        composeWidget(name);

        xName = x; yName = y;
        plotSignal = null;
        duration = 0.0;
    }

    /** 
     * Create Plot's widget struct
     * Params:
     *   name = Plot's name
     */
    private void composeWidget (string name) {
        plotArea = new DrawingArea();
        ScrolledWindow plotScrolledWindow = new ScrolledWindow();
        Label plotName = new Label("<span size='small' foreground='#000000'>" ~ name ~ "</span>");

        plotScrolledWindow.setChild(plotArea);
        setChild(plotScrolledWindow);
        addOverlay(plotName);
        
        plotName.setUseMarkup(true);
        plotName.setProperty("margin-end", 5);
        plotName.setProperty("margin-top", 5);
        plotName.setProperty("halign", GtkAlign.END);
        plotName.setProperty("valign", GtkAlign.START);

        plotArea.setDrawFunc ((area, cairo, w, h, data) {
            (cast(Plot)data).requestSize ();
            (cast(Plot)data).plotOnDraw (new Context (cairo), cast(ulong)w, cast(ulong)h);
        }, cast(void *)this, null);
    }

    /** 
     * Request required for signal size
     */
    private void requestSize () {
        plotArea.setSizeRequest (0, 0);
        plotArea.setSizeRequest (-1, -1);
        plotArea.setSizeRequest (60 + cast(int)plotSignal.calculateSignalWidth (duration), -1);
    }

    /** 
     * Set signal for display
     * Params:
     *   signal = New signal for drawing
     *   dur = Duration of the signal
     */
    public void setSignal (Signal signal, double dur) {
        plotSignal = signal; duration = dur;
    }

    /** 
     * Redraw the plot
     */
    public void drawRequest () {
        requestSize ();
        plotArea.queueDraw ();
    }

    /** 
     * Draw the plot
     * Params:
     *   context = Cairo context for actual drawing
     *   w = width of the drawing area
     *   h = height of the drawing area
     */
    private void plotOnDraw (Context context, ulong w, ulong h) {
        plotDrawBackground (context);

        ulong xHeight = h - 15;
        ulong yAmp = h - 45;

        if (plotSignal !is null) {
            double [] ys = plotSignal.createYS (duration);
            
            for (ulong i = 0; i < min (ys.length, FRAMERATE); i += 100) {
                if (ys[i] < 0) {
                    yAmp = (h - 90) / 2;
                    xHeight = h / 2;
                }
            }

            double step = (w - 60) / (FRAMERATE * ceil (duration));
            double current_point = 15.0;

            context.setSourceRgba (0.0, 1.0, 0.0, 1.0);
            context.setLineWidth (0.75);

            context.moveTo (current_point, xHeight);

            foreach (double point; ys) {
                context.lineTo (current_point, xHeight - yAmp * point);
                current_point += step;
            }

            context.stroke();
            ys.destroy ();
        }

        plotDrawXAxis (context, w, xHeight);
        plotDrawYAxis (context, h);

        plotMakeXAxisMarkup (context, w, xHeight);
        plotMakeYAxisMarkup (context, xHeight, yAmp);

        plotMakeAxesText (context, w, h, xHeight);
    }

    /** 
     * Draw the background of the plot
     * Params:
     *   context = Cairo context for actual drawing
     */
    private void plotDrawBackground (Context context) {
        context.setSourceRgba (1.0, 1.0, 1.0, 1.0);
        context.paint();
    }

    /** 
     * Draw Y axis of the plot
     * Params:
     *   context = Cairo context for drawing
     *   height = Height of the drawing area
     */
    private void plotDrawYAxis (Context context, ulong height) {
        context.setSourceRgba (0.0, 0.0, 0.0, 1.0);
        context.setLineWidth (2.0);       

        context.moveTo (15, height - 5);
        context.relLineTo (0, 15 - cast(int)height);
        context.stroke();

        context.moveTo (15, 10);
        context.relLineTo (1.5, 5);
        context.relLineTo (-3, 0);
        context.closePath();
        context.stroke();
    }

    /** 
     * Draw X axis of the plot
     * Params:
     *   context = Cairo context for drawing
     *   width = Width of the drawing area
     *   axisHeight = Height of the X axis
     */
    private void plotDrawXAxis (Context context, ulong width, ulong axisHeight) {
        context.setSourceRgba (0.0, 0.0, 0.0, 1.0);
        context.setLineWidth (2.0);       

        context.moveTo (5, axisHeight);
        context.relLineTo (width - 15, 0);
        context.stroke();

        context.moveTo (width - 10, axisHeight);
        context.relLineTo (-5, 1.5);
        context.relLineTo (0, -3);
        context.closePath();
        context.stroke();
    }

    /** 
     * Create Y axis's markup
     * Params:
     *   context = Cairo context for drawing
     *   height = Height of the X axis
     *   amp = Amplitude of Y values
     */
    private void plotMakeYAxisMarkup (Context context, ulong height, ulong amp) {
        context.setSourceRgba (0.0, 0.0, 0.0, 1.0);
        context.setLineWidth (2.0);
        context.setFontSize (12.0);

        context.moveTo (12.5, height - amp);
        context.relLineTo (5, 0);
        context.stroke();

        context.moveTo (2, height - amp + 2.5);
        context.showText (" 1");

        context.moveTo (12.5, height + amp);
        context.relLineTo (5, 0);
        context.stroke();

        context.moveTo (2, height + amp + 2.5);
        context.showText ("-1");
    }

    /** 
     * Create X axis's markup
     * Params:
     *   context = Cairo context for drawing
     *   width = Width of the drawing area
     *   height = Height of the X axis
     */
    private void plotMakeXAxisMarkup (Context context, ulong width, ulong height) {
        context.setSourceRgba (0.0, 0.0, 0.0, 1.0);
        context.setLineWidth (2.0);
        context.setFontSize (10.0);

        double step = (width - 60) / max (1, ceil (duration));

        for (ulong i = 0; i < max (1, ceil (duration)); i++) {
            context.moveTo (15 + step * (i + 1), height - 2.5);
            context.relLineTo (0, 5);
            context.stroke ();

            context.moveTo (15 + step * (i + 1) - 2.5, height + 12.5);
            context.showText (to!string (i + 1));
        }
    }

    /** 
     * Make incriptions on the plot
     * Params:
     *   context = Cairo context for drawing
     *   w = Width of the drawing area
     *   h = Height of the drawing area
     *   x = Height of the X axis
     */
    private void plotMakeAxesText (Context context, ulong w, ulong h, ulong x) {
        context.setSourceRgba (0.0, 0.0, 0.0, 1.0);
        context.setFontSize (8.0);

        context.moveTo (w - xName.length * 3, x + 10);
        context.showText (xName);

        context.rotate (-PI_2);
        context.moveTo (cast(int)yName.length * 8 * (-1), 10);
        context.showText (yName);
        context.rotate (PI_2);
    }

    /** Private plot's names for axes */
    protected string xName, yName;

    /** Signal for drawing */
    protected Signal plotSignal;

    /** Signal's duration */
    protected double duration;

    /** Drawing area for plot */
    private DrawingArea plotArea;
}
