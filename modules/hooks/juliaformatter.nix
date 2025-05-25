{ tools, lib, ... }:
{
  config = {
    name = "juliaformatter";
    description = "Format Julia files.";
    package = tools.julia-bin;
    entry = "${tools.julia-bin}/bin/julia -e 'using JuliaFormatter; format(".")'";
    files = "\.jl$";
    pass_filenames = false;
  };
}