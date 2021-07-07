/**
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 7 Jul 2021
 */
module kimp.signal;

import std.exception;

import std.math.trigonometry : sin, cos;
import std.math.rounding : round;
import std.math.constants : PI;

/** Default framerate for signal */
immutable ulong FRAMERATE = 11_025;

/** 
 * Excpetion class for signal errors
 */
class SignalException : Exception {
    /** 
     * Throw new Exception with error message
     * Params:
     *   err = Error message for exception
     */
    public this (string err) {
        super(err);
    }
}

/**
 * Base class for signal representation
 */
abstract class Signal {
    /** 
     * Create array with point's coordinates for display
     * Params:
     *   duration = Signal's duration in seconds
     * Returns: Array with points
     */
    public double [] createYS (double duration);

    /** 
     * Calculate width for signal display
     * Params:
     *   duration = Signal's duration in seconds
     * Returns: Prefered width for plot
     */
    public ulong calculateSignalWidth (double duration);
}

/** 
 * Sinusoidal signal
 */
class SinSignal : Signal {
    /** 
     * Create new sinusoidal signal
     * Params:
     *   freq = Frequency of the signal (Hz)
     *   amp = Amplitude of the signal
     *   off = Offset of the signal
     * Throws: SignalException if was given incorrect params
     */
    public this (double freq, double amp = 1.0, double off = 0.0) {
        if (freq < 0.0) throw new SignalException("Frequency could not be less then 0");
        frequency = freq; amplitude = amp; offset = off;
    }

    override public double [] createYS (double duration) {
        double [] ys = new double[cast(ulong)(duration * FRAMERATE)];

        for (ulong i = 0; i < ys.length; i++)
            ys[i] = amplitude * sin (PI * 2 * frequency * i / FRAMERATE + offset);

        return ys;
    }

    override public ulong calculateSignalWidth (double duration) {
        return (cast(ulong)round(duration) + 1) * 30;
    }

    /** Private sin parametrs */
    protected double frequency, amplitude, offset;
}
