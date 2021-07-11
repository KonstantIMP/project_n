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
 * Video pulse signal (1 or 0)
 */
class VideoPulse : Signal {
    /** 
     * Create new VideoPulse signal
     * Params:
     *   bitSequnce = Bit sequence for display
     *   informativeness = informativeness of the signal
     */
    public this (string bitSequnce, double informativeness) {
        bits = bitSequnce; inf = informativeness;
    }

    override public double [] createYS (double duration) {
        if (bits.length == 0 || duration <= 0.0) return new double[0];

        double [] ys = new double[bits.length * cast(ulong)(FRAMERATE / inf)];

        /** Zero check */
        if (ys.length / bits.length < 3) {
            inf = inf / 2; ys.destroy();
            return createYS (duration);
        }

        for (ulong i = 0; i < bits.length; i++) {
            double state = (bits[i] == '0' ? 0.0 : 1.0);
            for (ulong j = 0; j < ys.length / bits.length; j++) {
                ys[j + i * ys.length / bits.length] = state;
            }
        }

        if (ys.length) ys[$ - 1] = 0.0;

        return ys;
    }

    override public ulong calculateSignalWidth (double duration) {
        return bits.length * 15;
    }

    /** Bit sequence for display */
    protected string bits;
    /** Informativeness of the signal */
    protected double inf;
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
