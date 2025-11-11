## Enforce using the nix-provided Elixir for local development.
## This prevents accidental use of system/Homebrew Elixir which can
## cause compilation and test inconsistencies. CI can bypass this
## by setting the CI env var, and developers can opt out by
## setting ALLOW_SYSTEM_ELIXIR=1 (not recommended).

case System.find_executable("elixir") do
  nil -> :ok
  elixir_path ->
    in_nix = String.contains?(elixir_path, "/nix/store/")
    ci = System.get_env("CI")
    allow = System.get_env("ALLOW_SYSTEM_ELIXIR")

    unless in_nix or ci == "true" or allow == "1" do
      IO.puts("\nERROR: Detected elixir at: #{elixir_path}\n")
      IO.puts("This project requires running Elixir from the Nix dev-shell (nix develop / direnv allow).\n")
      IO.puts("Please start a nix dev-shell or set ALLOW_SYSTEM_ELIXIR=1 to bypass this check.\n")
      System.halt(1)
    end
end

defmodule SingularityCodeAnalysis.MixProject do
  use Mix.Project

  def project do
    [
      app: :singularity_code_analysis,
      version: "0.1.0",
      elixir: "~> 1.19",
      compilers: Mix.compilers(),
      rustler_crates: [singularity_code_analysis: [skip_compilation?: true]],
      deps: deps(),

      # Testing and coverage
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],

      # Dialyzer
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:mix, :ex_unit],
        flags: [:error_handling, :underspecs, :unmatched_returns]
      ]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:rustler, "~> 0.37", runtime: false},

      # Code quality and linting
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.21", only: [:dev, :test], runtime: false},

      # Security scanning
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},

      # Code coverage
      {:excoveralls, "~> 0.18", only: :test}
    ]
  end
end
