{ tools, lib, config, ... }:
{
  config = {
    package = tools.hindent;
    entry = "${config.package}/bin/hindent";
    files = "\.l?hs$";
  };
}
