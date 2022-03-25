{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hardware.pulseaudio.echo-canceling;
in {
  options.hardware.pulseaudio.echo-canceling = {
    enable = mkEnableOption {
      type = types.bool;
      default = false;
      description = ''
        Enable echo cancellation.

        Source and sink can be determined with `pactl list short
        sources` and `pactl list short sink` respectively.

        This will create a new, echo-canceled source, which can be
        either set as default using pulseaudio config or a graphical
        tool like pavucontrol.

        This will cancel sound coming from the computer's speakers
        from the microphone input. This also turns on noise
        suppression and voice detection, so should in general result
        in a better listening experience.
      '';
    };

    source = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The input source (microphone) whose input to cancel echos
        for. Required.

        A list of all sources on the system can be determined with
        `pactl list short sources`.
      '';
    };

    sink = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The output to cancel out of the microphone input.

        A list of all sinks on the system can be determined with
        `pactl list short sinks`.

        If not specified, this will be an empty dummy sound, resulting
        in no cancellation. Useful for headphones.
      '';
    };

    aec-method = mkOption {
      type = types.str;
      default = "webrtc";
      description = "The aec method to use.";
    };

    aec-args = mkOption {
      type = types.listOf types.str;
      default = [
        "analog_gain_control=0"
        "digital_gain_control=1"
        "experimental_agc=1"
        "noise_suppression=1"
        "voice_detection=1"
        "extended_filter=1"
      ];
      description = ''
        The default arguments to the echo cancellation module.

        These are undocumented upstream, the defaults were taken
        from the arch wiki [here](https://wiki.archlinux.org/index.php/PulseAudio/Examples).
      '';
    };
  };

  config = mkIf cfg.enable {
    hardware.pulseaudio.extraConfig = assert asserts.assertMsg (cfg.source != null)
    "A source is required for echo cancellation"; let
      aec-args = builtins.concatStringsSep " " cfg.aec-args;
      module-args = builtins.concatStringsSep " " ([
          "use_master_format=1"
          "aec_method=${cfg.aec-method}"
          ''aec_args="${aec-args}"''

          ''source_master="${cfg.source}"''
          ''source_name="${cfg.source}.echo-cancel"''
          ''source_properties="device.description='Echo\-Canceled Input'"''
        ]
        ++ (
          if cfg.sink != null
          then [''sink_master="${cfg.sink}"'']
          else []
        ));
    in ''
      # Enable echo cancellation
      load-module module-echo-cancel ${module-args}
    '';
  };
}
