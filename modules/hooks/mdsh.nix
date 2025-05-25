{ tools, lib, ... }:
{
  config = {
    name = "mdsh";
    description = "Markdown shell pre-processor.";
    package = tools.mdsh;
    entry = "${tools.mdsh}/bin/mdsh";
    files = "\.md$";
    pass_filenames = false;
  };
}