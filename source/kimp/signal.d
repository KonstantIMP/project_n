/**
 * Author: KonstantIMP <mihedovkos@gmail.com>
 * Date: 7 Jul 2021
 */
module kimp.signal;

import std.exception;

import std.math.trigonometry : sin, cos;
import std.math.rounding : round;
import std.math.constants : PI;

import std.algorithm : min;

import kimp.modulation : ModulationType;

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
    public this (string bitSequence, double informativeness) {
        bits = bitSequence; inf = informativeness;
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
        return min(bits.length * 5, 16_384);
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
        return min((cast(ulong)round(duration) + 1) * 30, 16_383);
    }

    /** Private sin parametrs */
    protected double frequency, amplitude, offset;
}

/** 
 * Signal with modulated radio data
 */
class RadioSignal : SinSignal {
    /** 
     * Create new Singal's object
     * Params:
     *   bitSequence = Bit sequnce for display
     *   freq = Frequency of the base signal
     *   inf = Informativeness of the signal
     *   mod = Modulation type for data
     */
    public this (string bitSequence, double freq, double inf, ModulationType mod) {
        bits = bitSequence; informativeness = inf; modulation = mod;
        super (freq, 1.0, 0.0);
    }

    override public double [] createYS (double duration) {
        double [] ys = new double[bits.length * cast(ulong)(FRAMERATE / informativeness)];

        if (ys.length < bits.length * 30) {
            informativeness = informativeness / 2; frequency = frequency / 2;
            ys.destroy();
            return createYS (duration);
        }

        int currentPhase = 1;
        if (bits.length) if (bits[0] == '0') currentPhase = -1;

        for (ulong i = 0; i < bits.length; i++) {
            if(i) if (bits[i] != bits[i - 1]) currentPhase = -currentPhase;
            for (ulong j = 0; j < ys.length / bits.length; j++) {
                if (modulation == ModulationType.PHASE)
                    ys [i * (ys.length / bits.length) + j] = sin(PI * 2 * frequency * (i * (ys.length / bits.length) + j) / FRAMERATE) * currentPhase;
                else
                    ys [i * (ys.length / bits.length) + j] = sin(PI * (bits[i] == '1' ? 2 : 1) * frequency * (i * (ys.length / bits.length) + j) / FRAMERATE);
            }
        }

        if (ys.length) ys[$ - 1] = 0;

        return ys;
    }

    override public ulong calculateSignalWidth (double duration) {
        return min(bits.length * 60, 16_384);
    }

    /** Bit sequnece for display */
    private string bits;
    /** Informativeness of the signal */
    private double informativeness;
    /** Modulation type for the signal */
    private ModulationType modulation;
}
