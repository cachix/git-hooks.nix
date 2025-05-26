{ tools, lib, config, ... }:
{
  config = {
    name = "tagref";
    description = "Have tagref check all references and tags.";
    package = tools.tagref;
    entry = "${config.package}/bin/tagref";
    types = [ "text" ];
    pass_filenames = false;
  };
}
