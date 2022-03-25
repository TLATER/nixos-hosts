{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hardware.pulseaudio.rnnoise-suppression;
in {
  options.hardware.pulseaudio.rnnoise-suppression = {
    enable = mkEnableOption {
      type = types.bool;
      default = false;
      description = ''
        Enable noise suppression with rnnoise.
      '';
    };

    source = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The input source (microphone) whose input to suppress noise
        on. Required.

        A list of all sources on the system can be determined with
        `pactl list short sources`.
      '';
    };

    suppression-type = mkOption {
      type = types.enum ["mono" "stereo"];
      default = "mono";
      description = ''
        Whether to suppress on a mono or stereo channel. The default
        is the safe mono, but you likely want stereo.
      '';
    };

    voice-threshold = mkOption {
      type = types.int;
      default = 50;
      description = ''
        The degree of confidence required to detect voice input.

        Upstream recommends 95 as "probably fine", but suggests 50 as
        a safe default for most microphones.
      '';
    };
  };

  config = mkIf cfg.enable {
    hardware.pulseaudio.extraConfig = assert asserts.assertMsg (cfg.source != null)
    "A source is required for noise suppression."; let
      number-of-channels =
        if cfg.suppression-type == "mono"
        then "1"
        else "2";
    in ''
      # The sink our noise suppression output will go to
      load-module module-null-sink ${
        builtins.concatStringsSep " " [
          "sink_name=${cfg.source}.denoised"
          ''sink_properties="device.description='Suppressed Microphone'"''
          "rate=48000"
        ]
      }

      # The noise suppression processing plugin
      load-module module-ladspa-sink ${
        builtins.concatStringsSep " " [
          "sink_name=${cfg.source}.raw"
          ''sink_properties="device.description='Suppression Processor'"''
          "sink_master=${cfg.source}.denoised"
          "label=noise_suppressor_${cfg.suppression-type}"
          "plugin=${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so"
          "control=${toString cfg.voice-threshold}"
        ]
      }

      # A loopback module to send source sound to the noise suppressor
      load-module module-loopback ${
        builtins.concatStringsSep " " [
          "source=${cfg.source}"
          "sink=${cfg.source}.raw"
          "channels=${number-of-channels}"
          "source_dont_move=true"
          "sink_dont_move=true"
        ]
      }

      # Finally wrap it all back into a source, so that
      # applications can use the noise-suppressed input
      load-module module-remap-source ${
        builtins.concatStringsSep " " [
          "source_name=${cfg.source}.denoised-source"
          ''source_properties="device.description='Noise\-Suppressed Input'"''
          "master=${cfg.source}.denoised.monitor"
          "channels=${number-of-channels}"
        ]
      }
    '';
  };
}
