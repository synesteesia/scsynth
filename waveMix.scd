s.boot;

(
Ndef(\waveformSynth, {
    arg freq = 220,
    sineMix = 0.5,
    sawMix = 0.5,
    triMix = 0.5,
    pulseMix = 0.5,
    pulseWidth = 0.5,
    noiseMix = 0.0,
    amp = 0.1,
    filterCutoff = 2150,
    filterResonance = 0.68,
    filterLFOSpeed = 5.0,
    filterLFODepth = 0,
    chorusOn = 0,
    chorusSpeed = 0.1,
    chorusDepth = 0.01,
    envAttack = 0.01,
    envDecay = 0.5,
    envSustain = 0.5,
    envRelease = 0.51,
    filterEnvAttack = 0.04,
    filterEnvDecay = 0.08,
    filterEnvSustain = 2.73,
    filterEnvRelease = 0.21,
    filterEnvAmount = 0;

    var sine, saw, tri, noise, pulse, mix, chorus, filtered, lfo, env, gate, filterEnv, filterFreq;

    // Generate a gate that toggles on and off every second
    gate = LFPulse.kr(1, 0, 0.5);

    // Generate the envelope for the amplitude
    env = EnvGen.kr(Env.adsr(envAttack, envDecay, envSustain, envRelease), gate, doneAction: 2);

    // Generate the envelope for the filter
    filterEnv = EnvGen.kr(Env.adsr(filterEnvAttack, filterEnvDecay, filterEnvSustain, filterEnvRelease), gate);

    // Generate different waveforms
    sine = SinOsc.ar(freq);
    saw = Saw.ar(freq);
    tri = LFTri.ar(freq);
    pulse = Pulse.ar(freq, pulseWidth);
    noise = WhiteNoise.ar;

    // Mix the waveforms
    mix = (sine * sineMix) + (saw * sawMix) + (pulse * pulseMix) + (tri * triMix) + (noise * noiseMix);

    // Normalize the mix to avoid clipping
    mix = mix * (amp / (sineMix + sawMix + pulseMix + triMix + noiseMix).max(1));

    // Apply LFO to filter cutoff
    lfo = SinOsc.kr(filterLFOSpeed, 0, filterLFODepth, filterCutoff);

    // Combine LFO and envelope for filter cutoff
    filterFreq = lfo + (filterEnv * filterEnvAmount);

    // Apply Moog filter with LFO and envelope modulation
    filtered = MoogFF.ar(mix, filterFreq, filterResonance);

    // Apply the envelope to the filtered signal
    filtered = filtered * env;

    // Apply chorus effect if enabled
    chorus = Select.ar(chorusOn, [
        filtered,
        filtered + DelayC.ar(filtered, 0.03, SinOsc.kr(chorusSpeed, 0, chorusDepth, 0.03))
    ]);

    // Output the mixed signal with or without chorus
    chorus ! 2; // Stereo output
});

// Add control specs for GUI
Spec.add(\amp, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.1));
Spec.add(\freq, ControlSpec(minval: 20, maxval: 20000, warp: \exp, step: 1, default: 220));
Spec.add(\sineMix, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.5));
Spec.add(\sawMix, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.5));
Spec.add(\triMix, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.5));
Spec.add(\pulseMix, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.5));
Spec.add(\pulseWidth, ControlSpec(minval: 0.01, maxval: 0.99, warp: \lin, step: 0.01, default: 0.5));
Spec.add(\noiseMix, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.0));
Spec.add(\filterCutoff, ControlSpec(minval: 20, maxval: 20000, warp: \exp, step: 1, default: 2150));
Spec.add(\filterResonance, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.68));
Spec.add(\filterLFOSpeed, ControlSpec(minval: 0.1, maxval: 20, warp: \lin, step: 0.1, default: 5.0));
Spec.add(\filterLFODepth, ControlSpec(minval: 0, maxval: 4000, warp: \lin, step: 1, default: 0));
Spec.add(\chorusOn, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 1, default: 0));
Spec.add(\chorusSpeed, ControlSpec(minval: 0.1, maxval: 10, warp: \lin, step: 0.1, default: 0.1));
Spec.add(\chorusDepth, ControlSpec(minval: 0, maxval: 0.015, warp: \lin, step: 0.001, default: 0.01));
Spec.add(\envAttack, ControlSpec(minval: 0.001, maxval: 2, warp: \lin, step: 0.001, default: 0.01));
Spec.add(\envDecay, ControlSpec(minval: 0.001, maxval: 2, warp: \lin, step: 0.001, default: 0.5));
Spec.add(\envSustain, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.5));
Spec.add(\envRelease, ControlSpec(minval: 0.51, maxval: 5, warp: \lin, step: 0.001, default: 0.51));
Spec.add(\filterEnvAttack, ControlSpec(minval: 0.001, maxval: 2, warp: \lin, step: 0.001, default: 0.04));
Spec.add(\filterEnvDecay, ControlSpec(minval: 0.001, maxval: 2, warp: \lin, step: 0.001, default: 0.08));
Spec.add(\filterEnvSustain, ControlSpec(minval: 0, maxval: 5, warp: \lin, step: 0.01, default: 2.73));
Spec.add(\filterEnvRelease, ControlSpec(minval: 0.001, maxval: 2, warp: \lin, step: 0.001, default: 0.21));
Spec.add(\filterEnvAmount, ControlSpec(minval: 0, maxval: 4000, warp: \lin, step: 1, default: 0));

// Add GUI for controlling the parameters
(
Ndef(\waveformSynth).gui;
)
)


Ndef(\waveformSynth).clear;
s.quit;



// Control the parameters dynamically
Ndef(\waveformSynth).set(\freq, 880);        // Change frequency to 880 Hz
Ndef(\waveformSynth).set(\sineMix, 0.7);     // Increase sine mix
Ndef(\waveformSynth).set(\sawMix, 0.2);      // Decrease saw mix
Ndef(\waveformSynth).set(\pulseMix, 0.1);    // Decrease pulse mix
Ndef(\waveformSynth).set(\pulseWidth, 0.3);  // Change pulse width
Ndef(\waveformSynth).set(\amp, 0.2);         // Increase amplitude


//version with 2 voices
(
Ndef(\DuoWave, {
    arg freq1 = 220,
        freq2 = 440,
        sineMix = 0.5,
        sawMix = 0.5,
        triMix = 0.5,
        pulseMix = 0.5,
        pulseWidth = 0.5,
        noiseMix = 0.0,
        amp = 0.1,
        amp2 = 0.0,
        filterCutoff = 2150,
        filterResonance = 0.68,
        filterLFOSpeed = 5.0,
        filterLFODepth = 0,
        chorusOn = 0,
        chorusSpeed = 0.1,
        chorusDepth = 0.01,
        envAttack = 0.04,
        envDecay = 0.5,
        envSustain = 0.5,
        envRelease = 0.51,
        filterEnvAttack = 0.04,
        filterEnvDecay = 0.08,
        filterEnvSustain = 2.73,
        filterEnvRelease = 0.21,
        filterEnvAmount = 0;

    var sine1, saw1, tri1, noise1, pulse1, mix1, filtered1;
    var sine2, saw2, tri2, noise2, pulse2, mix2, filtered2;
    var lfo, env, gate, filterEnv, filterFreq, chorus, output;

    // Generate a single gate that toggles on and off every second
    gate = LFPulse.kr(1, 0, 0.5);

    // Generate the envelope for both voices
    env = EnvGen.kr(Env.adsr(envAttack, envDecay, envSustain, envRelease), gate, doneAction: 2);

    // Generate the envelope for the filter, this is used for the autofilter effect
    filterEnv = EnvGen.kr(Env.adsr(filterEnvAttack, filterEnvDecay, filterEnvSustain, filterEnvRelease), gate);

    // Generate different waveforms for voice 1
    sine1 = SinOsc.ar(freq1);
    saw1 = Saw.ar(freq1);
    tri1 = LFTri.ar(freq1);
    pulse1 = Pulse.ar(freq1, pulseWidth);
    noise1 = WhiteNoise.ar;

    // Generate different waveforms for voice 2
    sine2 = SinOsc.ar(freq2);
    saw2 = Saw.ar(freq2);
    tri2 = LFTri.ar(freq2);
    pulse2 = Pulse.ar(freq2, pulseWidth);
    noise2 = WhiteNoise.ar;

	// Mix the waveforms for voice 1 (and normalize to avoid clipping)
    mix1 = (sine1 * sineMix) + (saw1 * sawMix) + (pulse1 * pulseMix) + (tri1 * triMix) + (noise1 * noiseMix);
    mix1 = mix1 * (amp / (sineMix + sawMix + pulseMix + triMix + noiseMix).max(1));

    // Mix the waveforms for voice 2
    mix2 = (sine2 * sineMix) + (saw2 * sawMix) + (pulse2 * pulseMix) + (tri2 * triMix) + (noise2 * noiseMix);
    mix2 = mix2 * (amp2 / (sineMix + sawMix + pulseMix + triMix + noiseMix).max(1));

    // Apply LFO to filter cutoff
    lfo = SinOsc.kr(filterLFOSpeed, 0, filterLFODepth, filterCutoff);

    // Combine LFO and envelope for filter cutoff - LFO has the cutoff basic cutoff, the rest is autofilter
    filterFreq = lfo + (filterEnv * filterEnvAmount);

    // Apply Moog filter with LFO and envelope modulation for voice 1
    filtered1 = MoogFF.ar(mix1, filterFreq, filterResonance);
    filtered1 = filtered1 * env;

    // Apply Moog filter with LFO and envelope modulation for voice 2
    filtered2 = MoogFF.ar(mix2, filterFreq, filterResonance);
    filtered2 = filtered2 * env;

    // Combine the two voices and apply chorus effect if enabled
    output = (filtered1 + filtered2) * 0.5;
    chorus = Select.ar(chorusOn, [
        output,
        output + DelayC.ar(output, 0.03, SinOsc.kr(chorusSpeed, 0, chorusDepth, 0.03))
    ]);

    // Output the mixed signal with or without chorus
    chorus ! 2; // Stereo output
});

// Add control specs for GUI
Spec.add(\amp, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.1));
Spec.add(\amp2, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.0));
Spec.add(\freq1, ControlSpec(minval: 20, maxval: 20000, warp: \exp, step: 1, default: 220));
Spec.add(\freq2, ControlSpec(minval: 20, maxval: 20000, warp: \exp, step: 1, default: 440));
Spec.add(\sineMix, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.5));
Spec.add(\sawMix, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.5));
Spec.add(\triMix, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.5));
Spec.add(\pulseMix, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.5));
Spec.add(\pulseWidth, ControlSpec(minval: 0.01, maxval: 0.99, warp: \lin, step: 0.01, default: 0.5));
Spec.add(\noiseMix, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.0));
Spec.add(\filterCutoff, ControlSpec(minval: 20, maxval: 20000, warp: \exp, step: 1, default: 2150));
Spec.add(\filterResonance, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.68));
Spec.add(\filterLFOSpeed, ControlSpec(minval: 0.1, maxval: 20, warp: \lin, step: 0.1, default: 5.0));
Spec.add(\filterLFODepth, ControlSpec(minval: 0, maxval: 4000, warp: \lin, step: 1, default: 0));
Spec.add(\chorusOn, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 1, default: 0));
Spec.add(\chorusSpeed, ControlSpec(minval: 0.1, maxval: 10, warp: \lin, step: 0.1, default: 0.1));
Spec.add(\chorusDepth, ControlSpec(minval: 0, maxval: 0.015, warp: \lin, step: 0.001, default: 0.01));
Spec.add(\envAttack, ControlSpec(minval: 0.001, maxval: 2, warp: \lin, step: 0.001, default: 0.04));
Spec.add(\envDecay, ControlSpec(minval: 0.001, maxval: 2, warp: \lin, step: 0.001, default: 0.5));
Spec.add(\envSustain, ControlSpec(minval: 0, maxval: 1, warp: \lin, step: 0.01, default: 0.5));
Spec.add(\envRelease, ControlSpec(minval: 0.51, maxval: 5, warp: \lin, step: 0.001, default: 0.51));
Spec.add(\filterEnvAttack, ControlSpec(minval: 0.001, maxval: 2, warp: \lin, step: 0.001, default: 0.04));
Spec.add(\filterEnvDecay, ControlSpec(minval: 0.001, maxval: 2, warp: \lin, step: 0.001, default: 0.08));
Spec.add(\filterEnvSustain, ControlSpec(minval: 0, maxval: 5, warp: \lin, step: 0.01, default: 2.73));
Spec.add(\filterEnvRelease, ControlSpec(minval: 0.001, maxval: 2, warp: \lin, step: 0.001, default: 0.21));
Spec.add(\filterEnvAmount, ControlSpec(minval: 0, maxval: 4000, warp: \lin, step: 1, default: 0));

// Add GUI for controlling the parameters

Ndef(\DuoWave).gui;
)

Ndef(\DuoWave).clear;

s.quit;


















