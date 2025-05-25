{ tools, lib, ... }:
{
  config = {
    name = "tagref";
    description = "Have tagref check all references and tags.";
    package = tools.tagref;
    entry = "${tools.tagref}/bin/tagref";
    types = [ "text" ];
    pass_filenames = false;
  };
}