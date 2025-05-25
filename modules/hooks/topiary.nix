{ tools, lib, ... }:
{
  config = {
    name = "topiary";
    description = "A universal formatter engine.";
    package = tools.topiary;
    entry = "${tools.topiary}/bin/topiary format";
    pass_filenames = false;
  };
}