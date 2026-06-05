defmodule SvgSanitizer.Native do
  @moduledoc false

  mix_config = Mix.Project.config()
  version = mix_config[:version]
  github_url = mix_config[:source_url]

  use RustlerPrecompiled,
    otp_app: :svg_sanitizer,
    crate: "svg_sanitizer_nif",
    base_url: "#{github_url}/releases/download/v#{version}",
    force_build: System.get_env("SVG_SANITIZER_BUILD") in ["1", "true"],
    # Linux (the prod deploy target) is built and published by CI on tag push.
    # Apple Silicon (aarch64-apple-darwin) ships a precompiled artifact built
    # locally and uploaded to the GitHub Release — CI can't build it because
    # rustler-precompiled-action v1.1.5 unconditionally installs `cross`, which
    # fails on macOS runners. See the "macOS arm64" step in RELEASING.md.
    # Intel Macs (x86_64-apple-darwin) are not precompiled; those devs set
    # SVG_SANITIZER_BUILD=1 (requires cargo) to build from source.
    targets: ~w(
      aarch64-apple-darwin
      aarch64-unknown-linux-gnu
      x86_64-unknown-linux-gnu
    ),
    version: version,
    # NIF 2.17 ships with OTP 26+. Earlier NIF versions are added on demand.
    nif_versions: ["2.17"]

  # Implementation lives in native/svg_sanitizer_nif (Rust). The function below
  # is replaced at load time by the NIF; this stub exists so the module
  # compiles even when no precompiled artifact is available.
  def sanitize(_svg), do: :erlang.nif_error(:nif_not_loaded)
end
