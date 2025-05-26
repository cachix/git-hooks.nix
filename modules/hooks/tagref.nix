{ tools, lib, config, ... }:
{
  config = {
    package = tools.tagref;
    entry = "${config.package}/bin/tagref";
    types = [ "text" ];
    pass_filenames = false;
  };
}
