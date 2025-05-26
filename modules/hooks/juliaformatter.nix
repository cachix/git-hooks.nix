{ config, tools, lib, ... }:
{
  config = {
    name = "juliaformatter";
    description = "Run JuliaFormatter.jl against Julia source files";
    package = tools.julia-bin;
    entry = ''
      ${config.package}/bin/julia -e '
      using Pkg
      Pkg.activate(".")
      using JuliaFormatter
      format(ARGS)
      out = Cmd(`git diff --name-only`) |> read |> String
      if out == ""
          exit(0)
      else
          @error "Some files have been formatted !!!"
          write(stdout, out)
          exit(1)
      end'
    '';
    files = "\\.jl$";
  };
}
